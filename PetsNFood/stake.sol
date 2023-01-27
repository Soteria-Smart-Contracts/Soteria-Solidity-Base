// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.17;

contract UnnamedStake{
    address public Pets;
    address public Food;
    address public TKN;
    uint256 public BasePay; //Yearly Base ROI in $TKN
    uint256 public FoodMultiplier;

    mapping(uint256 => PetStake) public PetStakes;

    struct PetStake{
        uint256 PetID;
        uint256 FoodStaked;
        uint256[] FoodIDs;
        uint256 ROIPerSecond;
    }

    function StakePetWithFood(uint256 PetID, uint256[] memory FoodIDs) public returns(bool success){
        ERC721(Pets).safeTransferFrom(msg.sender, address(this), PetID); //No Extra checks since function will bounce if owner is not message sender, just gas savings 
        
        uint256 index = 0;
        while(index < FoodIDs.length){
            ERC721(Food).safeTransferFrom(msg.sender, address(this), FoodIDs[index]);
            index++;
        }

        FoodMultiplier 
        uint256 ROIPerSecond = BasePay / 31557600;
        PetStakes[PetID] = PetStake(PetID, FoodIDs.length, FoodIDs, 0);
        

        return(success);
    }

    function StakePetWithAllFood(uint256 PetID, uint256[] memory FoodIDs) public returns(bool success){
        require(Pets == Pets);

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