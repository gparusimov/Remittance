pragma solidity ^0.4.21;

import "./Stoppable.sol";

contract Remittance is Stoppable {

    struct RemittanceStruct
    {
        address receiver;
        address sender;
        uint remitAmount;
        uint expirationBlock;
    }

    mapping(bytes32 => RemittanceStruct) public remittances;
    uint public maxDeadlineBlocks = 30;

    event LogRemit(address  indexed _reciever, uint _availableBlocks, uint _amount);
    event LogWithdraw(address indexed reciever, uint amount);
    event LogKill(address indexed owner);
    event LogAmountBack(address  indexed sender, uint claimAmount);

    constructor()
    public
    {

    }

    function remit(address _recipient, bytes32 _passwordHash, uint _availableBlocks)
    external
    payable
    {

        require(_availableBlocks != 0);
        require(_availableBlocks <= maxDeadlineBlocks);
        require(_recipient != 0);
        require(remittances[_passwordHash].sender == address(0));

        remittances[_passwordHash] = RemittanceStruct({
            receiver: _recipient,
            sender: msg.sender,
            remitAmount: msg.value,
            expirationBlock: block.number + _availableBlocks
            });

        emit LogRemit(_recipient, _availableBlocks, msg.value);
    }

    function withdraw(string _password)
    onlyIfRunning
    external
    payable
    returns(bool)
    {
        bytes32 passHash = hashForPassword(address(this), _password);
        RemittanceStruct memory remittance = remittances[passHash];
        uint withdrawalAmount = remittance.remitAmount;

        require(remittance.expirationBlock >= block.number);
        require(withdrawalAmount!=0);

        remittance.remitAmount = 0;

        emit LogWithdraw(remittance.receiver, withdrawalAmount);
        remittance.receiver.transfer(withdrawalAmount);
        return true;
    }

    function claimAmountBack(bytes32 _passHash)
    external
    returns (bool success)
    {
        RemittanceStruct memory remittance = remittances[_passHash];
        uint claimAmount =remittance.remitAmount;

        require(remittance.expirationBlock < block.number);
        require(remittance.sender == msg.sender);
        require(claimAmount > 0);

        remittance.remitAmount = 0;

        emit LogAmountBack(msg.sender, claimAmount);
        remittance.sender.transfer(claimAmount);
        return true;
    }

    function hashForPassword(address _contract, string _password)
    pure
    public
    returns (bytes32 hashedOutput)
    {
        return keccak256(_contract, _password);
    }
}
