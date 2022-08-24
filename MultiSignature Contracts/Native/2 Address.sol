//SPDX-License-Identifier:UNLICENSE
pragma solidity ^0.8.7;

contract Multi_Signature{
    //Addresses
    address public SignerOne;
    address public SignerTwo;

    constructor(address _1, address _2){
        SignerOne = _1;
        SignerTwo = _2;
        Signer[_1] = true;
        Signer[_2] = true;
    }
    mapping(address => bool) Signer;
    Proposal[] Proposals;

    //Proposals

    struct Proposal{
        uint256 Amount;
        address payable To;
        string Memo;
    }

    function CreateProposal(uint256 Amount, address payable to, )
    






    //Proposal Voting and executing









    //MultiSig Operations

}