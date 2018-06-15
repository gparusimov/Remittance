pragma solidity ^0.4.18;

import "./Owned.sol";

contract Stoppable is Owned {
    bool private isStopping;

    modifier onlyIfRunning()
    {
        require (!isStopping);
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
    public
    returns (bool _success)
    {
        isStopping = true;

        LogStoppableStopContract (msg.sender);
        return true;
    }

    function resumeContract()
    onlyOwner
    public
    returns (bool _success)
    {
        isStopping = false;

        LogStoppableResumeContract(msg.sender);
        return true;
    }

    function isStopped()
    public
    constant
    returns (bool _isStopping)
    {
        return isStopping;
    }
}
