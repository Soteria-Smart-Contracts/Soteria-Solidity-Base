// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract ClassicArt is ERC721, IERC721Receiver, Ownable, ReentrancyGuard, ERC721URIStorage, ERC721Enumerable  {

    constructor() ERC721("ClassicArt", "CLA") {
      commissionFunds = payable(0xDAba19446a60f747B56b5ae80305754171bb20E7);
    }

    address payable internal commissionFunds;
    address constant public savageContractAddress = 0x7f6a79C85E5eaEb16e4a7993A53d098bEE6184e5;

    //normal sales
    uint256 commissionNumerator = 3;
    uint256 commissionDenominator = 100;
    uint256 commission = 100 * commissionNumerator / commissionDenominator; // 3%
    uint256 saleNumerator = 97;
    uint256 saleDenominator = 100;
    uint256 salePercentage = 100 * saleNumerator / saleDenominator; // 97%

    uint256 public ItemIds;
    uint256 public ItemsSold;
    uint256 public TokenIds;

    uint256 amountSold = 0;

    struct Bid {
        bool hasBid;
        uint256 index;
        address bidder;
        uint256 value;
    }

    struct MarketItem {
      uint timeListed;
      uint timeSold;
      uint itemId;
      address nftContract;
      uint256 tokenId;
      address payable creator;
      address payable owner;
      uint256 sellingPriceOne;
      uint256 price;
      string name;
      bool listed;
      bool deprecated;
    }

    mapping(uint256 => MarketItem) public MarketItems;
    mapping (uint256 => Bid) public bids;
    mapping(address => bool) public approvedcontract;
    mapping(address => uint256[]) public contractIds;
    mapping(address => uint256[]) public userIds;


    function getContractIdsLength(address project) public view returns(uint256){
        require(approvedcontract[project] == true);
        return(contractIds[project].length);
    }

    function getUserIdLength() public view returns(uint256){
      return(userIds[msg.sender].length);
    }


    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) public override returns(bytes4) {
       return 0x150b7a02;
     }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function unlistMarketItem(uint256 itemId) public { //CHECK
      require(msg.sender == MarketItems[itemId].owner);
      // reset market item status and price
      MarketItems[itemId].listed = false;
      MarketItems[itemId].timeListed = 0;
      MarketItems[itemId].price = 0;

      // refund any existing bid for nft
      Bid memory existing = bids[itemId];
      address existingBidder = existing.bidder;
      if (existing.value > 0) {
          // Refund the lower bid to previous bidder
          (bool success,) = existingBidder.call{value: existing.value}("");
          require(success);
      }

      bids[itemId] = Bid(false, itemId, address(0), 0);

      // transfer token back to user
      IERC721(MarketItems[itemId].nftContract).safeTransferFrom(address(this), msg.sender, MarketItems[itemId].tokenId);
    }

    function relistMarketItem( //CHECK
      uint256 itemId,
      uint256 price
    ) public nonReentrant {
      require(price > 0, "Price must be greater than 0");
      MarketItems[itemId].owner = payable(msg.sender);

      MarketItems[itemId].timeListed = block.timestamp;
      MarketItems[itemId].listed = true;
      MarketItems[itemId].price = price;

      IERC721(MarketItems[itemId].nftContract).safeTransferFrom(msg.sender, address(this), MarketItems[itemId].tokenId);
    }

    /* Places an item for sale on the marketplace */
    function createMarketItem( //CHECK
      address nftContract,
      uint256 tokenId,
      uint256 price,
      string memory name
    ) public nonReentrant {
      require(price > 0, "Price must be greater than 0");
      require(approvedcontract[nftContract] == true);


      ItemIds = ItemIds + 1;


      MarketItems[ItemIds] =  MarketItem(
        block.timestamp,
        0,
        ItemIds,
        nftContract,
        tokenId,
        payable(msg.sender),
        payable(msg.sender),
        0,
        price,
        name,
        true,
        false
      );

      // transfer token to contract
      IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);
      contractIds[nftContract].push(ItemIds);
      userIds[msg.sender].push(ItemIds);
    }

    function removeMarketItem( //CHECK
      uint256 itemId
    ) onlyOwner public {

      MarketItems[itemId].listed = false;
      MarketItems[itemId].timeListed = 0;
      MarketItems[itemId].deprecated = true;

      Bid memory existing = bids[itemId];
      address existingBidder = existing.bidder;
      if (existing.value > 0) {
          // Refund the lower bid to previous bidder
          (bool success,) = existingBidder.call{value: existing.value}("");
          require(success);
      }

      bids[itemId] = Bid(false, itemId, address(0), 0);

      // transfer token back to user
      IERC721(MarketItems[itemId].nftContract).safeTransferFrom(address(this), MarketItems[itemId].owner, MarketItems[itemId].tokenId);
    }

  /* Creates the sale of a marketplace item */
  /* Transfers ownership of the item, as well as funds between parties */
  function createMarketSale( //CHECK
    uint256 itemId
    ) public payable nonReentrant {
    uint price = MarketItems[itemId].price;
    uint tokenId = MarketItems[itemId].tokenId;
    require(MarketItems[itemId].listed == true, "NFT is not listed for sale.");
    require(msg.sender != MarketItems[itemId].owner, "You are the owner and cannot purchase.");
    require(msg.value == price, "Please submit the asking price in order to complete the purchase.");

    IERC721(MarketItems[itemId].nftContract).safeTransferFrom(address(this), msg.sender, tokenId);

    // disperse funds from sale
    if (MarketItems[itemId].nftContract == savageContractAddress) {
      (bool success,) = commissionFunds.call{value: msg.value * commission / 100}("");
      require(success);
      MarketItems[itemId].owner.call{value: msg.value * salePercentage / 100}("");
      require(success);
    }
    else {
      (bool success,) = commissionFunds.call{value: msg.value * commission / 100}("");
      require(success);
      MarketItems[itemId].owner.call{value: msg.value  * salePercentage / 100}("");
      require(success);
    }

    // update history of selling prices
    MarketItems[itemId].sellingPriceOne = msg.value;

    // update owner history
    MarketItems[itemId].owner = payable(msg.sender);
    MarketItems[itemId].listed = false;
    MarketItems[itemId].timeListed = 0;
    MarketItems[itemId].timeSold = block.timestamp;
    MarketItems[itemId].price = msg.value;
    amountSold += msg.value;
    ItemsSold = ItemsSold + 1;

    // refund any existing bid for nft
    Bid memory existing = bids[itemId];
    address existingBidder = existing.bidder;
    if (existing.value > 0) {
        (bool success,) = existingBidder.call{value: existing.value}("");
        require(success);
    }

    bids[itemId] = Bid(false, itemId, address(0), 0);
  }

  function enterBid(uint256 itemId) public payable { //CHECK
      require(MarketItems[itemId].owner != msg.sender, "Owner cannot place bid.");
      require(msg.value > bids[itemId].value, "Must bid higher than current bid.");
      require(msg.value > 0, "Bid must be greater than 0.");
      Bid memory existing = bids[itemId];
      address existingBidder = existing.bidder;
      if (existing.value > 0) {
          // Refund the lower bid to previous bidder
          (bool success,) = existingBidder.call{value: existing.value}("");
          require(success);
      }

      bids[itemId] = Bid(true, itemId, msg.sender, msg.value);
  }

  function withdrawBid(uint256 itemId) public payable{ //CHECK
      require(MarketItems[itemId].owner != msg.sender, "Owner cannot withdraw bid.");
      require(bids[itemId].bidder == msg.sender, "Account does not match existing bidder.");
      uint amountBid = bids[itemId].value;
      bids[itemId] = Bid(false, itemId, address(0), 0);
      // Refund the bid money to existing bidder
      (bool success,) = msg.sender.call{value: amountBid}("");
      require(success);
  }

  function acceptBid(address nftContract, uint256 tokenId, uint256 itemId) public payable{ //CHECK
      require(MarketItems[itemId].listed == true, "NFT is not listed for sale.");
      require(bids[itemId].value > 0 , "Bid must be greater than 0.");
      Bid memory bid = bids[itemId];
      IERC721(nftContract).safeTransferFrom(address(this), bid.bidder, tokenId);

      // disperse funds from sale
      if (nftContract == savageContractAddress) {
        (bool success,) = commissionFunds.call{value: bids[itemId].value * commission / 100}("");
        require(success);
        msg.sender.call{value: bids[itemId].value * salePercentage / 100}("");
        require(success);
      }
      else {
        (bool success,) = commissionFunds.call{value: bids[itemId].value * commission / 100}("");
        require(success);
        msg.sender.call{value: bids[itemId].value * salePercentage / 100}("");
        require(success);
      }

      // update history of selling prices
      MarketItems[itemId].sellingPriceOne = bids[itemId].value;

      // update owner history
      MarketItems[itemId].owner = payable(bid.bidder);
      MarketItems[itemId].listed = false;
      MarketItems[itemId].timeListed = 0;
      MarketItems[itemId].timeSold = block.timestamp;
      MarketItems[itemId].price = 0;
      amountSold += bids[itemId].value;
      ItemsSold = ItemsSold + 1;

      bids[itemId] = Bid(false, itemId, address(0), 0);
  }

  function getExistingBid(uint256 itemId) public view returns (Bid memory) { //CHECK
      return bids[itemId];
  }

  /* Returns specific market item */
  function getMarketItem(uint256 itemId) public view returns (MarketItem memory) { //CHECK
    return MarketItems[itemId];
  }

  /* Returns volume traded on Nfts */
  function getVolumeTraded() public view returns (uint256) {
    return amountSold;
  }

  /* Returns number of sole NFTS on marketplace */
  function getTotalSales() public view returns (uint256) {
    return ItemsSold;
  }

  function totalBalance() external view returns(uint) {
      return payable(address(this)).balance;
  }

  function setCommissionPrice(uint256 numerator, uint256 denominator) onlyOwner public {
      commissionNumerator = numerator;
      commissionDenominator = denominator;
      commission = 100 * commissionNumerator / commissionDenominator;
  }

  function setSalePercentage(uint256 numerator, uint256 denominator) onlyOwner public {
      saleNumerator = numerator;
      saleDenominator = denominator;
      salePercentage = 100 * saleNumerator / saleDenominator;
  }

  function ApproveContract(address _toapprove) onlyOwner public{
    approvedcontract[_toapprove] = true;
  }

  function UnapproveContract(address _tounapprove) onlyOwner public{
    approvedcontract[_tounapprove] = false;
  }

  function createToken(string memory _tokenURI, address contractadd) public returns (uint) {
      TokenIds = TokenIds + 1;
      uint256 newItemId = TokenIds;
      _safeMint(msg.sender, newItemId);
      _setTokenURI(newItemId, _tokenURI);
      setApprovalForAll(contractadd, true);
      return newItemId;
  }
}