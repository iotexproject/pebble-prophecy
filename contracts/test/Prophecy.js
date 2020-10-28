const Prophecy = artifacts.require('Prophecy');
const {assertAsyncThrows} = require('./assert-async-throws');

contract('Prophecy', function([owner]) {
  beforeEach(async function() {
      // use shadow token as burnable erc20 token
      this.prophecy = await Prophecy.new();
  });

  it('set registration fee', async function() {
    assert.equal(await this.prophecy.registrationFee(), 0);
    await this.prophecy.setRegistrationFee(12345678);
    assert.equal(await this.prophecy.registrationFee(), 12345678);
  });

  it('set subscription fee', async function() {
    assert.equal(await this.prophecy.subscriptionFee(), 0);
    await this.prophecy.setSubscriptionFee(12345678);
    assert.equal(await this.prophecy.subscriptionFee(), 12345678);
  });

});
