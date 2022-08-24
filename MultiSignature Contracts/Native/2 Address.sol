//SPDX-License-Identifier:UNLICENSE
pragma solidity ^0.8.7;

contract Multi_Signature{
    //Addresses
    address public SignerOne;
    address public SignerTwo;

    event ProposalCreated(uint256 Amount, address payable Reciever, string Memo);

    constructor(address _1, address _2){
        SignerOne = _1;
        SignerTwo = _2;
        Signer[_1] = true;
        Signer[_2] = true;
    }
    mapping(address => bool) Signer;
    Proposal[] public Proposals;

    //Proposals

    struct Proposal{
        uint256 Amount;
        address payable Reciever;
        string Memo;
        uint256 Votes;
        //2 Votes Needed
    }

    function CreateProposal(uint256 Amount, address payable Reciever, string memory Memo) public returns(bool success){
        require(Signer[msg.sender] == true, "Not Signer");

        Proposal memory NewProposal = Proposal(Amount, Reciever, Memo, 0);

        Proposals.push(NewProposal);
        
        ProposalCreated(Amount, Reciever, Memo);
        return(success);
    }
    

    function ExecuteProposal(uint16 ProposalID) internal{
        uint256 Amount = Proposals[ProposalID].Amount;
        address payable Reciever = Proposals[ProposalID].Reciever;

    }

    //Proposal Voting and executing









    //MultiSig Operations

}