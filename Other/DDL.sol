pragma solidity ^0.8.4;


contract DebtLedger {
    address EXC = 0x71c6a1ae78259f9E74cD4FaA3F96CFD06d9E1616;
    

//  __  __           _             _____                          _     _                       
// |  \/  |   __ _  (_)  _ __     |  ___|  _   _   _ __     ___  | |_  (_)   ___    _ __    ___ 
// | |\/| |  / _` | | | | '_ \    | |_    | | | | | '_ \   / __| | __| | |  / _ \  | '_ \  / __|
// | |  | | | (_| | | | | | | |   |  _|   | |_| | | | | | | (__  | |_  | | | (_) | | | | | \__ \
// |_|  |_|  \__,_| |_| |_| |_|   |_|      \__,_| |_| |_|  \___|  \__| |_|  \___/  |_| |_| |___/
                                                                                              


    //Keeps Track of Debts, Debtors and Creditors
    mapping (address => mapping (uint256 => DTR)) DebtTracker;
    mapping (address => uint) DebtCount;
    
    struct DTR {
        address Creditor;
        address Debtor;
        uint256 InitialValue;
        uint256 UnPaidValue;
        bool Validity;
        uint DebtId;
    }
    
    function NewDebt(address Debtor, uint256 DebtAmount) public returns(address, uint256){
        // Variable Setting
        uint256 ID = (DebtCount[msg.sender] + 1);
        // Modifiers
        DebtTracker[msg.sender][ID] = DTR(msg.sender,Debtor,DebtAmount,DebtAmount,false,ID);
        DebtCount[msg.sender] = DebtCount[msg.sender] + 1;
        //Return Data
        return (Debtor, DebtAmount);
    }
    
    function ConfirmDebt(address Creditor, uint ID) public returns(address, uint256, bool){
        require (msg.sender == DebtTracker[Creditor][ID].Debtor);
        require (DebtTracker[Creditor][ID].Validity == false);
        DebtTracker[Creditor][ID].Validity = true;
        
        return (Creditor, ID, true);
    }
    
    function ViewDebt(address Creditor, uint ID) public view returns(address Lender, address Borrower, uint256 Amount, uint256 UnpaidAmount, bool Confirmed, uint DebtIdentifier){
        return
        (DebtTracker[Creditor][ID].Creditor,
        DebtTracker[Creditor][ID].Debtor,
        DebtTracker[Creditor][ID].InitialValue,
        DebtTracker[Creditor][ID].UnPaidValue,
        DebtTracker[Creditor][ID].Validity,
        DebtTracker[Creditor][ID].DebtId);
        
    }
    
    function UpdateDebt(address Creditor, uint ID, uint256 NewUnpaid) public returns(bool success){
        DebtTracker[Creditor][ID].UnPaidValue = NewUnpaid;
        return (success);
    }
    

//_______________________________________________________________________________________________________\\

//  _____   ____     ____   ____     ___      ___                       _                                     _             _     _                 
// | ____| |  _ \   / ___| |___ \   / _ \    |_ _|  _ __ ___    _ __   | |   ___   _ __ ___     ___   _ __   | |_    __ _  | |_  (_)   ___    _ __  
// |  _|   | |_) | | |       __) | | | | |    | |  | '_ ` _ \  | '_ \  | |  / _ \ | '_ ` _ \   / _ \ | '_ \  | __|  / _` | | __| | |  / _ \  | '_ \ 
// | |___  |  _ <  | |___   / __/  | |_| |    | |  | | | | | | | |_) | | | |  __/ | | | | | | |  __/ | | | | | |_  | (_| | | |_  | | | (_) | | | | |
// |_____| |_| \_\  \____| |_____|  \___/    |___| |_| |_| |_| | .__/  |_|  \___| |_| |_| |_|  \___| |_| |_|  \__|  \__,_|  \__| |_|  \___/  |_| |_|
//                                                             |_|                                                                                  
    
//_______________________________________________________________________________________________________\\

    function RepayDebt(address Creditor, uint ID) public returns (bool success){
        require (msg.sender == DebtTracker[Creditor][ID].Debtor);
        //make sure debt is confirmed
        ERC20(EXC).transferFrom(DebtTracker[Creditor][ID].Debtor, Creditor, (DebtTracker[Creditor][ID].UnPaidValue * 10000000000));
        UpdateDebt(Creditor, ID, 0);
        return (success);
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
