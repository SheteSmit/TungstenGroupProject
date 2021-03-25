// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// make sure that only the owner is allowed to do certain functions
contract Ownable {

    address public _owner;

    event OwnershipTransferred(address _previousOwner, address indexed _newOwner);

    constructor () {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(isOwner(), "You are not the owner.");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit OwnershipTransferred(_owner, _newOwner);
    }
}