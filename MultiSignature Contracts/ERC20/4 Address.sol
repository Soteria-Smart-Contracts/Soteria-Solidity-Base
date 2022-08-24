//SPDX-License-Identifier:UNLICENSE
pragma solidity ^0.8.7;

contract Multi_Signature{
    //Addresses
    address public Token;
    address public SignerOne;
    address public SignerTwo;

    event FundsRecieved(uint256 Amount, address From);
    event ProposalCreated(uint256 Amount, address payable Reciever, string Memo);
    event ProposalExecuted(uint256 Amount, address payable Reciever, string Memo);


    constructor(address token, address _1, address _2, address _3, address _4){
        require(_1 != _2 && _1 != _3 && _2 != _3 && _1 != _4 && _2 != _4 && _3 != _4);
        Token = token;
        SignerOne = _1;
        SignerTwo = _2;
        Signer[_1] = true;
        Signer[_2] = true;
    }
    mapping(address => bool) Signer;
    mapping(uint256 => mapping(address => bool)) ProposalSigned;
    Proposal[] public Proposals;

    //Proposals

    struct Proposal{
        uint256 Amount;
        address payable Reciever;
        string Memo;
        uint256 Votes;
        //2 Votes Needed
    }

    function CreateProposal(uint256 Amount, address payable Reciever, string memory Memo) public returns(uint256 ID){
        require(Signer[msg.sender] == true, "Not Signer");

        Proposal memory NewProposal = Proposal(Amount, Reciever, Memo, 0);

        Proposals.push(NewProposal);
        
        uint256 ProposalID = (Proposals.length - 1);
        emit ProposalCreated(Amount, Reciever, Memo);
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
        require(Amount <= ERC20(Token).balanceOf(address(this)));

        ERC20(Token).transfer(Reciever, Amount);

        emit ProposalExecuted(Amount, Reciever, Proposals[ProposalID].Memo);
    }

    //Fallback Function for when depositing ETC
    receive() external payable  {
        revert();
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