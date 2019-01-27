var Migrations = artifacts.require("./Migrations.sol");
const Migrations = artifacts.require("./deployment-core.sol");
const Migrations = artifacts.require("./tokenize-core.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(DeploymentCoreExample);
  deployer.deploy(TokenizeCore);
};
 