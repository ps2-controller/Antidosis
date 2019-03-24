var Migrations = artifacts.require("./Migrations.sol");
const ERC721 = artifacts.require("ERC721")
const dummy721 = artifacts.require("dummy721");

//const DriverCoreInterface = artifacts.require("DriverCoreInterface");
//const DeploymentCoreInterface = artifacts.require("DeploymentCoreInterface");
const DeploymentCoreExample = artifacts.require("DeploymentCoreExample");
const TokenizeCore = artifacts.require("TokenizeCore");


module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(ERC721);
  deployer.deploy(dummy721);

  //deployer.deploy(DriverCoreInterface);
  deployer.deploy(DeploymentCoreExample);
  deployer.deploy(TokenizeCore);
};


 	