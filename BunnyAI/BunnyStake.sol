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
    uint256 public BUNAItobeWithdrawn;
    uint256[] internal EmptyArray;

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
    mapping(address => uint256[]) public UserLockList;
    mapping(address => uint256) internal LatestUserLock;
    mapping(LockOptions => uint256) internal LockLengths;
    mapping(LockOptions => uint256) internal LockPayouts;

    //Make events, constructor, etc...
    constructor(){
        LockLengths[LockOptions(0)] = 864000; //TODO: 10 days
        LockLengths[LockOptions(1)] = 2592000; //TODO: 30 days
        LockLengths[LockOptions(2)] = 7776000; //TODO: 90 days
        LockPayouts[LockOptions(0)] = 5000;
        LockPayouts[LockOptions(1)] = 10000;
        LockPayouts[LockOptions(2)] = 22500;
    }

    //Public Functions
    //Lock BUNAI w/o NFT
    function LockBUNAI(uint256 BUNAI_Amount, LockOptions Type) public returns(bool success){
        require(BUNAI_Amount >= MinimumStake, 'You must stake atleast the minimum stake Amount');
        require(ERC20(BUNAI).transferFrom(msg.sender, address(this), BUNAI_Amount), 'Unable to transfer BUNAI to contract');

        uint256 EndTime = (block.timestamp + LockLengths[Type]);
        uint256 Payout = ((BUNAI_Amount * LockPayouts[Type]) / 10000) + BUNAI_Amount;
        require(GetBUNAIAvailable() >= (Payout - BUNAI_Amount), 'The contract does not have enough BUNAI to pay out rewards for this lock');
        UserLocks[msg.sender][LatestUserLock[msg.sender]++] = Lock(block.timestamp, EndTime, LockPayouts[Type], BUNAI_Amount, Payout, EmptyArray);

        return(success);
    }
    
    //Lock BUNAI w/ NFT
    function LockBUNAIWithNFTs(uint256 BUNAI_Amount, LockOptions Type, uint256[] calldata NFTs) public returns(bool success){
        require(BUNAI_Amount >= MinimumStake, 'You must stake atleast the minimum stake Amount');
        require(ERC20(BUNAI).transferFrom(msg.sender, address(this), BUNAI_Amount), 'Unable to transfer BUNAI to contract');
        require(NFTs.length <= 10, 'Maximum number of boosting NFTs is 10');
        require(TransferInNFTs(NFTs, msg.sender), 'Unable to transfer NFTs to contract');

        uint256 EndTime = (block.timestamp + LockLengths[Type]);
        uint256 BoostedPayoutMultiplier = LockPayouts[Type] + (NFTBoostMultiplier * NFTs.length);
        uint256 Payout = ((BUNAI_Amount * BoostedPayoutMultiplier) / 10000) + BUNAI_Amount;
        require(GetBUNAIAvailable() >= (Payout - BUNAI_Amount), 'The contract does not have enough BUNAI to pay out rewards for this lock');
        UserLocks[msg.sender][LatestUserLock[msg.sender]++] = Lock(block.timestamp, EndTime, BoostedPayoutMultiplier, BUNAI_Amount, Payout, NFTs);

        return(success);

    }

    //Add to NFT with existing BUNAI lock
    function AddNFTtoLock(uint256 UserLockID, uint256[] calldata NFTs) public returns(bool success){
        require((UserLocks[msg.sender][UserLockID].BNFTs_Boosting.length + NFTs.length) <= 10, 'Cannot boost with more than 10 NFTs per lock');
        require(TransferInNFTs(NFTs, msg.sender), 'Unable to transfer NFTs to contract');

        UpdateBoostList(UserLockID, NFTs);
        uint256 BoostedPayoutMultiplier =  UserLocks[msg.sender][UserLockID]. + (NFTBoostMultiplier * NFTs.length);

        return(success);
    }

    //Claim BUNAILock
    function ClaimLock(uint256 UserLockID) public returns(bool success){

    }

    //Owner Only Functions

    //TODO: ChangePayoutMultipliers (Make sure to set minimum so it doesent fucking explode)
    //TODO: ChangeNFTBoostMultiplier
    //TODO: SetNewOperator

    //Internal Functions

    function TransferInNFTs(uint256[] calldata IDs, address Owner) internal returns(bool success){
        uint256 index;
        while(index < IDs.length){
            ERC721(BNFT).transferFrom(Owner, address(this), IDs[index]);
            index++;
        }

        return(success);
    }

    function UpdateBoostList(uint256 UserLockID, uint256[] calldata NFTs) internal returns(bool success){
        uint256 index;
        while(index < NFTs.length){
            UserLocks[msg.sender][UserLockID].BNFTs_Boosting.push(NFTs[index]); 
            index++;
        }

        return(success);
    }


    //View and calculation functions
    function GetBUNAIAvailable() public view returns(uint256 Available){
        return(ERC20(BUNAI).balanceOf(address(this)) - BUNAItobeWithdrawn);
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