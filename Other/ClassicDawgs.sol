// SPDX-License-Identifier: UNLICENSE
pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ClassicDawgs is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public baseURI;
  address payable public CommunityWallet;
  string public baseExtension = ".json";
  uint256 public cost = 900000000000000000;
  uint256 public maxSupply = 1234; 
  uint256 public maxMintAmount = 20;
  bool public paused = false;


  mapping(uint256 => string) public TokenName;
  mapping(address => bool) public Eligibility;
  mapping(address => uint256) PayoutPercentage;
  mapping(address => uint256) UnclaimedETH;

  //Minting Protocol based on Fisher-Yates Shuffle using mapping instead of array
  mapping(uint256 => uint256) public UnMinted;
  uint256 public MaxUnMinted = 1234; //If this we're an array, this would be the equivalent of UnMinted.length


  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    address payable _CommunityWallet
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    CommunityWallet = _CommunityWallet;
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

    TransferToTreasury();
  }

  function ChangeTokenName(uint256 ID, string memory NewName) public payable returns (bool success){
    require(ownerOf(ID) == msg.sender);
    require(msg.value >= 1 ether);

    TokenName[ID] = NewName;

    TransferToTreasury();
    return(success);
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
          
  function transferContract(address newOwner) public onlyOwner{
    transferOwnership(newOwner);
  }

  function _generateRandom(uint256 num) public view returns (uint256)
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

//Special Request Functions

  function TransferToTreasury() internal{
    CommunityWallet.transfer(address(this).balance);
  }

  function ChangeCommunityWallet(address payable NewAddress) public onlyOwner{
    CommunityWallet = NewAddress;
  }



//Airdrop function
   function Airdrop(address Reciever) public returns(bool success){
       require(msg.sender == owner()); 
       uint256 supply = totalSupply();
       require(supply + 1 <= maxSupply);

       RandomMint(Reciever);

       return(success);
   }

}