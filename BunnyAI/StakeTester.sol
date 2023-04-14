// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.17;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakeTester{
    address public DualStake;
    address public Token;
    address public NFT;
    
    constructor(){
        Token = address(new TokenContract(100000000000000000000000, 'TestBUNAI', 'TBN'));
        NFT = address(new NFTContract());
        DualStake = address(new BunnyDualStake(Token));
        ERC20(Token).transfer(DualStake, 25000000000000000000000);
        ERC20(Token).transfer(msg.sender, 75000000000000000000000);
        NFTContract(NFT).mint(10);
        uint256 index;
        uint256[] memory NFTs = NFTContract(NFT).walletOfOwner(address(this));
        while(index < NFTs.length){
            NFTContract(NFT).transferFrom(address(this), msg.sender, NFTs[index]);
            index++;
        }
    }

}

contract BunnyDualStake{
    //Parameters
    address public Operator = 0xc932b3a342658A2d3dF79E4661f29DfF6D7e93Ce;
    address public BUNAI; //Bunny AI Token
    address public BNFT; //Bunny AI NFT
    bool public BNFT_set = false;
    uint256 public NFTBoostMultiplier = 500; //APR Booster in Basis Points
    uint256 public MinimumStake = 100000000000000000000; //The minimum amount of BUNAI needed to create a stake

    //Informational and Updated variables
    uint256 public BUNAItobeWithdrawn; //Can be used as total locked
    uint256[] internal EmptyArray;

    struct Lock{
        LockOptions Type;
        uint256 LockStart; //Unix Time
        uint256 LockEnd; //Unix Time
        bool Claimed;
        uint256 TotalMultiplier;
        uint256 BUNAI_Locked;
        uint256 BUNAI_Payout;
        uint256[] BNFTs_Boosting;
    }

    enum LockOptions{  
        TenDays, //0
        ThirtyDays, //1
        NinetyDays //2
    }

    mapping(address => mapping(uint256 => Lock)) public UserLocks;
    mapping(address => uint256[]) public UserLockList;

    mapping(address => mapping(uint256 => uint256)) internal ListIndex;
    mapping(address => uint256) internal LatestUserLock;
    mapping(LockOptions => uint256) internal LockLengths;
    mapping(LockOptions => uint256) internal LockPayouts;

    //Make events, constructor, etc...
    constructor(address _BUNAI){
        BUNAI = _BUNAI;
        LockLengths[LockOptions(0)] = 180; // 10 days
        LockLengths[LockOptions(1)] = 180; // 30 days 
        LockLengths[LockOptions(2)] = 180; // 90 days 
        LockPayouts[LockOptions(0)] = 13700; //1.37%
        LockPayouts[LockOptions(1)] = 82100; //8.21%
        LockPayouts[LockOptions(2)] = 554700;//55.47%
    }

    event BUNAILocked(uint256 amount, LockOptions Type, address User, uint256 ID);
    event NFTBoost(uint256[] NFTs, address User, uint256 ID);
    event LockClaimed(uint256 TotalPayout, address User, uint256 ID);
    event LockClaimedEarly(uint256 TotalPayout, address User, uint256 ID);
    event NewOperatorSet(address NewOperator);
    event NewNFTBoostMultiplierSet(uint256 NewMultiplier);
    event BNFTset(address BNFT);
    event TypePayoutChanged(uint256 NewMultiplier, LockOptions Type);


    //Public Functions
    //Lock BUNAI w/o NFT
    function LockBUNAI(uint256 BUNAI_Amount, LockOptions Type) public returns(bool success){
        require(BUNAI_Amount >= MinimumStake, 'You must stake atleast the minimum stake Amount');
        LatestUserLock[msg.sender]++;

        uint256 EndTime = (block.timestamp + LockLengths[Type]);
        uint256 Payout = ((BUNAI_Amount * LockPayouts[Type]) / 1000000) + BUNAI_Amount;
        require(GetBUNAIAvailable() >= (Payout - BUNAI_Amount), 'The contract does not have enough BUNAI to pay out rewards for this lock');
        UserLocks[msg.sender][LatestUserLock[msg.sender]] = Lock(Type, block.timestamp, EndTime, false, LockPayouts[Type], BUNAI_Amount, Payout, EmptyArray);
        BUNAItobeWithdrawn += Payout;
        require(ERC20(BUNAI).transferFrom(msg.sender, address(this), BUNAI_Amount), 'Unable to transfer BUNAI to contract');

        UserLockList[msg.sender].push(LatestUserLock[msg.sender]);
        ListIndex[msg.sender][LatestUserLock[msg.sender]] = (UserLockList[msg.sender].length - 1);

        emit BUNAILocked(BUNAI_Amount, Type, msg.sender, LatestUserLock[msg.sender]);
        return(success);
    }
    
    //Lock BUNAI w/ NFT
    function LockBUNAIWithNFTs(uint256 BUNAI_Amount, LockOptions Type, uint256[] calldata NFTs) public returns(bool success){
        require(BNFT_set);
        require(BUNAI_Amount >= MinimumStake, 'You must stake atleast the minimum stake Amount');
        require(NFTs.length <= 10 && NFTs.length > 0, 'Maximum number of boosting NFTs is 10 and minimum is 1');
        TransferInNFTs(NFTs, msg.sender);
        LatestUserLock[msg.sender]++;

        uint256 EndTime = (block.timestamp + LockLengths[Type]);
        uint256 BoostedPayoutMultiplier = (LockPayouts[Type] * (NFTBoostMultiplier * NFTs.length) / 10000) + LockPayouts[Type];
        uint256 Payout = ((BUNAI_Amount * BoostedPayoutMultiplier) / 1000000) + BUNAI_Amount;
        require(GetBUNAIAvailable() >= (Payout - BUNAI_Amount), 'The contract does not have enough BUNAI to pay out rewards for this lock');
        UserLocks[msg.sender][LatestUserLock[msg.sender]] = Lock(Type, block.timestamp, EndTime, false, BoostedPayoutMultiplier, BUNAI_Amount, Payout, NFTs);
        BUNAItobeWithdrawn += Payout;
        require(ERC20(BUNAI).transferFrom(msg.sender, address(this), BUNAI_Amount), 'Unable to transfer BUNAI to contract');

        UserLockList[msg.sender].push(LatestUserLock[msg.sender]);
        ListIndex[msg.sender][LatestUserLock[msg.sender]] = (UserLockList[msg.sender].length - 1);

        emit BUNAILocked(BUNAI_Amount, Type, msg.sender, LatestUserLock[msg.sender]);
        emit NFTBoost(NFTs, msg.sender, LatestUserLock[msg.sender]);
        return(success);
    }

    //Add to NFT with existing BUNAI lock
    function AddNFTtoLock(uint256 UserLockID, uint256[] calldata NFTs) public returns(bool success){
        require(BNFT_set);
        require((UserLocks[msg.sender][UserLockID].BNFTs_Boosting.length + NFTs.length) <= 10, 'Cannot boost with more than 10 NFTs per lock');
        require(UserLocks[msg.sender][UserLockID].LockEnd > block.timestamp, 'Cannot boost completed lock');
        TransferInNFTs(NFTs, msg.sender);
        UpdateBoostList(UserLockID, NFTs);
        uint256 OldPayout = UserLocks[msg.sender][UserLockID].BUNAI_Payout;

        uint256 BoostedPayoutMultiplier = (LockPayouts[(UserLocks[msg.sender][UserLockID].Type)] * (NFTBoostMultiplier * UserLocks[msg.sender][UserLockID].BNFTs_Boosting.length) / 10000) + LockPayouts[(UserLocks[msg.sender][UserLockID].Type)];
        uint256 NewPayout = ((UserLocks[msg.sender][UserLockID].BUNAI_Locked * BoostedPayoutMultiplier) / 1000000) + UserLocks[msg.sender][UserLockID].BUNAI_Locked;
        require(GetBUNAIAvailable() >= (NewPayout - OldPayout), 'The contract does not have enough BUNAI to pay out rewards for this lock');
        UserLocks[msg.sender][UserLockID].BUNAI_Payout = NewPayout;
        UserLocks[msg.sender][UserLockID].TotalMultiplier = BoostedPayoutMultiplier;

        BUNAItobeWithdrawn += (NewPayout - OldPayout);

        emit NFTBoost(NFTs, msg.sender, UserLockID);
        return(success);
    }

    //Claim BUNAILock
    function ClaimLock(uint256 UserLockID) public returns(bool success){
        require(UserLocks[msg.sender][UserLockID].LockEnd <= block.timestamp && UserLocks[msg.sender][UserLockID].LockEnd != 0, 'This lock is still active and it is too early to claim it');
        require(UserLocks[msg.sender][UserLockID].Claimed == false);

        uint256 Payout = UserLocks[msg.sender][UserLockID].BUNAI_Payout;
        uint256[] memory NFTsToTransfer = UserLocks[msg.sender][UserLockID].BNFTs_Boosting;
        UserLocks[msg.sender][UserLockID].Claimed = true;
        UserLocks[msg.sender][UserLockID].BUNAI_Payout = 0;
        UserLocks[msg.sender][UserLockID].BNFTs_Boosting = EmptyArray;

        TransferOutNFTs(NFTsToTransfer, msg.sender);
        BUNAItobeWithdrawn -= Payout;
        ERC20(BUNAI).transfer(msg.sender, Payout);

        if(UserLockList[msg.sender][UserLockList[msg.sender].length - 1] != UserLockID){
            UserLockList[msg.sender][ListIndex[msg.sender][UserLockID]] = UserLockList[msg.sender][(UserLockList[msg.sender].length - 1)];
        }
        UserLockList[msg.sender].pop();

        emit LockClaimed(Payout, msg.sender, UserLockID);
        return(success);
    }

    function EarlyClaimLock(uint256 UserLockID) public returns(bool success){
        require(UserLocks[msg.sender][UserLockID].LockEnd > block.timestamp && UserLocks[msg.sender][UserLockID].LockEnd != 0, 'This lock can be claimed regularly, withought taking a penalty and receiving rewards');
        require(UserLocks[msg.sender][UserLockID].Claimed == false);

        BUNAItobeWithdrawn -= UserLocks[msg.sender][UserLockID].BUNAI_Payout;

        uint256 Payout = (UserLocks[msg.sender][UserLockID].BUNAI_Locked * 95) / 100;
        uint256[] memory NFTsToTransfer = UserLocks[msg.sender][UserLockID].BNFTs_Boosting;
        UserLocks[msg.sender][UserLockID].Claimed = true;
        UserLocks[msg.sender][UserLockID].BUNAI_Payout = 0;
        UserLocks[msg.sender][UserLockID].BNFTs_Boosting = EmptyArray;

        TransferOutNFTs(NFTsToTransfer, msg.sender);
        ERC20(BUNAI).transfer(msg.sender, Payout);

        if(UserLockList[msg.sender][UserLockList[msg.sender].length - 1] != UserLockID){
            UserLockList[msg.sender][ListIndex[msg.sender][UserLockID]] = UserLockList[msg.sender][(UserLockList[msg.sender].length - 1)];
        }
        UserLockList[msg.sender].pop();

        emit LockClaimedEarly(Payout, msg.sender, UserLockID);
        return(success);
    }

    //Owner Only Functions

    function SetNewPayoutMultiplier(LockOptions OptionToChange, uint256 NewPercentage) public {
        require(msg.sender == Operator);
        LockPayouts[OptionToChange] = NewPercentage;
        emit TypePayoutChanged(NewPercentage, OptionToChange);
    }
    function ChangeNFTBoostMultiplier(uint256 NewMultiplier) public {
        require(msg.sender == Operator);
        NFTBoostMultiplier = NewMultiplier;
        emit NewNFTBoostMultiplierSet(NewMultiplier);
    }

    function SetBNFTcontract(address BNFTtoSet) public {
        require(msg.sender == Operator);
        require(!BNFT_set);

        BNFT_set = true;

        BNFT = BNFTtoSet;
        emit BNFTset(BNFT);
    }

    function SetNewOperator(address NewOperator) public {
        require(msg.sender == Operator);
        Operator = NewOperator;
        emit NewOperatorSet(NewOperator);
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


contract TokenContract {
    uint256 public TokenCap;
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    address private ZeroAddress;
    //variable Declarations
    

    event Transfer(address indexed from, address indexed to, uint256 value);    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event BurnEvent(address indexed burner, uint256 indexed buramount);
    event ManageMinterEvent(address indexed newminter);
    //Event Declarations 
    
    mapping(address => uint256) public balances;

    mapping(address => mapping (address => uint256)) public allowance;
    
    constructor(uint256 _TokenCap, string memory _name, string memory _symbol){
        TokenCap = _TokenCap;
        totalSupply = 0;
        name = _name;
        symbol = _symbol;
        decimals = 18;
        Mint(msg.sender, _TokenCap);
    }
    
    
    
    function balanceOf(address _Address) public view returns (uint256 balance){
        return balances[_Address];
    }

    function approve(address delegate, uint _amount) public returns (bool) {
        allowance[msg.sender][delegate] = _amount;
        emit Approval(msg.sender, delegate, _amount);
        return true;
    }
    //Approves an address to spend your coins

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(_amount <= balances[_from]);    
        require(_amount <= allowance[_from][msg.sender]);
    
        balances[_from] = balances[_from]-(_amount);
        allowance[_from][msg.sender] = allowance[_from][msg.sender]-(_amount);
        balances[_to] = balances[_to]+(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }
    //Transfer From an other address


    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-(_amount);
        balances[_to] = balances[_to]+(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }


    function Mint(address _MintTo, uint256 _MintAmount) internal {
        require (totalSupply+(_MintAmount) <= TokenCap);
        balances[_MintTo] = balances[_MintTo]+(_MintAmount);
        totalSupply = totalSupply+(_MintAmount);
        ZeroAddress = 0x0000000000000000000000000000000000000000;
        emit Transfer(ZeroAddress ,_MintTo, _MintAmount);
    } //Can only be used on deploy, view Internal 


    function Burn(uint256 _BurnAmount) public {
        require (balances[msg.sender] >= _BurnAmount);
        balances[msg.sender] = balances[msg.sender]-(_BurnAmount);
        totalSupply = totalSupply-(_BurnAmount);
        ZeroAddress = 0x0000000000000000000000000000000000000000;
        emit Transfer(msg.sender, ZeroAddress, _BurnAmount);
        emit BurnEvent(msg.sender, _BurnAmount);
        
    }

}


contract NFTContract is ERC721Enumerable, Ownable {
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

    // if (msg.sender != owner()) {
    //   require(msg.value >= cost * _mintQuantity);
    // }

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


interface ERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint value) external returns (bool);
    function Mint(address _MintTo, uint256 _MintAmount) external;
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool); 
    function totalSupply() external view returns (uint);
} 

 