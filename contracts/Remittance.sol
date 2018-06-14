    pragma solidity ^0.4.18;

    import "./Owned.sol";

    contract Remittance is Owned {

        struct RemittanceStruct
        {
            address receiver;
            address sender;
            uint remitAmount;
            bytes32 hashedPassword;
            uint expirationBlock;
        }

        mapping(bytes32 => RemittanceStruct) public remittances;
        uint public constant maxDeadlineBlocks = 30;

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
            require(_availableBlocks < maxDeadlineBlocks);
            require(recipient != 0);
            remittances[_passwordHash] = new RemittanceStruct({
                receiver: _recipient,
                sender: msg.sender,
                remitAmount: msg.value,
                expirationBlock: block.number + _availableBlocks,
                passwordHash: _passwordHash
                });

            emit LogRemittance(_recipient, _passwordHash, _availableBlocks, msg.value);
        }

        function withdraw(string _password)
        external
        payable
        returns(bool)
        {
            bytes32 passHash = hashForPassword(msg.sender,_password);
            RemittanceStruct memory remittance = remittances[passHash];
            uint withdrawalAmount =remittance.remitAmount;

            require(msg.sender == remittance.receiver);
            require(remittance.expirationBlock >= block.number);
            require(passHash == remittance.hashedPassword);
            require(withdrawalAmount!=0);

            msg.sender.transfer(withdrawalAmount);
            remittance.remitAmount = 0;

            emit LogWithdraw(msg.sender, withdrawalAmount);
            return true;
        }

        function claimAmountBack(string _password)
        external
        returns (bool success)
        {
            bytes32 passHash = hashForPassword(msg.sender,_password);
            RemittanceStruct memory remittance = remittances[passHash];
            uint claimAmount =remittance.remitAmount;

            require(msg.sender == remittance.sender);
            require(remittance.expirationBlock < block.number);
            require(passHash == remittance.hashedPassword);
            require(claimAmount > 0);

            remittance.remitAmount = 0;
            msg.sender.transfer(claimAmount);
            emit LogAmountBack(claimAmount);
            return true;
        }

        function hashForPassword(address _remitter, string _password)
        public
        returns (bytes32 hashedOutput)
        {
            return keccak256(_remitter, _password);
        }

        function kill()
        onlyOwner
        {
            emit LogKill(msg.sender);
            selfdestruct(this);
        }
    }
