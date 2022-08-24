//SPDX-License-Identifier:UNLICENSE
pragma solidity ^0.8.7;

contract Multi_Signature{
    //Addresses
    address public SignerOne;
    address public SignerTwo;

    constructor(address _1, address _2){
        SignerOne = _1;
        SignerTwo = _2;
    }

    Proposal[] Proposals;
    mapping 

    //Proposals

    struct Proposal{
        uint256 Amount;
        address To;
        string Memo;
    }






    //Proposal Voting and executing









    //MultiSig Operations

}