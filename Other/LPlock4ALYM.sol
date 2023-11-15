//SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.7.5;


contract AlymLPLockOfficial { 
    uint256 contractbal;
    address payable Alym = 0x7336fa672F229C7325ACcB5eF867B914a6062ad0;
    address payable AlymWEXPpool = 0x855aA3637853A2c294F9dF1AED68aC716Ee42416;
    uint256 public CurrentELPool;
    uint256 public AlymRewardPool;
    uint256 public NoWithdrawlEnd;
    uint256 private reward;
    uint256 private CalculatedDepo;
    
    
    using SafeMath for uint256;
    
    mapping (address => uint256) LPTbal;
    mapping (address => uint256) EndDate;
    mapping (address => uint256) PreBal;
    mapping (address => uint256) WithdrawReq;
    mapping (address => uint256) PreReq;
    
    
    
    function PreDeposit()public payable returns(bool success){
        require(ERC20(AlymWEXPpool).balanceOf(msg.sender) >= 0);
        require (block.timestamp >= EndDate[msg.sender]);
        require (WithdrawReq[msg.sender] == 0);
        PreBal[msg.sender] = ERC20(AlymWEXPpool).balanceOf(msg.sender);
        CalculatedDepo = 0;
        PreReq[msg.sender] = 0;
        return success;
        
    }
    
    
    
    
    //Deposit ELP tokens in order to lock them for 7 days before receiving ALYM reward
    function Deposit()public payable returns(uint256){
        CalculatedDepo = PreBal[msg.sender].sub(ERC20(AlymWEXPpool).balanceOf(msg.sender));
        require (block.timestamp >= EndDate[msg.sender]);
        require (ERC20(AlymWEXPpool).balanceOf(address(this)) >= CurrentELPool.add(CalculatedDepo));
        require (WithdrawReq[msg.sender] == 0);
        require (PreReq[msg.sender] == 0);
        LPTbal[msg.sender] = CalculatedDepo;
        EndDate[msg.sender] = (block.timestamp.add(604800)); //Reset on Real Release
        WithdrawReq[msg.sender] = 1;
        CurrentELPool = CurrentELPool.add(CalculatedDepo);
        PreBal[msg.sender] = 0;
        CalculatedDepo = 0;
        
        return EndDate[msg.sender];
    }
    
    //Withdraw your ELP and Receive ALYM Reward directly to your wallet after a 7 day Lock Period
    function Withdraw()public payable returns(uint256){
       require (block.timestamp >= EndDate[msg.sender]);
       require (block.timestamp >= NoWithdrawlEnd);
       require (LPTbal[msg.sender] > 0);
       reward = ((AlymRewardPool/100)*(LPTbal[msg.sender]/(CurrentELPool/100)));
       ERC20(AlymWEXPpool).transfer(msg.sender, LPTbal[msg.sender]);
       ERC20(Alym).transfer(msg.sender, reward);
       AlymRewardPool = AlymRewardPool.sub(reward);
       CurrentELPool = CurrentELPool.sub(LPTbal[msg.sender]);
       WithdrawReq[msg.sender] = 0;
       LPTbal[msg.sender] = 0;
       EndDate[msg.sender] = 0;
       PreReq[msg.sender] = 1;
       return reward;
}
 
    
    //Check when your current Lock opens to withdrawls
    function EndDateCheck(address _address) public view returns(uint256){
        return EndDate[_address];
    }
    //Check Your current Reward
    function CurrentReward(address _address) public view returns(uint256){
        return ((AlymRewardPool/100)*(LPTbal[_address]/(CurrentELPool/100)));
        
    }

    //Add Funds to the current pool of ALYM Rewards
    function AddtoAlymPool(uint256 _amount)public returns(bool success){
        require (msg.sender == 0x19b2a627Dd49587E021290b3eEF38ea8DE541eE5); //Revert on Exp
        AlymRewardPool = AlymRewardPool.add(_amount);
        NoWithdrawlEnd = (block.timestamp.add(43200)); //Reset on real release
        return success;
        
    }
    
    //Check LPTbal
    function CheckLPTbalance(address _Address)public view returns(uint256){
        return LPTbal[_Address];
    }
    
    
    function ERC20Recovery(address payable _contractAddress, uint256 _amount, address _to) public payable returns(bool success){
        require (msg.sender == 0x19b2a627Dd49587E021290b3eEF38ea8DE541eE5);
        ERC20(_contractAddress).transfer(_to,_amount);
        if (_contractAddress == AlymWEXPpool && LPTbal[msg.sender] == 0){
         LPTbal[_to] = 0;}
        if (_contractAddress == AlymWEXPpool && LPTbal[msg.sender] > 0){
         CurrentELPool = CurrentELPool.sub(_amount);
         LPTbal[_to] = LPTbal[_to].sub(_amount);
         PreReq[msg.sender] = 1;
         WithdrawReq[msg.sender] = 0;
        }
        if (_contractAddress == Alym){
         AlymRewardPool = AlymRewardPool.sub(_amount);
        }
        return success;
    }
    
    

    
}
    
   
   
   
  library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }    
   
   
  }
   
   
    
interface ERC20 {
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool); 
}    
