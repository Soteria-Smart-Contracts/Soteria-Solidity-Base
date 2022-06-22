// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;


contract EVM_NFT_Collateralized_Lending_Protocol {
//Variable Declarations
    uint256 public TotalLoanCount; 
    uint256 public TotalActiveLoanCount;
    uint256 public TotalOfferCount;
    uint256 public TotalETHloaned;       //SEE BEFORE FINAL
    uint256 public TotalUnpaidEthLoaned; //SEE BEFORE FINAL
    uint256 LastUID;
    uint256 LastLID;
    address public Operator;

// Operator Declaration
    constructor(address _Operator){
        Operator = _Operator;
    }


//Struct Type Declarations
    struct NFT{
        uint256 UniqueIdentifier;
        address CollectionAddress;
        uint256 Collection_ID;
        address OriginalOwner;
        bool Active;
        bool InLoan;
    } //Once a UID has been used once in a loan, if the same NFT is collateralized again, the UID will be different


    struct Loan{
        uint256 LoanID;
        bool LoanIsOffer;
        bool LoanActive; //Default False
        bool LoanRepayed; //Default False
        uint256 LoanTerm; //In Days
        uint256 LoanExpiryUnix; //In UnixTime
        uint256 InterestRate; //In tenths of 1 (10 = 1%)
        uint256 ETHinitial; //Amount of ETH transfered/to be transfered on opening of the loan
        uint256 ETHfinal; //Amount of ETH needed to be repayed in order to close the loan before expiry
        uint256 NFT_UID; //Using Unique Identifier
        address Loanee; //User collateralizing their NFT
        address Loaner; //User providing the loan funds
        CounterOffer[] CounterOffers;
    }

    struct CounterOffer{
        address COuser;
        uint256 COterm;
        uint256 COInterestRate;
        uint256 COETHinitial;
    }

// Functionality Mappings
    mapping (address => bool) ApprovedNFTContract;

// User, NFT, Loan Mappings
    mapping (uint256 => NFT) UIDmapping;
    mapping (uint256 => Loan) LoanMapping;
    mapping (address => uint256) public OfferCount;
    mapping (address => uint256) public LoaneeCount;
    mapping (address => uint256) public LoanerCount;

//Reminder: When Counter offer is created, check to ensure Loaner has given contract access to its funds + enough funds, and if accepted but funds are missing Close the Offer and return (Not enough funds on loanee sun)

// ()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()
//User Acccesed State-Modifing functions

   function CreateLoanOffer(uint256 ID, address CollectionAddress, uint256 Amount, uint256 Term, uint256 InterestR) public returns(bool success){

      uint256 UID = InitializeUID(CollectionAddress, ID);

      InitializeLoan(Amount, Term, InterestR, UID);

      OfferCount[msg.sender] = OfferCount[msg.sender] + 1;

      return(success);
    } //UNTESTED

//    function ChangeLoanOffer()
    
//    function MakeCounterOffer()

//    function AcceptLoanCounterOffer() //For Loanee

//    function AcceptLoanOffer() //Any user to become Loaner

//    function RepayLoan()//

//    function RepayAllLoans()//
    
//    function ClaimExpiredNFT()



// ()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()
//Read Only Functions

    function ReturnUID(uint256 UID) public view returns(NFT memory) {
        return(UIDmapping[UID]);
    }

    function ReturnLoan(uint256 LoanID) public view returns(Loan memory){
        return(LoanMapping[LoanID]);
    }

    function ReturnCounterOffer(uint256 LoanID, uint256 CounterOfferID) public view returns(CounterOffer memory) {
        return(LoanMapping[LoanID].CounterOffers[CounterOfferID]);
    }

    function GetAllOffers() public view returns(uint256[] memory OfferList){
        uint256 index = 1;
        uint256 currentpush = 0;
        uint256[] memory Offerlist = new uint256[](TotalOfferCount);
        while(index <= LastLID){
            if(LoanMapping[index].LoanIsOffer == true){
                Offerlist[currentpush] = index;
                currentpush = currentpush + 1;
            }
            index = index + 1;
        }

        return(Offerlist);
    }

    function GetMyOffers(address user) public view returns(uint256[] memory MyOffersList){
        uint256 index = 1;
        uint256 currentpush = 0;
        uint256[] memory Offerlist = new uint256[](OfferCount[user]);
        while(index <= LastLID){
            if(LoanMapping[index].LoanIsOffer == true && LoanMapping[index].Loanee == user){
                Offerlist[currentpush] = index;
                currentpush = currentpush + 1;
            }
            index = index + 1;
        }

        return(Offerlist); 
    }

    function GetMyLoansLoaner(address user) public view returns(uint256[] memory MyLoanerList){
        uint256 index = 1;
        uint256 currentpush = 0;
        uint256[] memory Offerlist = new uint256[](LoaneeCount[user]);
        while(index <= LastLID){
            if(LoanMapping[index].LoanActive == true && LoanMapping[index].Loaner == user){
                Offerlist[currentpush] = index;
                currentpush = currentpush + 1;
            }
            index = index + 1;
        }

        return(Offerlist); //UNTESTED
    }

    function GetMyLoansLoanee(address user) public view returns(uint256[] memory MyLoaneeList){
        uint256 index = 1;
        uint256 currentpush = 0;
        uint256[] memory Offerlist = new uint256[](LoaneeCount[user]);
        while(index <= LastLID){
            if(LoanMapping[index].LoanActive == true && LoanMapping[index].Loanee == user){
                Offerlist[currentpush] = index;
                currentpush = currentpush + 1;
            }
            index = index + 1;
        }

        return(Offerlist); //UNTESTED
    }

    function GetCounterOffers(uint256 LoanID) public view returns(uint256[] memory LoanCounterOffersList){
        uint256 index = 1;
        uint256 TotalCounterOffers = LoanMapping[LoanID].CounterOffers.length;
        uint256 currentpush = 0;
        uint256[] memory Offerlist = new uint256[](TotalCounterOffers);
        while(index <= TotalCounterOffers){
                Offerlist[currentpush] = index;
                currentpush = currentpush + 1;
            
            index = index + 1;
        }

        return(Offerlist); //UNTESTED
    }

//    function GetMyCounterOffer(uint256 LoanID)

// ()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()
//Internal Functions 

    function InitializeUID(address CollectionAddress, uint256 ID) public returns(uint256 UID){ //MAKE INTERNAL
//        require(ApprovedNFTContract[CollectionAddress] == true, "Collection is not approved for loans");
//        require(ERC721(CollectionAddress).ownerOf(ID) == msg.sender, "User is not owner of NFT");
//        require(ERC721(CollectionAddress).isApprovedForAll(msg.sender, address(this)), "Contract is Not approved to handle this addresses NFTs");

        //Transfer NFT
//        ERC721(CollectionAddress).safeTransferFrom(msg.sender, address(this), ID);

        //Set UID
        uint256 NewUID = LastUID + 1;

        //Struct Construction
        UIDmapping[NewUID].UniqueIdentifier = NewUID;
        UIDmapping[NewUID].CollectionAddress = CollectionAddress;
        UIDmapping[NewUID].Collection_ID = ID;
        UIDmapping[NewUID].OriginalOwner = msg.sender;
        UIDmapping[NewUID].Active = true;
        UIDmapping[NewUID].InLoan = false;


        LastUID = LastUID + 1;

        return(NewUID);
    }

    function InitializeLoan(uint256 ETH, uint256 Term, uint256 Interest, uint256 UID) public returns(uint256 LoanID){ //SET INTERNAL
        require(UIDmapping[UID].Active == true);
        require(UIDmapping[UID].InLoan == false);
        require(UIDmapping[UID].OriginalOwner == msg.sender);
        require(Interest >= 5); //Minimum 0.5% interest on a loan
        require(Term >= 1); //Minimum Loan length is 1 day
        require(ETH >= 100000000 gwei); //0.1 ETH/ETC

        uint256 NewLoanID = LastLID + 1;

        LoanMapping[NewLoanID].LoanID = NewLoanID;
        LoanMapping[NewLoanID].LoanIsOffer = true;
        LoanMapping[NewLoanID].LoanActive = false;
        LoanMapping[NewLoanID].LoanRepayed = false;
        LoanMapping[NewLoanID].LoanTerm = Term;
        LoanMapping[NewLoanID].LoanExpiryUnix = 0; //Determined when loan is activated
        LoanMapping[NewLoanID].InterestRate = Interest;
        LoanMapping[NewLoanID].ETHinitial = ETH;
        LoanMapping[NewLoanID].ETHfinal = (ETH + ((ETH * 1000) / (Interest * 10000))); //ETH needed to repay the loan (Assuming no counter offer is made)
        LoanMapping[NewLoanID].NFT_UID = UID;
        LoanMapping[NewLoanID].Loanee = msg.sender;
        LoanMapping[NewLoanID].Loaner = address(0); //Set when Loan is accepted

        UIDmapping[UID].InLoan = true;

        LastLID = NewLoanID;
        TotalLoanCount = TotalLoanCount + 1;
        TotalOfferCount = TotalOfferCount + 1;

        return(NewLoanID);

    }

    function InitializeCounterOffer(uint256 LoanID, bool ChangeTerm, uint256 COterm, bool ChangeInterest, uint256 COir, bool ChangeETH, uint256 COeth) returns(uint256 COID){
        require(UIDmapping[UID].Active == true);
        require(UIDmapping[UID].InLoan == false);
        require()

    }

    function SendETH(address payable to, uint256 amount) internal{
        (to).transfer(amount);
    }

// ()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()
// Operator Only Functions

    function ApproveCollection(address CollectionAddress) public OperatorF returns(bool success){
        ApprovedNFTContract[CollectionAddress] = true;

        return(success);
    }

    function DisapproveCollection(address CollectionAddress) public OperatorF returns(bool success){
        ApprovedNFTContract[CollectionAddress] = false;

        return(success);
    } //Only for emergencies, could potentially cause issues if used while loans are open

    function TransferOperator(address NewOperator) public OperatorF returns(bool success){
        Operator = NewOperator;

        return(success);
    }


// ()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()
// Interface Dependancies and other

    function onERC721Received(address operator, address, uint256, bytes calldata) view external returns(bytes4) {
        require(operator == address(this), "");
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    modifier OperatorF{
        require(msg.sender == Operator);
        _;
    }



    

}


//Interface for Transfering ERC721 tokens
interface ERC721{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}
