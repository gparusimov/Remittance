var Owned = artifacts.require("./Owned.sol");
var Stoppable = artifacts.require("./Stoppable.sol");
var Remittance = artifacts.require("./Remittance.sol");

module.exports = function(deployer) {
    deployer.deploy(Owned);
    deployer.deploy(Stoppable);
    deployer.deploy(Remittance);
};
