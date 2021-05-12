pragma solidity ^0.8.4;


contract EXCstakefarm{
    address EXC;
    address Creator;
    uint256 ContractEXCBalance;
    uint OnOff;
    
    event Deposit(address indexed sender, uint indexed amount);
    event Withdraw(address indexed sender, uint256 indexed amount);
    //event declarations
    
    mapping(address => uint256) Staked;
    mapping(address => uint256) ClaimableEXC;
    mapping(address => uint256) BlockDeposit;
    
    constructor(address payable _EXC){
        Creator = msg.sender;
        EXC = _EXC;
    }
    
    function Stake(uint256 _amount) public payable returns(bool success){
        require (ERC20(EXC).balanceOf(msg.sender) >= _amount);
        require (ERC20(EXC).allowance(msg.sender,(address(this))) >= _amount);
        require (OnOff == 1);
        
        ERC20(EXC).transferFrom(msg.sender, (address(this)), _amount);
        
        if (Staked[msg.sender] > 0){
            ClaimableEXC[msg.sender] = ClaimableEXC[msg.sender]+((Staked[msg.sender]*(12594*(block.number-(BlockDeposit[msg.sender]))))/10000000000);
        }
        Staked[msg.sender] = Staked[msg.sender]+(_amount);
        BlockDeposit[msg.sender] = block.number;
        
        emit Deposit (msg.sender, _amount);
        return success;
        
        
    }
    
    function ClaimEXC() public payable returns(bool success){
        require (Staked[msg.sender] > 0);
        require (OnOff == 1);
        
        ClaimableEXC[msg.sender] = ClaimableEXC[msg.sender]+((Staked[msg.sender]*(12594*(block.number-(BlockDeposit[msg.sender]))))/10000000000);
        
        ERC20(EXC).Mint(msg.sender, ClaimableEXC[msg.sender]);
        
        emit Withdraw(address(this),ClaimableEXC[msg.sender]);
        
        ClaimableEXC[msg.sender] = 0;
        BlockDeposit[msg.sender] = block.number;
        return success;
    }
   
    function Unstake(uint256 _amount) public payable returns(bool success){
        require (Staked[msg.sender] > 0);
        require (Staked[msg.sender] >= _amount);
        require (OnOff == 1);
        
        ClaimableEXC[msg.sender] = ClaimableEXC[msg.sender]+((Staked[msg.sender]*(12594*(block.number-(BlockDeposit[msg.sender]))))/10000000000);
        
        ERC20(EXC).Mint(msg.sender, ClaimableEXC[msg.sender]);
        ERC20(EXC).transfer(msg.sender, _amount);
        
        Staked[msg.sender] = Staked[msg.sender]-(_amount);
        BlockDeposit[msg.sender] = block.number;
        ClaimableEXC[msg.sender] = 0;
        
        return success;
    }
    
    function ReInvest() public returns(bool success){
        require (Staked[msg.sender] > 0);
        require (OnOff == 1);
        
        ClaimableEXC[msg.sender] = ClaimableEXC[msg.sender]+((Staked[msg.sender]*(12594*(block.number-(BlockDeposit[msg.sender]))))/10000000000);
        
        ERC20(EXC).Mint(address(this),ClaimableEXC[msg.sender]);
        
        Staked[msg.sender] = Staked[msg.sender]+(ClaimableEXC[msg.sender]);
        BlockDeposit[msg.sender] = block.number;
        ClaimableEXC[msg.sender] = 0;
        
        return success;
    }
    
    
    //view functions
    
    function StakedEXC(address Staker) public view returns(uint256){
        return Staked[Staker];
    }
    
    function UnclaimedEXC(address Staker) public view returns(uint256){
        return ClaimableEXC[Staker]+((Staked[Staker]*(12594*(block.number-(BlockDeposit[Staker]))))/10000000000);
    }
    
    function TotalStaked()public view returns(uint256){
        return ERC20(EXC).balanceOf(address(this));
    }
    
    //Creator functions
    
    function Toggle(uint OneOnTwoClosed) private returns(bool success){
        require (msg.sender == Creator);
        if (OneOnTwoClosed == 1){
            OnOff = 1;
            } else if(OneOnTwoClosed == 2){
                OnOff = 2;
            } else {
                OnOff = 2;
            }
            
            return success;
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
