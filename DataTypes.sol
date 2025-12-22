// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataTypeExperiment {
    uint256 public stateUint = 10;
    string public stateString = "Hello";
    bool public stateBool = true;
    address public stateAddress = address(0x1234567890123456789012345678901234567890); 
    bytes32 public stateBytes = keccak256("initial bytes");

    function operateUint(uint256 _addValue) public view returns (uint256) {
        uint256 localUint = 5; 
        return stateUint + localUint + _addValue;
    }

    function operateString(string memory _append) public pure returns (string memory) {
        string memory localString = " World"; 
        return string.concat(localString, _append);
    }

    function flipBool() public returns (bool) {
        bool localBool = false; 
        stateBool = !stateBool; 
        return stateBool && localBool; 
    }

    function operateAddress() public view returns (uint256) {
        address localAddress = msg.sender; 
        return stateAddress.balance + localAddress.balance; 
    }

    function operateBytes(bytes32 _input) public view returns (bytes32) {
        bytes32 localBytes = keccak256("local prefix"); 
        return keccak256(abi.encodePacked(stateBytes, localBytes, _input)); 
    }

    function localVsStateDemo() public view returns (uint256, uint256) {
        uint256 localDemo = 20;
        return (stateUint, localDemo);
    }
}