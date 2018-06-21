const Remittance = artifacts.require("./Remittance.sol");

contract('Remittance', function(accounts) {
    var instance;
    const sender = accounts[0];
    const receiver = accounts[1];
    const remitAmount = 10;
    var password = "passwd";
    var passwordHash;
    var passwordHash2;
    var expirationBlock = 25;

    it("remit and withdrow successfully happened", function() {
        return Remittance.new().then(function(_instance) {
            instance = _instance;
            return instance.hashForPassword(receiver, password);
        }).then(function(txPasswordHash) {
            passwordHash = txPasswordHash;
            return instance.remit(receiver, txPasswordHash, expirationBlock, {from: sender, value: remitAmount});
        }).then(function() {
            return instance.withdraw(receiver, password, {from: sender});
        }).then(function(txWithdraw) {
            assert(txWithdraw.logs.length != 0);
            assert.strictEqual(receiver, txWithdraw.logs[0].args.reciever);
            assert.strictEqual(remitAmount, Number(txWithdraw.logs[0].args.amount));
        });
    });

    it("remmit and claimAmountBack successfully happened", function() {
        expirationBlock = 1;
        return Remittance.new().then(function(_instance) {
            instance = _instance;
            return instance.hashForPassword(sender, password);
        }).then(function(txPasswordHash) {
            passwordHash2 = txPasswordHash;
            return instance.remit(receiver, passwordHash, expirationBlock, {from: sender, value: remitAmount});
        }).then(function() {
            return instance.remit(sender, passwordHash2, expirationBlock, {from: receiver, value: remitAmount});
        }).then(function() {
            return instance.claimAmountBack(passwordHash, {from: sender});
        }).then(function(txClaimAmountBack) {
            assert(txClaimAmountBack.logs.length != 0);
            assert.strictEqual(sender, txClaimAmountBack.logs[0].args.sender);
            assert.strictEqual(remitAmount, Number(txClaimAmountBack.logs[0].args.claimAmount));
        });
    });
});