pragma solidity ^0.4.18;

contract Owned {

	address public owner;

	modifier onlyOwner
	{
		require(msg.sender == owner);
		_;
	}

	function Owned()
	 public
	{
      owner = msg.sender;
	}

}