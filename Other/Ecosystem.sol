pragma solidity ^0.8.4;

contract EcosystemMain{

    //Constant Variable Declarations
    string public Project;
    address public NFTContract;
    address public ECScontract;
    address public Operator;
    uint256 public BaseValue; //In EST Token
    uint256 public FullValueTime; //In Days

    //Changing Variable Declarations
    uint256 TotalStaked;

    //Mapping Declarations
    mapping (uint256 => address) Staker;
    mapping (uint256 => uint256) ExpiryUnix;

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
    }



    //Public Functions




}

//Interface for Transfering ERC721 tokens
interface NFT{
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}
