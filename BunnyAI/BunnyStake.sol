// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.17;

contract BunnyDualStake{
    address public Operator;
    ERC20 public BUNAI; //Bunny AI Token
    ERC721 public BNFT; //Bunny AI NFT
    uint256 public BaseAPR; //The base APR yearly in %
    uint256 public SecondsAPR; //The base APR per second in BUNAI
    uint256 public NFTBoostMultiplier; //APR Booster in Basis Points
    uint256 public MinimumStake; //The minimum amount of BUNAI needed to create a stake

    struct Lock{
        uint256 LockStart; //Unix Time
        uint256 LockEnd; //Unix Time
        uint256 BUNAI_Locked;
        uint256 BUNAI_Payout;
        uint256[] BNFTs_Boosting;
    }

    enum LockOptions{
        TwoWeeks,
        OneMonth,
        ThreeMonths
    }

    mapping(address => mapping(uint256 => Lock)) public UserLocks;
    mapping(address => uint256) internal LatestUserLock;
    mapping(LockOptions => uint256) internal LockLengths;

    //Make events, constructor, etc...
    constructor(){
        LockLenghts[0] = 1209600;
        LockLenghts[0] = 1209600;
    }

    //Public Functions
    //Lock BUNAI w/o NFT
    function LockBUNAI(uint256 BUNAI_Amount, LockOptions Length) public returns(bool success){
        require(BUNAI_Amount >= MinimumStake, 'You must stake atleast the minimum stake Amount');
        require(BUNAI.transferFrom(msg.sender, address(this), BUNAI_Amount), 'Unable to transfer BUNAI to contract');

        uint256 EndTime = (block.timestamp + LockLenghts[Length]);
        UserLocks[msg.sender][LatestUserLock++] = Lock()

        return(success);
    }
    
    //Lock BUNAI w/ NFT
    function LockBUNAIWithNFTs(uint256 BUNAI_Amount, uint256[] calldata NFTs) public returns(bool success){

    }

    //Add to NFT with existing BUNAI lock
    function AddNFTtoLock(uint256 UserLockID, uint256[] calldata NFTs) public returns(bool success){

    }

    //Claim BUNAILock
    function ClaimLock(uint256 UserLockID) public returns(bool success){

    }

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