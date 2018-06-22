pragma solidity ^0.4.21;

contract Owned {

    address private owner;

    event LogChangeOwner(address sender, address newOwner);

    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }

    constructor()
    public
    {
        owner = msg.sender;
    }

    function changeOwner(address newOwner)
    public
    onlyOwner
    returns(bool success)
    {
        require(newOwner!=0);
        require(newOwner!=owner);
        owner = newOwner;
        emit LogChangeOwner(msg.sender, newOwner);
        return true;
    }

    function getOwner()
    public
    view
    returns(address) {
        return owner;
    }

}