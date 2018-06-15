pragma solidity ^0.4.18;

import "./Owned.sol";

contract Stoppable is Owned {
    bool private isStopped;

    modifier onlyIfRunning()
    {
        require (!isStopped);
        _;
    }

    event LogStoppableConstruct(address _sender);
    event LogStoppableStopContract(address _sender);
    event LogStoppableResumeContract(address _sender);

    function Stoppable()
    public
    {
        LogNewStoppableConstruct(msg.sender);
    }

    function stopContract()
    onlyOwner
    onlyIfRunning
    returns (bool _success)
    {
        isStopped = true;

        LogStoppableStopContract (msg.sender);
        return true;
    }

    function resumeContract()
    onlyOwner
    returns (bool _success)
    {
        require(isStopped);
        isStopped = false;

        LogStoppableResumeContract(msg.sender);
        return true;
    }

    function isStopped()
    public
    constant
    pure
    returns (bool _isStopped)
    {
        return isStopped;
    }
}
