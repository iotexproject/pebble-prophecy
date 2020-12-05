const Prophecy = artifacts.require('Prophecy');
const { assertAsyncThrows } = require('./assert-async-throws');

contract('Prophecy', function ([owner, alpha]) {
  beforeEach(async function () {
    // use shadow token as burnable erc20 token
    this.prophecy = await Prophecy.new();
  });

  it('set registration fee', async function () {
    assert.equal(await this.prophecy.registrationFee(), 0);
    await this.prophecy.setRegistrationFee(12345678);
    assert.equal(await this.prophecy.registrationFee(), 12345678);
  });

  it('set subscription fee', async function () {
    assert.equal(await this.prophecy.subscriptionFee(), 0);
    await this.prophecy.setSubscriptionFee(12345678);
    assert.equal(await this.prophecy.subscriptionFee(), 12345678);
  });

  it('pre-register device', async function () {

    let _deviceId = web3.utils.fromAscii("123456789");
    await this.prophecy.preRegisterDevice(owner);

    assert.equal(await this.prophecy.allowedIDHashes(owner), true);
    assert.equal(await this.prophecy.allowedIDHashes(_deviceId), false);

    // cannot pre-register again
    try {
      let _result = await this.prophecy.preRegisterDevice(owner);
    } catch (err) {
      assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert already whitelisted -- Reason given: already whitelisted.')
    }
  });

  it('register device', async function () {
    let _deviceId = web3.utils.fromAscii("random0");
    let _freq = 1;
    let _spec = "xxxx";
    let _price = 1;
    let _rsaPubkeyN = web3.utils.fromAscii("random1");
    let _rsaPubkeyE = web3.utils.fromAscii("random2");

    let _deviceIdHash = web3.utils.keccak256(web3.eth.abi.encodeParameter('bytes32', _deviceId));
    await this.prophecy.preRegisterDevice(_deviceIdHash);

    let _result = await this.prophecy.registerDevice(_deviceId, _freq, _price, _spec, _rsaPubkeyN, _rsaPubkeyE);
    assert.equal(_result.receipt.status, true);

    // cannot register again
    try {
      await this.prophecy.registerDevice(_deviceId, _freq, _price, _spec, _rsaPubkeyN, _rsaPubkeyE);
    } catch (err) {
      assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert id not allowed -- Reason given: id not allowed.')
    }

    // register device not in whitelist
    _deviceId = web3.utils.fromAscii("wrong id");
    try {
      await this.prophecy.registerDevice(_deviceId, _freq, _price, _spec, _rsaPubkeyN, _rsaPubkeyE);
    } catch (err) {
      assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert id not allowed -- Reason given: id not allowed.')
    }
  });

  describe('after register device', function () {
    beforeEach(async function () {
      let _deviceId = web3.utils.fromAscii("random0");
      let _freq = 1;
      let _spec = "xxxx";
      let _price = 0;
      let _rsaPubkeyN = web3.utils.fromAscii("random1");
      let _rsaPubkeyE = web3.utils.fromAscii("012345");

      let _deviceIdHash = web3.utils.keccak256(web3.eth.abi.encodeParameter('bytes32', _deviceId));
      await this.prophecy.preRegisterDevice(_deviceIdHash);

      let _result = await this.prophecy.registerDevice(_deviceId, _freq, _price, _spec, _rsaPubkeyN, _rsaPubkeyE);
      assert.equal(_result.receipt.status, true);
    });

    it('update device', async function () {
      let _deviceId = web3.utils.fromAscii("random0");
      let _freq = 2;
      let _spec = "yyyy";
      let _price = 1234;
      let _rsaPubkeyN = web3.utils.fromAscii("random3");
      let _rsaPubkeyE = web3.utils.fromAscii("random4");

      let _result = await this.prophecy.updateDevice(_deviceId, _freq, _price, _spec, _rsaPubkeyN, _rsaPubkeyE);
      assert.equal(_result.receipt.status, true);

      _result = await this.prophecy.getDeviceInfoByID(_deviceId);
      assert.equal(_result[1].toString(), '2');
      assert.equal(_result[2].toString(), '1234');
      assert.equal(_result[5], "yyyy");
      assert.equal(_result[6].toString(), "0x72616e646f6d33");
      assert.equal(_result[7].toString(), "0x72616e646f6d34");

      // update device not yet registered
      _deviceId = web3.utils.fromAscii("wrong id");
      try {
        await this.prophecy.updateDevice(_deviceId, _freq, _price, _spec, _rsaPubkeyN, _rsaPubkeyE);
      } catch (err) {
        assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert not yet registered -- Reason given: not yet registered.')
      }
    });

    it('subscribe', async function () {
      // subscribe device not yet registered
      let _deviceId = web3.utils.fromAscii("wrong id");
      try {
        await this.prophecy.subscribe(_deviceId, 1, "aaa", "bbb", {from: owner, value: 100});
      } catch (err) {
        assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert no such device -- Reason given: no such device.')
      }

      _deviceId = web3.utils.fromAscii("random0");
      let _result = await this.prophecy.subscribe(_deviceId, 1, "aaa", "bbb", { from: owner, value: 100 });
      assert.equal(_result.receipt.status, true);
      _result = await this.prophecy.getDeviceOrderByID(_deviceId);
      assert.equal(_result[1].toString(), '1');
      assert.equal(_result[2].toString(), 'aaa');
      assert.equal(_result[3].toString(), "bbb");

      // subscribe while still active
      _deviceId = web3.utils.fromAscii("random0");
      try {
        await this.prophecy.subscribe(_deviceId, 1, "aaa", "bbb", {from: owner, value: 100});
      } catch (err) {
        assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert device in active subscription -- Reason given: device in active subscription.')
      }

      // let one block pass
      await this.prophecy.getDeviceInfoByID(_deviceId)
      _result = await this.prophecy.subscribe(_deviceId, 2, "ccc", "ddd", {from: owner, value: 100});
      assert.equal(_result.receipt.status, true);
      _result = await this.prophecy.getDeviceOrderByID(_deviceId);
      assert.equal(_result[1].toString(), '2');
      assert.equal(_result[2].toString(), 'ccc');
      assert.equal(_result[3].toString(), "ddd");
    });

    it('claim', async function () {
      // claim device not yet registered
      let _deviceId = web3.utils.fromAscii("wrong id");
      try {
        await this.prophecy.claim(_deviceId);
      } catch (err) {
        assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert no such device -- Reason given: no such device.')
      }

      // not from owner
      _deviceId = web3.utils.fromAscii("random0");
      try {
        await this.prophecy.claim(_deviceId, {from: alpha});
      } catch (err) {
        assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert not owner -- Reason given: not owner.')
      }

      // no order yet
      try {
        await this.prophecy.claim(_deviceId);
      } catch (err) {
        assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert device not yet subscribed -- Reason given: device not yet subscribed.')
      }

      let _result = await this.prophecy.subscribe(_deviceId, 1, "aaa", "bbb", { from: owner, value: 100 });
      assert.equal(_result.receipt.status, true);

      try {
        await this.prophecy.claim(_deviceId);
      } catch (err) {
        assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert device in active subscription -- Reason given: device in active subscription.')
      }

      // let one block pass
      await this.prophecy.getDeviceInfoByID(_deviceId)

      _result = await this.prophecy.claim(_deviceId);
      assert.equal(_result.receipt.status, true);
    });

    it('get device ids', async function () {
      let _result = await this.prophecy.getDeviceIDs(0, 1);

      assert.equal(_result.count, 1);
      assert.equal(_result.ids.length, 1);
    });

    it('get device by id', async function () {
      let _deviceId = web3.utils.fromAscii("random0");
      let _result = await this.prophecy.getDeviceInfoByID(_deviceId);
      assert.equal(_result[1].toString(), '1');
      assert.equal(_result[2].toString(), '0');
      assert.equal(_result[5], "xxxx");
      assert.equal(_result[6].toString(), "0x72616e646f6d31");
      assert.equal(_result[7].toString(), "0x303132333435");

      _deviceId = web3.utils.fromAscii("wrong id");
      try {
        await this.prophecy.getDeviceInfoByID(_deviceId);
      } catch (err) {
        assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert no such device')
      }
    });

    it('get order by id', async function () {
      let _deviceId = web3.utils.fromAscii("random0");
      try {
        await this.prophecy.getDeviceOrderByID(_deviceId);
      } catch (err) {
        assert.equal(err.message.toString(), 'Returned error: VM Exception while processing transaction: revert no order yet')
      }
    })

  });

  it('collect fees', async function () {
    let _result = await this.prophecy.collectFees();
    assert.equal(_result.receipt.status, true);
  });

  it('register device w/ free stream', async function () {
    let _deviceId = web3.utils.fromAscii("random789");
    let _freq = 1;
    let _spec = "xxxx";
    let _price = 0; // free stream
    let _rsaPubkeyN = web3.utils.fromAscii("random1");
    let _rsaPubkeyE = web3.utils.fromAscii("random2");

    let _deviceIdHash = web3.utils.keccak256(web3.eth.abi.encodeParameter('bytes32', _deviceId));
    await this.prophecy.preRegisterDevice(_deviceIdHash);

    let _result = await this.prophecy.registerDevice(_deviceId, _freq, _price, _spec, _rsaPubkeyN, _rsaPubkeyE);
    assert.equal(_result.receipt.status, true);

    // check if registered
    _result = await this.prophecy.getDeviceInfoByID(_deviceId);
    assert.equal(_result[1].toString(), '1');
    assert.equal(_result[2].toString(), '0'); // free, yay!
    assert.equal(_result[5], "xxxx");
    assert.equal(_result[6].toString(), "0x72616e646f6d31");
    assert.equal(_result[7].toString(), "0x72616e646f6d32");

    // make sure everything is free
    assert.equal(await this.prophecy.subscriptionFee(), 0);

    // should be able to subscribe to this free stream
    _result = await this.prophecy.subscribe(_deviceId, 394, "lalala", "hahaha", { from: owner, value: 0 });
    assert.equal(_result.receipt.status, true);
    _result = await this.prophecy.getDeviceOrderByID(_deviceId);
    assert.equal(_result[1].toString(), '394');
    assert.equal(_result[2].toString(), 'lalala');
    assert.equal(_result[3].toString(), "hahaha");
  });

  // https://github.com/iotexproject/pebble-prophecy/issues/9
  it('getDeviceOrderByID() return null when no order is available', async function () {
    let _deviceId = web3.utils.fromAscii("random789");
    let _freq = 1;
    let _spec = "xxxx";
    let _price = 0; // free stream
    let _rsaPubkeyN = web3.utils.fromAscii("random1");
    let _rsaPubkeyE = web3.utils.fromAscii("random2");

    let _deviceIdHash = web3.utils.keccak256(web3.eth.abi.encodeParameter('bytes32', _deviceId));
    await this.prophecy.preRegisterDevice(_deviceIdHash);

    let _result = await this.prophecy.registerDevice(_deviceId, _freq, _price, _spec, _rsaPubkeyN, _rsaPubkeyE);
    assert.equal(_result.receipt.status, true);

    // check order while there is no order
    _result = await this.prophecy.getDeviceOrderByID(_deviceId);
    console.log(_result)
    assert.equal(_result[1], 0);
    assert.equal(_result[2].toString(), "");
    assert.equal(_result[3].toString(), "");
  });
});
