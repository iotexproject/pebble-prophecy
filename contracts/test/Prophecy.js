const Prophecy = artifacts.require('Prophecy');
const { assertAsyncThrows } = require('./assert-async-throws');

contract('Prophecy', function ([owner]) {
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

  it('pre register device', async function () {

    let _deviceId = web3.utils.fromAscii("123456789");
    await this.prophecy.preRegisterDevice(owner);

    assert.equal(await this.prophecy.allowedIDHashes(owner), true);
    assert.equal(await this.prophecy.allowedIDHashes(_deviceId), false);
  });

  it('register device', async function () {
    let _deviceId = web3.utils.fromAscii("random0");
    let _devicePubKeyX = web3.utils.fromAscii("random1");
    let _devicePubKeyY = web3.utils.fromAscii("random2");
    let _freq = 1;
    let _spec = "xxxx";
    let _price = 1;

    let _deviceIdHash = web3.utils.keccak256(web3.eth.abi.encodeParameter('bytes32', _deviceId));
    await this.prophecy.preRegisterDevice(_deviceIdHash);

    let _result = await this.prophecy.registerDevice(_deviceId, _devicePubKeyX, _devicePubKeyY, _freq, _spec, _price);

    assert.equal(_result.receipt.status, true);

  });

  describe('after register device', function () {
    beforeEach(async function () {
      let _deviceId = web3.utils.fromAscii("random0");
      let _devicePubKeyX = web3.utils.fromAscii("random1");
      let _devicePubKeyY = web3.utils.fromAscii("random2");
      let _freq = 1;
      let _spec = "xxxx";
      let _price = 0;

      let _deviceIdHash = web3.utils.keccak256(web3.eth.abi.encodeParameter('bytes32', _deviceId));
      await this.prophecy.preRegisterDevice(_deviceIdHash);

      await this.prophecy.registerDevice(_deviceId, _devicePubKeyX, _devicePubKeyY, _freq, _spec, _price);
    });

    it('update device', async function () {
      let _deviceId = web3.utils.fromAscii("random0");
      let _devicePubKeyX = web3.utils.fromAscii("random1");
      let _devicePubKeyY = web3.utils.fromAscii("random2");
      let _freq = 1;
      let _spec = "xxxx";
      let _price = 1234;

      let _result = await this.prophecy.updateDevice(_deviceId, _devicePubKeyX, _devicePubKeyY, _freq, _spec, _price);
      assert.equal(_result.receipt.status, true);

    });

    it('subscribe', async function () {
      let _deviceId = web3.utils.fromAscii("random0");
      let _result = await this.prophecy.subscribe(_deviceId, "aaa", "bbb", 1, { from: owner, value: 100 });
      assert.equal(_result.receipt.status, true);

    });

    it('claim', async function () {
      let _deviceId = web3.utils.fromAscii("random0");
      await this.prophecy.subscribe(_deviceId, "aaa", "bbb", 1, { from: owner, value: 100 });
      let _result = await this.prophecy.claim(_deviceId);
      assert.equal(_result.receipt.status, true);

    });

    it('get device ids', async function () {
      let _result = await this.prophecy.getDeviceIDs(0, 1);

      assert.equal(_result.count, 1);
      assert.equal(_result.ids.length, 1);
    });

    it('get device by id', async function () {
      let _deviceId = web3.utils.fromAscii("random0");
      let _result = await this.prophecy.getDeviceByID(_deviceId);

      assert.equal(_result[7], "xxxx");
    });

  });

  it('collect fees', async function () {
    let _result = await this.prophecy.collectFees();
    assert.equal(_result.receipt.status, true);
  });

});
