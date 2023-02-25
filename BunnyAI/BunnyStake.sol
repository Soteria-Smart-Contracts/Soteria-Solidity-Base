// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.17;

contract BunnyDualStake{
    address public Operator;
    ERC20 public BUNAI; //Bunny AI Token
    ERC721 public BNFT; //Bunny AI NFT
    uint256 public BaseAPR;
    

    struct Lock{
        uint256 LockStart; //Unix Time
        uint256 LockEnd; //Unix Time
        uint256 BUNAI_Locked;
        uint256 BUNAI_Payout;
        uint256[] BNFTs_Boosting;
    }

    //Public Functions
    //Lock BUNAI w/o NFT
    
    //Lock BUNAI w/ NFT

    //Add to NFT with existing BUNAI lock

    //Claim BUNAILock

    //Owner Only Functions

    //ChangeBaseAPY (Make sure to set minimum so it doesent fucking explode)





}

interface ERC721{
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function walletOfOwner(address owner) external view returns (uint256[] memory);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface ERC20 {
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint value) external returns (bool);
  function Mint(address _MintTo, uint256 _MintAmount) external;
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool); 
  function totalSupply() external view returns (uint);
} 