pragma solidity ^0.8.4;



contract CLS_Crowdsale {
    address payable CLS;
    address payable wETC;
    uint256 public CLS_Sale_Allocation;
    uint256 public Total_wETC_Deposited; 
    uint256 public Allocation_Exchange_Rate = 0;
    uint256 public Total_CLS_Distributed;
    address public CrowdSale_Operator;
    uint256 public Crowdsale_End_Unix;
    
    //Crowdsale Mode struct 
    struct Mode {
        string Sale_Mode_Text;
        uint8 Sale_Mode;
    }
    
    Mode Crowdsale_Mode;
    //Crowdsale Modes
    //1: Before sale preperation Mode
    //2: Sale is Open to buy CLS
    //3: Sale is over, CLS buyer withdrawal period
    //99 Emergency Shutdown mode, in case any issues or bugs need to be dealt with, Safe for buyers, and ETC withdrawls will be available
    
    
    //Crowdsale Contract constructor
    constructor(uint256 Sale_Allocation, address payable _CLS, address payable _wETC){
        CLS_Sale_Allocation = Sale_Allocation;
        CLS = _CLS;
        wETC = _wETC;
        Crowdsale_Mode = Mode("Before sale preperation", 1);
        CrowdSale_Operator = msg.sender;
    }
    
    //Event Declarations
    event CrowdsaleStarted(address Operator, uint256 Crowdsale_Allocation, uint256 Unix_End);
    event CrowdsaleEnded(address Operator, uint256 wETCraised, uint256 BlockTimestamp);
    event wETCdeposited(address Depositor, uint256 Amount);
    event wETCwithdrawn(address Withdrawee, uint256 Amount);
    event CLSwithdrawn(address Withdrawee, uint256 Amount);
    event VariableChange(string Change);
    
    
    //Deposit Tracker
    mapping(address => uint256) wETC_Deposited;
    
    
    //Buyer Functions
    
    function DepositETC(uint256 amount) public returns(bool success){
        require (Crowdsale_Mode.Sale_Mode == 2);
        require (block.timestamp < Crowdsale_End_Unix);
        
        ERC20(wETC).transferFrom(msg.sender, address(this), amount);
        
        wETC_Deposited[msg.sender] = (wETC_Deposited[msg.sender] + amount);
        
        Total_wETC_Deposited = (Total_wETC_Deposited + amount);
        emit wETCdeposited(msg.sender, amount);
        return(success);
    }
    
    //There is a 5% fee for withdrawing deposited wETC
    function WithdrawETC(uint256 amount) public returns(bool success){
        require (amount < wETC_Deposited[msg.sender]);
        require(Crowdsale_Mode.Sale_Mode != 3 && Crowdsale_Mode.Sale_Mode != 1);
        uint256 amount_wFee;
        amount_wFee = (amount * 95 / 100);
        
        wETC_Deposited[msg.sender] = (wETC_Deposited[msg.sender] - amount);
        
        ERC20(wETC).transfer(msg.sender, amount_wFee);
        //CHECK WITH DEVS FOR FEE TO COME RIGHT OUT OR NOT
        Total_wETC_Deposited = (Total_wETC_Deposited - amount);
        emit wETCwithdrawn(msg.sender, amount);
        return(success);
    }
    
    
    
    //Operator Functions
    function StartCrowdsale() public returns(bool success){
        require(msg.sender == CrowdSale_Operator);
        require(ERC20(CLS).CheckMinter(address(this)) == true);
        require(Crowdsale_Mode.Sale_Mode == 1);
        
        Crowdsale_End_Unix = (block.timestamp + 1209600);
        Crowdsale_Mode.Sale_Mode_Text = ("Sale is Open to buy CLS");
        Crowdsale_Mode.Sale_Mode = 2;
        
        emit CrowdsaleStarted(msg.sender, CLS_Sale_Allocation, Crowdsale_End_Unix);
        return success;
        
    }
    
    function EndCrowdsale() public returns(bool success){
        require(msg.sender == CrowdSale_Operator);
        require(ERC20(CLS).CheckMinter(address(this)) == true);
        require(Crowdsale_Mode.Sale_Mode == 2);
        require (block.timestamp > Crowdsale_End_Unix);
        
        Crowdsale_Mode.Sale_Mode_Text = ("Sale is over, Time to withdraw CLS!");
        Crowdsale_Mode.Sale_Mode = 3;
        
        emit CrowdsaleEnded(msg.sender, Total_wETC_Deposited, block.timestamp);
        return(success);
        
    }
    
      //Redundancy
    function ChangeCLSaddy(address payable NewAddy)public returns(bool success, address CLSaddy){
        require(msg.sender == CrowdSale_Operator);
        require(Crowdsale_Mode.Sale_Mode != 3);
        CLS = NewAddy;
        emit VariableChange("Changed CLS Address");
        return(true, CLS);
    }
      //Redundancy
    function ChangeWETCaddy(address payable NewAddy)public returns(bool success, address wETCaddy){
        require(msg.sender == CrowdSale_Operator);
        require(Crowdsale_Mode.Sale_Mode == 1);
        wETC = NewAddy;
        emit VariableChange("Changed wETC Address");
        return(true, CLS);
    }
    
    //Call Functions
    function GetContractMode() public view returns(uint256, string memory){
        return (Crowdsale_Mode.Sale_Mode, Crowdsale_Mode.Sale_Mode_Text);
        
    }
    
    function GetwETCdeposited(address _address) public view returns(uint256){
        return (wETC_Deposited[_address]);
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
  function CheckMinter(address AddytoCheck) external view returns(bool);
}

//      $$$$$$                     /$$                                /$$           /$$                      /$$      /$$               /$$                                               /$$                      
//    /$$__  $$                   | $$                               | $$          | $$                     | $$  /$ | $$              | $$                                              | $$                      
//   | $$  \__/ /$$$$$$ /$$$$$$$ /$$$$$$   /$$$$$$ /$$$$$$  /$$$$$$$/$$$$$$        | $$$$$$$ /$$   /$$      | $$ /$$$| $$ /$$$$$$  /$$$$$$$ /$$$$$$  /$$$$$$  /$$$$$$  /$$$$$$  /$$$$$$ /$$$$$$   /$$$$$$ /$$$$$$$ 
//   | $$      /$$__  $| $$__  $|_  $$_/  /$$__  $|____  $$/$$_____|_  $$_/        | $$__  $| $$  | $$      | $$/$$ $$ $$/$$__  $$/$$__  $$/$$__  $$/$$__  $$/$$__  $$|____  $$/$$__  $|_  $$_/  /$$__  $| $$__  $$
//   | $$     | $$  \ $| $$  \ $$ | $$   | $$  \__//$$$$$$| $$       | $$          | $$  \ $| $$  | $$      | $$$$_  $$$| $$$$$$$| $$  | $| $$$$$$$| $$  \__| $$  \ $$ /$$$$$$| $$  \__/ | $$   | $$$$$$$| $$  \ $$
//   | $$    $| $$  | $| $$  | $$ | $$ /$| $$     /$$__  $| $$       | $$ /$$      | $$  | $| $$  | $$      | $$$/ \  $$| $$_____| $$  | $| $$_____| $$     | $$  | $$/$$__  $| $$       | $$ /$| $$_____| $$  | $$
//   |  $$$$$$|  $$$$$$| $$  | $$ |  $$$$| $$    |  $$$$$$|  $$$$$$$ |  $$$$/      | $$$$$$$|  $$$$$$$      | $$/   \  $|  $$$$$$|  $$$$$$|  $$$$$$| $$     |  $$$$$$|  $$$$$$| $$       |  $$$$|  $$$$$$| $$  | $$
//   \______/ \______/|__/  |__/  \___/ |__/     \_______/\_______/  \___/        |_______/ \____  $$      |__/     \__/\_______/\_______/\_______|__/      \____  $$\_______|__/        \___/  \_______|__/  |__/
//                                                                                         /$$  | $$                                                       /$$  \ $$                                             

//
