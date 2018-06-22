const Remittance = artifacts.require("./Remittance.sol");

contract('Remittance', function(accounts) {
    var instance;
    const owner =  accounts[0]
    const sender = accounts[1];
    const receiver = accounts[2];
    const remitAmount = 10;
    var password = "passwd";
    var passwordHash;
    var passwordHash2;
    var expirationBlock = 25;
    const status = 1;
    beforeEach(function() {
        return Remittance.new({ from: owner }).then(function(_instance) {
            instance = _instance;
        });
    });

    it("remit and withdrow successfully happened", function() {
            return instance.hashForPassword(instance.address, password).then(function(txPasswordHash) {
            passwordHash = txPasswordHash;
            return instance.remit(receiver, txPasswordHash, expirationBlock, {from: sender, value: remitAmount});
        }).then(function(txObj) {
            assert.equal(status, txObj.receipt.status);
            assert.strictEqual(receiver, txObj.logs[0].args._reciever);
            assert.equal(expirationBlock, txObj.logs[0].args._availableBlocks.toString(10));
            assert.equal(remitAmount, txObj.logs[0].args._amount.toString(10));
            return instance.withdraw(password, {from: sender});
        }).then(function(txWithdraw) {
            assert.equal(status, txWithdraw.receipt.status);
            assert.strictEqual(receiver, txWithdraw.logs[0].args.reciever);
            assert.equal(remitAmount, txWithdraw.logs[0].args.amount.toString(10));
        });
    });

    it("remmit and claimAmountBack successfully happened", function() {
            expirationBlock = 1;
            return instance.hashForPassword(instance.address, password).then(function(txPasswordHash) {
            passwordHash2 = txPasswordHash;
            return instance.remit(receiver, passwordHash, expirationBlock, {from: sender, value: remitAmount});
        }).then(function(txObj) {
            assert.equal(status, txObj.receipt.status);
            assert.strictEqual(receiver, txObj.logs[0].args._reciever);
            assert.equal(expirationBlock, txObj.logs[0].args._availableBlocks.toString(10));
            assert.equal(remitAmount, txObj.logs[0].args._amount.toString(10));
            return instance.remit(sender, passwordHash2, expirationBlock, {from: receiver, value: remitAmount});
        }).then(function(txObj) {
            assert.equal(status, txObj.receipt.status);
            assert.strictEqual(sender, txObj.logs[0].args._reciever);
            assert.equal(expirationBlock, txObj.logs[0].args._availableBlocks.toString(10));
            assert.equal(remitAmount, txObj.logs[0].args._amount.toString(10));
            return instance.claimAmountBack(passwordHash, {from: sender});
        }).then(function(txClaimAmountBack) {
            assert.equal(status, txClaimAmountBack.receipt.status);
            assert.strictEqual(sender, txClaimAmountBack.logs[0].args.sender);
            assert.equal(remitAmount, txClaimAmountBack.logs[0].args.claimAmount.toString(10));
        });
    });
});