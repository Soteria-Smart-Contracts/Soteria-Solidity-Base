// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.17;

contract BunnyDualStake{
    //Parameters
    address public Operator;
    address public BUNAI; //Bunny AI Token
    address public BNFT; //Bunny AI NFT
    uint256 public NFTBoostMultiplier; //APR Booster in Basis Points
    uint256 public MinimumStake; //The minimum amount of BUNAI needed to create a stake

    //Informational and Updated variables
    uint256 BUNAItobeWithdrawn;

    struct Lock{
        uint256 LockStart; //Unix Time
        uint256 LockEnd; //Unix Time
        uint256 TotalMultiplier;
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
    mapping(LockOptions => uint256) internal LockPayouts;

    //Make events, constructor, etc...
    constructor(){
        LockLenghts[0] = 1209600; //TODO: 10 days
        LockLenghts[1] = 2630000; //TODO: 30 days
        LockLenghts[2] = 7890000; //TODO: 90 days
        LockPayouts[0] = 5000;
        LockPayouts[1] = 10000;
        LockPayouts[2] = 22500;
    }

    //Public Functions
    //Lock BUNAI w/o NFT
    function LockBUNAI(uint256 BUNAI_Amount, LockOptions Type) public returns(bool success){
        require(BUNAI_Amount >= MinimumStake, 'You must stake atleast the minimum stake Amount');
        require(ERC20(BUNAI).transferFrom(msg.sender, address(this), BUNAI_Amount), 'Unable to transfer BUNAI to contract');

        uint256 EndTime = (block.timestamp + LockLenghts[Type]);
        uint256 Payout = ((amount * LockPayouts[Type]) / 10000) + amount;
        require(GetBUNAIAvailable() >= (Payout - BUNAI_Amount), 'The contract does not have enough BUNAI to pay out rewards for this lock');
        UserLocks[msg.sender][LatestUserLock++] = Lock(block.timestamp, EndTime, LockPayouts[Type], BUNAI_Amount, Payout, uint256[]);

        return(success);
    }
    
    //Lock BUNAI w/ NFT
    function LockBUNAIWithNFTs(uint256 BUNAI_Amount, uint256[] calldata NFTs) public returns(bool success){
        require(BUNAI_Amount >= MinimumStake, 'You must stake atleast the minimum stake Amount');
        require(ERC20(BUNAI).transferFrom(msg.sender, address(this), BUNAI_Amount), 'Unable to transfer BUNAI to contract');

        uint256 EndTime = (block.timestamp + LockLenghts[Type]);
        uint256 Payout = ((amount * LockPayouts[Type]) / 10000) + amount;
        require(GetBUNAIAvailable() >= (Payout - BUNAI_Amount), 'The contract does not have enough BUNAI to pay out rewards for this lock');
        UserLocks[msg.sender][LatestUserLock++] = Lock(block.timestamp, EndTime, LockPayouts[Type], BUNAI_Amount, Payout, uint256[]);

        return(success);

    }

    //Add to NFT with existing BUNAI lock
    function AddNFTtoLock(uint256 UserLockID, uint256[] calldata NFTs) public returns(bool success){

    }

    //Claim BUNAILock
    function ClaimLock(uint256 UserLockID) public returns(bool success){

    }

    //Owner Only Functions

    //ChangeBaseAPY (Make sure to set minimum so it doesent fucking explode)

    //Internal Functions

    function TransferInNFTs(uint256[] IDs, address Owner) internal returns(success){
        uint256 index;
        while(index < IDs.length){
            ERC721(BNFT).transferFrom(Owner, address(this))
        }

        return(success);
    }


    //View and calculation functions
    function GetBUNAIAvailable() public view returns(uint256 Available){
        return(BUNAI.balanceOf(address(this)) - BUNAItobeWithdrawn)
    }




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