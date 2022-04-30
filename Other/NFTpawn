pragma solidity 0.8.7;


contract EVM_NFT_Collateralized_Lending_Protocol {
//Variable Declarations
    uint256 TotalLoanCount;
    uint256 TotalActiveLoanCount;
    uint256 TotalETHloaned;
    uint256 TotalUnpaidEthLoaned;
    uint256 LastUID;
    uint256 LastLID;


//Struct Type Declarations
    struct NFT{
        uint256 UniqueIdentifier;
        address CollectionAddress;
        uint256 Collection_ID;
        address OriginalOwner;
        bool Active;
    } //Once a UID has been used once in a loan, if the same NFT is collateralized again, the UID will be different


    struct Loan{
        uint256 LoanID;
        bool LoanActive; //Default False
        bool LoanRepayed; //Default False
        uint256 LoanTerm; //In Days
        uint256 LoanExpiryUnix; //In UnixTime
        uint256 InterestRate; //In tenths of 1 (10 = 1%)
        uint256 NFT_UID; //Using Unique Identifier
        address Loanee; //User collateralizing their NFT
        address Loaner; //User providing the loan funds
    }

// Functionality Mappings
    mapping (address => bool) ApprovedNFTContract;

// User, NFT, Loan Mappings
    mapping (uint256 => NFT) UIDmapping;
    mapping (address => uint256) UserLoanCount;







    

// ()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()
//Internal Functions 

    function CreateUID(address CollectionAddress, uint256 ID) internal returns(uint256 UID){
        require(ApprovedNFTContract[CollectionAddress] == true, "Collection is not approved for loans");
        require(ERC721(CollectionAddress).ownerOf(ID) == msg.sender, "User is not owner of NFT");
        require(ERC721(CollectionAddress).isApprovedForAll(msg.sender, address(this)), "Contract is Not approved to handle this addresses NFTs");

        //Transfer NFT
        ERC721(CollectionAddress).safeTransferFrom(msg.sender, address(this), ID);

        //Set UID
        uint256 NewUID = LastUID + 1;

        //Struct Construction
        UIDmapping[NewUID].UniqueIdentifier = NewUID;
        UIDmapping[NewUID].CollectionAddress = CollectionAddress;
        UIDmapping[NewUID].Collection_ID = ID;
        UIDmapping[NewUID].OriginalOwner = msg.sender;
        UIDmapping[NewUID].Active = true;


        LastUID = LastUID + 1;

    }




// ()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()
// Interface Dependancies (Basically just ERC721Reciever)

    function onERC721Received(address operator, address, uint256, bytes calldata) view external returns(bytes4) {
        require(operator == address(this), "");
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    

}


//Interface for Transfering ERC721 tokens
interface ERC721{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}
