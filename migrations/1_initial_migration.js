const Migrations = artifacts.require("./Migrations.sol");
const dummy721 = artifacts.require("dummy721");
const Dai = artifacts.require("Dai");

//const DriverCoreInterface = artifacts.require("DriverCoreInterface");
//const DeploymentCoreInterface = artifacts.require("DeploymentCoreInterface");
const TokenizeCore = artifacts.require("TokenizeCore");


module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Dai);
  deployer.deploy(dummy721);

  //deployer.deploy(DriverCoreInterface);
  deployer.deploy(TokenizeCore);
};



 	