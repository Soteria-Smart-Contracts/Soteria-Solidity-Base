// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.17;

contract UnnamedStake{
    //Core Variables
    address public Pets;
    address public Food;
    address public TKN;
    uint256 public BasePay; //Yearly Base ROI in $TKN
    uint256 public FoodBoost = 334; // in 0.0001 of percentage

    //All stakes stored here
    mapping(uint256 => PetStake) public PetStakes; //TODO: TEST

    struct PetStake{
        bool Staked;
        address Staker;
        uint256 FoodStaked;
        uint256[] FoodIDs; //List of all food IDs staked with this pet
        uint256 ROIPerSecond; //Tokens returned per second
        uint256 LastPayout; //Last time this stake was claimed
    }

    //Stake Pet With no Food
    function StakePet(uint256 PetID) public returns(bool success){ //TODO: TEST
        ERC721(Pets).safeTransferFrom(msg.sender, address(this), PetID); //No Extra checks since function will bounce if owner is not message sender, just gas savings 

        uint256 ROIPerSecond = (BasePay / 31557600); //TODO: TEST
        PetStakes[PetID] = PetStake(true, msg.sender, 0, [0], ROIPerSecond, block.timestamp);

        return(success);
    }

    //Stake pet with up to 10 food
    function StakePetWithFood(uint256 PetID, uint256[] memory FoodIDs) public returns(bool success){ //TODO: TEST
        require(FoodIDs.length <= 10);
        ERC721(Pets).safeTransferFrom(msg.sender, address(this), PetID); //No Extra checks since function will bounce if owner is not message sender, just gas savings 
        
        uint256 index = 0;
        while(index < FoodIDs.length){
            ERC721(Food).safeTransferFrom(msg.sender, address(this), FoodIDs[index]);
            index++;
        }

        uint256 FoodMultiplier = FoodIDs.length * FoodBoost;
        uint256 ROIPerSecond = (((BasePay / 31557600) * FoodMultiplier) / 10000000); //TODO: TEST
        PetStakes[PetID] = PetStake(true, msg.sender, FoodIDs.length, FoodIDs, ROIPerSecond, block.timestamp);

        return(success);
    }

    // function StakePetWithAllFood(uint256 PetID, uint256[] memory FoodIDs) public returns(bool success){
    //     require(Pets == Pets);

    // }










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