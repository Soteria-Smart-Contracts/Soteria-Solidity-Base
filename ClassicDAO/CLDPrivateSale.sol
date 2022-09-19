//SPDX-License-Identifier:UNLICENSE
pragma solidity ^0.8.7;


contract CLDPrivateSale {
    address public CLD = 0xfc84c3Dc9898E186aD4b85734100e951E3bcb68c;
    uint256 public CLDAvailable;
    uint256 public CLDsold;
    uint256 public TreasuryPool;
    address payable public TresuryMultiSig;
    uint256 public ETCexRate;
    uint public OpenClosed;
    address public Owner;
    bool public FundsDeposited;
    bool public EligibilityCompleted = false;
    //Variable Declarations
    
    //Event Declartions
    event CLDBought(address indexed buyer, uint256 amountWETC, uint256 amountCLD);
    event ETCremoval(address indexed remover, string RemovalType, uint256 amountETC);
    
    mapping(address => bool) public Eligibility;

    //contructor arguments
    constructor(uint256 Total, uint256 _ETCexRate, address payable TreasurySig){
        CLDAvailable = Total;
        ETCexRate = _ETCexRate;
        Owner = msg.sender;
        TresuryMultiSig = TreasurySig;
    }
    
    
    function Buy() public payable returns(bool success){
        uint256 value = msg.value;
        uint256 CLDtoMintAndSend = (value * ETCexRate);
        require (OpenClosed == 1);
        require (FundsDeposited == true);
        require (Eligibility[msg.sender] == true, "Not Eligible for the Private Sale");
        require (value > 100000000);
        require ((CLDsold + CLDtoMintAndSend) <= CLDAvailable);

        //Transfers WETC to Contract and sets amount variables
        TreasuryPool = TreasuryPool + value;
        
        //Sends CLD to Buyer
        ERC20(CLD).transfer(msg.sender, CLDtoMintAndSend);
        
        //Function Events and Clearings
        emit CLDBought(msg.sender, value, CLDtoMintAndSend);
        CLDsold = CLDsold + CLDtoMintAndSend;
        CLDtoMintAndSend = 0;
        return success;
    }
    
    //View Current Conversion
    
    function ViewConversionAmount(uint256 _amountETC)public view returns(uint256){
        return (_amountETC * ETCexRate);
    }
    
    //Owner Functions
    function changePrice(uint256 _NewPrice)public payable returns(bool success){
        require (msg.sender == Owner);
        ETCexRate = _NewPrice;
        return success;
        
    }
    
    function WithdrawTRpool()public payable returns(bool success){
        require (msg.sender == Owner);
        (TresuryMultiSig).transfer(TreasuryPool);
        emit ETCremoval (Owner, "TreasuryPool", TreasuryPool);
        TreasuryPool = 0;
        return success;
    }
    
    function OnOff(uint OneOnZeroOff) public returns(bool success){
        require (msg.sender == Owner);
        OpenClosed = OneOnZeroOff;
        return success;
    }

    function VerifyFundRecieval() public returns(bool success){
        require(msg.sender == Owner);
        require(FundsDeposited == false);
        require(ERC20(CLD).balanceOf(address(this)) == CLDAvailable);
        FundsDeposited = true;
        return(success);
    }

    function AddEligible(address[] memory Addresses) public returns(bool success){
        require(msg.sender == Owner);
        require(EligibilityCompleted == false);

        uint256 index = 0;
        while(index < Addresses.length){
            Eligibility[Addresses[index]] = true;
            index++;
        }
        EligibilityCompleted = true;
        return(success);
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
