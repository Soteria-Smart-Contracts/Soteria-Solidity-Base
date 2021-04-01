pragma solidity ^0.7.5;


contract AlymLPLock { 
    uint256 contractbal;
    address payable Alym = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    address payable AlymWEXPpool = 0x855aA3637853A2c294F9dF1AED68aC716Ee42416;
    uint256 public CurrentELPool;
    uint256 public AlymRewardPool;
    uint256 public NoWithdrawlEnd;
    uint256 private reward;
    
    using SafeMath for uint256;
    
    mapping (address => uint256) LPTbal;
    mapping (address => uint256) EndDate;
    
    //Deposit ELP tokens in order to lock them for 7 days before receiving ALYM reward
    function Deposit(uint256 _amount)public payable returns(uint256){
        require (ERC20(AlymWEXPpool).allowance(msg.sender, address(this)) >= 1);
        require (ERC20(AlymWEXPpool).balanceOf(msg.sender) >= _amount);
        LPTbal[msg.sender] = _amount;
        ERC20(AlymWEXPpool).transferFrom(msg.sender, address(this), _amount);
        EndDate[msg.sender] = (block.timestamp.add(1*300)); //(7*86400) BURH BURH
        CurrentELPool = CurrentELPool.add(_amount);
        
        return EndDate[msg.sender];
    }
    
    //Withdraw your ELP and Receive ALYM Reward directly to your wallet after a 7 day Lock Period
    function Withdraw()public payable returns(uint256){
        require (block.timestamp >= EndDate[msg.sender]);
        require (block.timestamp >= NoWithdrawlEnd);
        require (LPTbal[msg.sender] > 0);
        reward = (AlymRewardPool/100)*(LPTbal[msg.sender]/CurrentELPool);
        ERC20(AlymWEXPpool).transfer(msg.sender, LPTbal[msg.sender]);
        ERC20(Alym).transfer(msg.sender, reward);
        LPTbal[msg.sender] = 0;
        EndDate[msg.sender] = 0;
        return reward;
    }
    
    
    //Check when your current Lock opens to withdrawls
    function EndDateCheck(address _address) public view returns(uint256){
        return EndDate[_address];
    }
    
    function CurrentReward(address _address) public view returns(uint256){
        return (AlymRewardPool/100)*(LPTbal[_address]/CurrentELPool);
        
    }

    //Add Funds to the current pool of ALYM Rewards
    function AddtoAlymPool(uint256 _amount)public payable returns(bool success){
        require (ERC20(AlymWEXPpool).allowance(msg.sender, address(this)) >= 1);
        require (_amount >= 1000000000000000); // ADD 2 ZEROS DUMBASS
        ERC20(Alym).transferFrom(msg.sender, address(this), _amount);
        AlymRewardPool = AlymRewardPool.add(_amount);
        NoWithdrawlEnd = (block.timestamp.add(600));
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
