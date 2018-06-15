    pragma solidity ^0.4.18;

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

        event LogRemittance(address _reciever, bytes32 _passwordHash, uint _availableBlocks, uint _amount);
        event LogWithdraw(address reciever, uint amount);
        event LogKill(address indexed owner);
        event LogAmountBack(uint claimAmount);

        function Remittance()
        public
        {

        }

        function remittance(address _recipient, bytes32 _passwordHash, uint _availableBlocks)
        external
        payable
        {
            require(_availableBlocks != 0);
            require(_availableBlocks <= maxDeadlineBlocks);
            require(recipient != 0);
            remittances[_passwordHash] = RemittanceStruct({
                receiver: _recipient,
                sender: msg.sender,
                remitAmount: msg.value,
                expirationBlock: block.number + _availableBlocks
                });

            emit LogRemittance(_recipient, _availableBlocks, msg.value);
        }

        function withdraw(address _recipient, string _password)
        onlyIfRunning
        external
        payable
        returns(bool)
        {
            bytes32 passHash = hashForPassword(_recipient, _password);
            RemittanceStruct memory remittance = remittances[passHash];
            uint withdrawalAmount =remittance.remitAmount;

            require(remittance.receiver == _recipient);
            require(remittance.expirationBlock >= block.number);
            require(withdrawalAmount!=0);

            remittance.remitAmount = 0;

            emit LogWithdraw(msg.sender, withdrawalAmount);
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

            emit LogAmountBack(claimAmount);
            remittance.sender.transfer(claimAmount);
            return true;
        }

        function hashForPassword(address _remitter, string _password)
        pure
        public
        returns (bytes32 hashedOutput)
        {
            return keccak256(_remitter, _password);
        }
    }
