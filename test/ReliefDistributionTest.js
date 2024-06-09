const ReliefDistribution = artifacts.require("ReliefDistribution");

contract("ReliefDistribution", (accounts) => {
  let reliefInstance;
  const admin = accounts[0];
  const cardholder1 = accounts[1];
  const cardholder2 = accounts[2];

  before(async () => {
    reliefInstance = await ReliefDistribution.deployed();
  });

  it("should add funds to the admin account", async () => {
    await reliefInstance.addFunds({ from: admin, value: web3.utils.toWei("5", "ether") });
    const contractBalance = await web3.eth.getBalance(reliefInstance.address);
    assert.equal(contractBalance, web3.utils.toWei("5", "ether"), "Contract should have 5 ether");
  });

  it("should distribute relief to cardholder1", async () => {
    await reliefInstance.distributeRelief(cardholder1, web3.utils.toWei("1", "ether"), { from: admin });
    const cardholder1Balance = await web3.eth.getBalance(cardholder1);
    assert(cardholder1Balance > web3.utils.toWei("100", "ether"), "Cardholder 1 should receive 1 ether");
  });

  it("should transfer funds from cardholder1 to cardholder2", async () => {
    // Ensure cardholder1 has enough balance to transfer
    await web3.eth.sendTransaction({ from: admin, to: cardholder1, value: web3.utils.toWei("1", "ether") });
    await reliefInstance.transferFunds(cardholder2, web3.utils.toWei("0.5", "ether"), { from: cardholder1 });
    const cardholder2Balance = await web3.eth.getBalance(cardholder2);
    assert(cardholder2Balance > web3.utils.toWei("100", "ether"), "Cardholder 2 should receive 0.5 ether");
  });

  it("should remove balance from the contract", async () => {
    await reliefInstance.removeBalance(admin, web3.utils.toWei("2", "ether"), { from: admin });
    const contractBalance = await web3.eth.getBalance(reliefInstance.address);
    assert.equal(contractBalance, web3.utils.toWei("2", "ether"), "Admin should remove 2 ether from the contract");
  });
});
