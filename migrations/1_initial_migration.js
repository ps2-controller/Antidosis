var Migrations = artifacts.require("./Migrations.sol");
const ERC721 = artifacts.require("ERC721")
const dummy721 = artifacts.require("dummy721");

const DeploymentCore = artifacts.require("DeploymentCore");
const TokenizeCore = artifacts.require("TokenizeCore");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(ERC721);
  deployer.deploy(dummy721);

  deployer.deploy(DeploymentCore);
  deployer.deploy(TokenizeCore);
};
 