// SPDX-Licence-Identifier: GPL -3.0
pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    address public manager;
    address payable[] public participants;

    constructor() public
    {
        manager=msg.sender;
    }

    receive() external payable 
    {
        require(msg.value == 1 ether);
        participants.push(msg.sender); 
    } 

    function getBalance() public view returns(uint)
    {
        require(msg.sender == manager);
        return address(this).balance;
    }

    function random() public view returns(uint)
    {
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,participants.length)));
    }
    function selectWinner() public
    {
        require(manager==msg.sender);
        require(participants.length>=2);
        uint r = random();
        address payable winner;
        uint index = r % participants.length ;
        winner = participants[index];
        winner.transfer(getBalance());
        participants=new address payable[](0);
    }
}