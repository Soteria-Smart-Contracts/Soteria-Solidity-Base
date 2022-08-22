//SPDX-License-Identifier:UNLICENSE
pragma solidity ^0.8.7;


contract CLDPrivateSale {
    address public CLD = payable(0);
    uint256 public CLDAvailable;
    uint256 public CLDMinted;
    uint256 public TreasuryPool;
    address payable public TresuryMultiSig;
    uint256 public DevelopmentPool;
    address payable public DeveloperMultiSig;
    uint256 public ETCexRate;
    uint public OpenClosed;
    address public Owner;
    bool public FundsDeposited;
    //Variable Declarations
    
    //Event Declartions
    event CLDBought(address indexed buyer, uint256 amountWETC, uint256 amountCLD);
    event ETCremoval(address indexed remover, string RemovalType, uint256 amountETC);
    

    //contructor arguments
    constructor(uint256 Total, uint256 _ETCexRate){
        CLDAvailable = Total;
        ETCexRate = _ETCexRate;
        Owner = msg.sender;
    }
    
    
    function Buy() public payable returns(bool success){
        uint256 value = msg.value;
        uint256 CLDtoMintAndSend = (value * ETCexRate);
        require (OpenClosed == 1);
        require (value > 100000000);
        require ((CLDMinted + CLDtoMintAndSend) <= CLDAvailable);

        //Transfers WETC to Contract and sets amount variables
        TreasuryPool = TreasuryPool+((value / 100) * 85);
        DevelopmentPool = DevelopmentPool+((value / 100) * 15);

        
        //Mints and Sends CLD to Buyer
        ERC20(CLD).Mint(msg.sender, CLDtoMintAndSend);
        
        //Function Events and Clearings
        emit CLDBought(msg.sender, value, CLDtoMintAndSend);
        CLDMinted = CLDMinted + CLDtoMintAndSend;
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
        (payable(Owner)).transfer(TreasuryPool);
        emit ETCremoval (Owner, "LiquidityPool", TreasuryPool);
        TreasuryPool = 0;
        return success;
    }
    
    function WithdrawDevPool()public payable returns(bool success){
        require (msg.sender == Owner);
        (payable(Owner)).transfer(DevelopmentPool);
        emit ETCremoval (Owner, "DevelopmentPool", TreasuryPool);
        TreasuryPool = 0;
        return success;
    }
    
    function OnOff(uint OneOnZeroOff) public returns(bool success){
        require (msg.sender == Owner);
        OpenClosed = OneOnZeroOff;
        return success;
    }

    function VerifyFundRecieval() public returns(bool success){
        require(ERC20(CLD).balanceOf(address(this)) == CLDAvailable);
        FundsDeposited = true;
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
