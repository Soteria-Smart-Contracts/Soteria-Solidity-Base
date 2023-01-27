// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.17;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Pets is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 1000000000000000; //Change Before Official Deploy
  uint256 public maxSupply = 1000; 
  uint256 public maxMintAmount = 50; 
  bool public paused = false;

  //Minting Protocol based on Fisher-Yates Shuffle using mapping instead of array
  mapping(uint256 => uint256) public UnMinted;
  uint256 public MaxUnMinted = 1000; //If this we're an array, this would be the equivalent of UnMinted.length


  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    
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

//Airdrop function
   function Airdrop(address Reciever) public returns(bool success){
       require(msg.sender == owner()); 
       uint256 supply = totalSupply();
       require(supply + 1 <= maxSupply);

       RandomMint(Reciever);

       return(success);
   }
  
}
