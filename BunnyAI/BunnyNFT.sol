// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.17;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BunnyDualStake{
    //Parameters
    address public Operator;
    address public BUNAI; //Bunny AI Token
    address public BNFT; //Bunny AI NFT
    uint256 public NFTBoostMultiplier; //APR Booster in Basis Points
    uint256 public MinimumStake; //The minimum amount of BUNAI needed to create a stake

    //Informational and Updated variables
    uint256 public BUNAItobeWithdrawn; //Can be used as total locked
    uint256[] internal EmptyArray;

    struct Lock{
        uint256 LockStart; //Unix Time
        uint256 LockEnd; //Unix Time
        bool Claimed;
        uint256 TotalMultiplier;
        uint256 BUNAI_Locked;
        uint256 BUNAI_Payout;
        uint256[] BNFTs_Boosting;
    }

    enum LockOptions{
        TenDays,
        ThirtyDays,
        NinetyDays
    }

    mapping(address => mapping(uint256 => Lock)) public UserLocks;
    mapping(address => uint256[]) public UserLockList;

    mapping(address => mapping(uint256 => uint256)) internal ListIndex;
    mapping(address => uint256) internal LatestUserLock;
    mapping(LockOptions => uint256) internal LockLengths;
    mapping(LockOptions => uint256) internal LockPayouts;

    //Make events, constructor, etc...
    constructor(){
        LockLengths[LockOptions(0)] = 864000; // 10 days
        LockLengths[LockOptions(1)] = 2592000; // 30 days
        LockLengths[LockOptions(2)] = 7776000; // 90 days
        LockPayouts[LockOptions(0)] = 137;
        LockPayouts[LockOptions(1)] = 821;
        LockPayouts[LockOptions(2)] = 5547;
    }

    //Public Functions
    //Lock BUNAI w/o NFT
    function LockBUNAI(uint256 BUNAI_Amount, LockOptions Type) public returns(bool success){
        require(BUNAI_Amount >= MinimumStake, 'You must stake atleast the minimum stake Amount');
        require(ERC20(BUNAI).transferFrom(msg.sender, address(this), BUNAI_Amount), 'Unable to transfer BUNAI to contract');

        uint256 EndTime = (block.timestamp + LockLengths[Type]);
        uint256 Payout = ((BUNAI_Amount * LockPayouts[Type]) / 10000) + BUNAI_Amount;
        require(GetBUNAIAvailable() >= (Payout - BUNAI_Amount), 'The contract does not have enough BUNAI to pay out rewards for this lock');
        UserLocks[msg.sender][LatestUserLock[msg.sender]++] = Lock(block.timestamp, EndTime, false, LockPayouts[Type], BUNAI_Amount, Payout, EmptyArray);
        LatestUserLock[msg.sender]++;
        BUNAItobeWithdrawn += Payout;

        UserLockList[msg.sender].push(LatestUserLock[msg.sender]);
        ListIndex[msg.sender][LatestUserLock[msg.sender]] = (UserLockList[msg.sender].length - 1);

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
        UserLocks[msg.sender][LatestUserLock[msg.sender]++] = Lock(block.timestamp, EndTime, false, BoostedPayoutMultiplier, BUNAI_Amount, Payout, NFTs);
        LatestUserLock[msg.sender]++;
        BUNAItobeWithdrawn += Payout;

        UserLockList[msg.sender].push(LatestUserLock[msg.sender]);
        ListIndex[msg.sender][LatestUserLock[msg.sender]] = (UserLockList[msg.sender].length - 1);

        return(success);
    }

    //Add to NFT with existing BUNAI lock
    function AddNFTtoLock(uint256 UserLockID, uint256[] calldata NFTs) public returns(bool success){
        require((UserLocks[msg.sender][UserLockID].BNFTs_Boosting.length + NFTs.length) <= 10, 'Cannot boost with more than 10 NFTs per lock');
        require(TransferInNFTs(NFTs, msg.sender), 'Unable to transfer NFTs to contract');

        UpdateBoostList(UserLockID, NFTs);
        uint256 BoostedPayoutMultiplier =  UserLocks[msg.sender][UserLockID].TotalMultiplier + (NFTBoostMultiplier * NFTs.length);
        uint256 NewPayout = ((UserLocks[msg.sender][UserLockID].BUNAI_Locked * BoostedPayoutMultiplier) / 10000) + UserLocks[msg.sender][UserLockID].BUNAI_Locked;
        UserLocks[msg.sender][UserLockID].BUNAI_Payout = NewPayout;
        UserLocks[msg.sender][UserLockID].TotalMultiplier = BoostedPayoutMultiplier;

        return(success);
    }

    //Claim BUNAILock
    function ClaimLock(uint256 UserLockID) public returns(bool success){
        require(UserLocks[msg.sender][UserLockID].LockEnd <= block.timestamp, 'This lock is still active and it is too early to claim it');
        require(UserLocks[msg.sender][UserLockID].Claimed == false);

        uint256 Payout = UserLocks[msg.sender][UserLockID].BUNAI_Payout;
        uint256[] memory NFTsToTransfer = UserLocks[msg.sender][UserLockID].BNFTs_Boosting;
        UserLocks[msg.sender][UserLockID].Claimed = true;
        UserLocks[msg.sender][UserLockID].BUNAI_Payout = 0;
        UserLocks[msg.sender][UserLockID].BNFTs_Boosting = EmptyArray;

        TransferOutNFTs(NFTsToTransfer, msg.sender);
        ERC20(BUNAI).transfer(msg.sender, Payout);
        BUNAItobeWithdrawn -= Payout;

        UserLockList[msg.sender][ListIndex[msg.sender][UserLockID]] = UserLockList[msg.sender][(UserLockList[msg.sender].length - 1)];
        UserLockList[msg.sender].pop();

        return(success);
    }

    //Owner Only Functions

    function SetNewPayoutMultiplier(LockOptions OptionToChange, uint256 NewPercentage) public {
        require(msg.sender == Operator);
        LockPayouts[OptionToChange] = NewPercentage;
    }
    function ChangeNFTBoostMultiplier(uint256 NewMultiplier) public {
        require(msg.sender == Operator);
        NFTBoostMultiplier = NewMultiplier;
    }

    function SetNewOperator(address NewOperator) public {
        require(msg.sender == Operator);
        Operator = NewOperator;
    }

    //Internal Functions

    function TransferInNFTs(uint256[] calldata IDs, address Owner) internal returns(bool success){
        uint256 index;
        while(index < IDs.length){
            ERC721(BNFT).transferFrom(Owner, address(this), IDs[index]);
            index++;
        }
        return(success);
    }
    function TransferOutNFTs(uint256[] memory IDs, address Owner) internal returns(bool success){
        uint256 index;
        while(index < IDs.length){
            ERC721(BNFT).transferFrom(address(this), Owner, IDs[index]);
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

    function AllUserLocks(address User) public view returns(uint256[] memory Locks){
        return(UserLockList[User]);
    }



}

contract BUNAInft is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0; 
  uint256 public maxSupply = 500; 
  uint256 public maxMintAmount = 25; 
  bool public paused = false;

  //Minting Protocol based on Fisher-Yates Shuffle using mapping instead of array
  mapping(uint256 => uint256) public UnMinted;
  uint256 public MaxUnMinted = 500; //If this we're an array, this would be the equivalent of UnMinted.length


  constructor() ERC721("Hopper", "HOP") {
    setBaseURI("ipfs://REPLACE/");
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(uint256 _mintQuantity) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintQuantity > 0);
    require(_mintQuantity <= maxMintAmount);
    require(supply + _mintQuantity <= maxSupply);

    if (msg.sender != owner()) {
      require(msg.value >= cost * _mintQuantity);
    }

    for (uint256 i = 1; i <= _mintQuantity; i++) {
      RandomMint(msg.sender);
    }
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner

  
  function setCost(uint256 _newCost) public onlyOwner() {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }


  function transferContract(address newOwner) public onlyOwner{
    transferOwnership(newOwner);
  }

  function _generateRandom(uint256 num) internal view returns (uint256)
  {
       uint256 random;
        
       random = uint256(keccak256
        (abi.encodePacked(block.timestamp, msg.sender, num))) 
        % MaxUnMinted;

        return random;

  }

  function RandomMint(address to) internal returns(bool success){
    uint256 RandomNumber = _generateRandom(MaxUnMinted);

    if(RandomNumber == 0){
      RandomNumber = 1;
    }

    if(UnMinted[RandomNumber] == 0 && RandomNumber == MaxUnMinted){
      _safeMint(to, RandomNumber);
      --MaxUnMinted;
      return(success);
    }

    if(UnMinted[RandomNumber] == 0){
      _safeMint(to, RandomNumber);
      if(UnMinted[MaxUnMinted] == 0){
      UnMinted[RandomNumber] = MaxUnMinted;
      --MaxUnMinted;
      }
      else{
        UnMinted[RandomNumber] = UnMinted[MaxUnMinted];
        --MaxUnMinted;
      }
    }
    else{
      _safeMint(to, UnMinted[RandomNumber]);
      if(UnMinted[MaxUnMinted] == 0){
      UnMinted[RandomNumber] = MaxUnMinted;
      --MaxUnMinted;
      }
      else{
        UnMinted[RandomNumber] = UnMinted[MaxUnMinted];
        --MaxUnMinted;
      }
    }
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

