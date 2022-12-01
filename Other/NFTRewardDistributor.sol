// SPDX-License-Identifier: UNLICENSE
//This contract uses ERC721 tokens to verify the ownership of rewards before transfer
//Created by SoteriaSC for ShibaClassic/ClassicDawgs but is open-source
pragma solidity >=0.7.0 <0.9.0;

contract NFTRewardDistributor{
    //Variable Declarations
    uint256 TotalTokens;
    address NFTcontract;

    //Mapping, structs, enums and other declarations
    mapping(uint256 => uint256) LatestClaim;

    struct RewardInstance{
        uint256 TotalEtherReceived;
        uint256 EtherReward;
        
    }

    //On Deploy code to run (Constructor)
    constructor(address _NFTcontract){
        NFTcontract = _NFTcontract;
    }
}