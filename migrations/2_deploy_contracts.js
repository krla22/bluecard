const ReliefDistribution = artifacts.require("ReliefDistribution");

module.exports = function (deployer) {
  deployer.deploy(ReliefDistribution);
};
