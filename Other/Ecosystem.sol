pragma solidity ^0.8.4;

contract EcosystemMain{

    //Constant Variable Declarations
    string public Project;
    address public NFTContract;
    address public ECScontract;
    address public Operator;
    uint256 public BaseValue; //In EST Token (Down to last decimal place)
    uint256 public FullValueTime; //In Days
    uint256 public DailyReturn; //Calculated based on previous two variables

    //Changing Variable Declarations
    uint256 TotalStaked;

    //Mapping Declarations
    mapping (uint256 => address) public Staker;
    mapping (uint256 => uint256) public ExpiryUnix;
    mapping (uint256 => uint256) public StakeReturn;

    //Event Declarationns
    event NFTstaked(uint256 TokenID, uint256 ExpiryUnix, string Project, address NFTContract);

    //Constructor to set Variables and Operator
    constructor(string memory _ProjectName, address _NFTcontract, address _ECScontract, uint256 _BaseValue, uint256 _FullValueTime){
        Operator = msg.sender;
        Project = _ProjectName;
        NFTContract = _NFTcontract;
        ECScontract = _ECScontract;
        BaseValue = _BaseValue;
        FullValueTime = _FullValueTime;
        DailyReturn = (BaseValue / FullValueTime);
    }



    //Public Functions

    function StakeDeposit(uint256 ID, uint256 DaysToExpiry) public returns(bool success){
        //State Changes
        Staker[ID] = msg.sender;
        ExpiryUnix[ID] = (block.timestamp + (DaysToExpiry *86400));
        StakeReturn[ID] = (DailyReturn * DaysToExpiry);

        //NFT Transfer
        NFT(NFTContract).safeTransferFrom(address(this), msg.sender, ID);


        //Emit and Return
        emit NFTstaked(ID, ExpiryUnix[ID], Project, NFTContract);
        return(success);
    }



    //ERC721 Recieving Implementation
    function onERC721Received(address operator, address, uint256, bytes calldata) view external returns(bytes4) {
        require(operator == address(this), "");
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }




}

//Interface for Transfering ERC721 tokens
interface NFT{
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}
