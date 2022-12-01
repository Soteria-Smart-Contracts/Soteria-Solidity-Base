//SPDX-License-Identifier:UNLICENSE
pragma solidity ^0.8.7;

contract Multi_Signature{
    //Addresses
    address public SignerOne;
    address public SignerTwo;
    address public SignerThree;
    address public SignerFour;

    event FundsRecieved(uint256 Amount, address From);
    event ProposalCreated(uint256 ID, uint256 Amount, address payable Reciever, string Memo);
    event ProposalExecuted(uint256 ID, uint256 Amount, address payable Reciever, string Memo);


    constructor(address _1, address _2, address _3, address _4){
        require(_1 != _2 && _1 != _3 && _2 != _3 && _1 != _4 && _2 != _4 && _3 != _4);
        SignerOne = _1;
        SignerTwo = _2;
        SignerThree = _3;
        SignerFour = _4;
        Signer[_1] = true;
        Signer[_2] = true;
        Signer[_3] = true;
        Signer[_4] = true;
    }

    mapping(address => bool) Signer;
    mapping(uint256 => mapping(address => bool)) ProposalSigned;
    Proposal[] public Proposals;

    //Proposals

    struct Proposal{
        uint8 ProposalType; //Type 1 is ETC, Type 2 is ERC20
        address ERC20; //Defaults to 0
        uint256 Amount;
        address payable Reciever;
        string Memo;
        uint256 Votes;
        //2 Votes Needed
    }

    function CreateETCProposal(uint256 Amount, address payable Reciever, string memory Memo) public returns(uint256 ID){
        require(Signer[msg.sender] == true, "Not Signer");

        Proposal memory NewProposal = Proposal(1, address(0), Amount, Reciever, Memo, 0);

        Proposals.push(NewProposal);
        
        uint256 ProposalID = (Proposals.length - 1);
        emit ProposalCreated(ProposalID, Amount, Reciever, Memo);
        return(ProposalID);
    }

    function CreateERC20Proposal(address TokenAddress, uint256 Amount, address payable Reciever, string memory Memo) public returns(uint256 ID){
        require(Signer[msg.sender] == true, "Not Signer");

        Proposal memory NewProposal = Proposal(2, TokenAddress, Amount, Reciever, Memo, 0);

        Proposals.push(NewProposal);
        
        uint256 ProposalID = (Proposals.length - 1);
        emit ProposalCreated(ProposalID, Amount, Reciever, Memo);
        return(ProposalID);
    }

    function SignProposal(uint256 ID) public returns(bool Executed){
        require(Signer[msg.sender] == true, "Not Signer");
        require(ProposalSigned[ID][msg.sender] == false, "Already Signed");

        ProposalSigned[ID][msg.sender] = true;
        Proposals[ID].Votes++;

        if(Proposals[ID].Votes == 2){
            ExecuteProposal(ID);
            return(Executed);
        }
        return(false);
    }

    //Proposal Internals and executing


    function ExecuteProposal(uint256 ProposalID) internal{
        uint256 Amount = Proposals[ProposalID].Amount;
        address payable Reciever = Proposals[ProposalID].Reciever;

        if(Proposals[ProposalID].ProposalType == 1){
        require(Amount <= address(this).balance);
        Reciever.transfer(Amount);
        }

        if(Proposals[ProposalID].ProposalType == 2){
        require(Amount <= ERC20(Proposals[ProposalID].ERC20).balanceOf(address(this)));
        ERC20(Proposals[ProposalID].ERC20).transfer(Reciever, Amount);
        }

        emit ProposalExecuted(ProposalID, Amount, Reciever, Proposals[ProposalID].Memo);
    }

    receive() external payable  {
        emit FundsRecieved(msg.value, msg.sender);
    }

}


interface ERC20 {
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool); 
  function totalSupply() external view returns (uint);
}