//SPDX-License-Identifier : MIT

pragma solidity >=0.5.0 <0.9.0;

contract CrowedFund{
    mapping(address=>uint) public contributers;
    address public manager;
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmt;
    uint public NoOfContributers;

    struct Request{
        string discription;
        address payable recipient;
        uint value;
        bool completed;
        uint noofVoters;
        mapping(address=>bool) voters;  
    }

    mapping(uint=>Request) public requests; //requests will work as pointer when more than one Request present
    uint public numRequests;

    constructor(uint _target,uint _deadline){ //For initialzing the default conditions
        target=_target;
        deadline = block.timestamp+_deadline;
        minContribution = 1 ether;
        manager = msg.sender;
    }

    function sendEth() public payable { // For making the contract payable
        require(block.timestamp<deadline,"deadline has passed");
        require(msg.value>=minContribution,"You require a minimum contribution of 1 ether");
        if(contributers[msg.sender]==0){ //checks weather the contributor is contributing first time or not(if not then noofContributers++) else it won't
            NoOfContributers++;
        }
        contributers[msg.sender]+=msg.value; //amount that the contributers will fund
        raisedAmt+=msg.value; //Make record of total amount raised
    }

    function getBalance() public view returns(uint) { //Returns the balance of the contract 
        return address(this).balance;
    }

    function refund() public{ //Refund function when the conditions are not met
        require(raisedAmt<target && block.timestamp>deadline,"You are not eligible");
        require(contributers[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributers[msg.sender]);
        contributers[msg.sender]=0;
        }

        modifier onlyManager(){ //modifier to set cetain function limited to manager only
            require(msg.sender==manager,"You are not Manager");
            _;
        }

        function createRequest(string memory _discription,address payable _recipient,uint _value) public onlyManager{ 
        //Manager will create request about the crowed fund events like (education,global warming) contributers have power to select for what cause they want to contribute
            Request storage newRequest = requests[numRequests]; //Mapping inside struct will use only storage 
            numRequests++;
            newRequest.discription=_discription;
            newRequest.recipient=_recipient;
            newRequest.value=_value;
            newRequest.completed=false;
            newRequest.noofVoters=0;
        }
        function voteRequest(uint _requestNo) public{ 
            //all contributers have right to vote for which event they have to contribute 
            require(contributers[msg.sender]>0,"You must be contributer");
            Request storage thisRequest = requests[_requestNo];
            require(thisRequest.voters[msg.sender]==false,"You have alreaedy voted");
            thisRequest.voters[msg.sender]=true;
            thisRequest.noofVoters++;
        }
        function makePayment(uint _requestNo) public onlyManager{ 
            //The event which have highest votes will get the total target amount from the raised amount
            require(raisedAmt>=target,"Target not met yet");
            Request storage thisRequest=requests[_requestNo];
            require(thisRequest.completed==false,"This request is already completed");
            require(thisRequest.noofVoters>NoOfContributers/2,"Majority does not support"); //more than 50% votes required so (total contributers/2)=50% 
            thisRequest.recipient.transfer(thisRequest.value);
            thisRequest.completed=true;
        }
}



