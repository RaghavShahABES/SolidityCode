//SPDX-License-Identifier : MIT

pragma solidity >=0.5.0 <0.9.0;

contract lottery{

    address public manager;
    address payable[] public participants;

    constructor(){
        manager=msg.sender;
    }
    receive() external payable {
        require(msg.value==1 ether,"Atleast 1 ETHER require to paticipate");
        participants.push(payable(msg.sender));
    }
    function getBalance() public view returns(uint){
        require(msg.sender==manager,"You are not Manager");
        return address(this).balance;
    } 
    function Random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,participants.length)));
    }
    function getWinner() public{
        require(msg.sender==manager);
        require(participants.length>=3);
        uint r=Random();
        address payable winner;
        uint index = r % participants.length;
        winner=participants[index];
        winner.transfer(getBalance());
        participants = new address payable[](0); ///x
    }

}