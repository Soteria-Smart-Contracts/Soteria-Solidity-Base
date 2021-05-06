pragma solidity ^0.7.5;


contract EXCstakefarm{
    address payable EXC = 0xB43882F3DcF8ced02701C62d3310580049e93AE8;
    uint256 ContractEXCBalance;
    
    event Deposit(address indexed sender, uint indexed amount);
    event Withdraw(address indexed sender, uint256 indexed amount);
    //event declarations
    
    using SafeMath for uint256;
    
    mapping(address => uint256) Staked;
    mapping(address => uint256) ClaimableEXC;
    mapping(address => uint256) BlockDeposit;
    
    function Stake(uint256 _amount) public payable returns(bool success){
        require (ERC20(EXC).balanceOf(msg.sender) >= _amount);
        require (ERC20(EXC).allowance(msg.sender,(address(this))) >= _amount);
        
        ERC20(EXC).transferFrom(msg.sender, (address(this)), _amount);
        
        if (Staked[msg.sender] > 0){
            ClaimableEXC[msg.sender] = ClaimableEXC[msg.sender].add((Staked[msg.sender]*(200*(block.number.sub(BlockDeposit[msg.sender]))))/100000);
        }
        Staked[msg.sender] = Staked[msg.sender].add(_amount);
        BlockDeposit[msg.sender] = block.number;
        
        emit Deposit (msg.sender, _amount);
        return success;
        
        
    }
    
    function ClaimEXC() public payable returns(bool success){
        require (Staked[msg.sender] > 0);
        
        ClaimableEXC[msg.sender] = ClaimableEXC[msg.sender].add((Staked[msg.sender]*(200*(block.number.sub(BlockDeposit[msg.sender]))))/100000);
        
        ERC20(EXC).Mint(msg.sender, ClaimableEXC[msg.sender]);
        
        emit Withdraw(address(this),ClaimableEXC[msg.sender]);
        
        ClaimableEXC[msg.sender] = 0;
        BlockDeposit[msg.sender] = block.number;
        return success;
    }
   
    function Unstake(uint256 _amount) public payable returns(bool success){
        require (Staked[msg.sender] > 0);
        require (Staked[msg.sender] >= _amount);
        
        ClaimableEXC[msg.sender] = ClaimableEXC[msg.sender].add((Staked[msg.sender]*(200*(block.number.sub(BlockDeposit[msg.sender]))))/100000);
        
        ERC20(EXC).Mint(msg.sender, ClaimableEXC[msg.sender]);
        ERC20(EXC).transfer(msg.sender, _amount);
        
        Staked[msg.sender] = Staked[msg.sender].sub(_amount);
        BlockDeposit[msg.sender] = block.number;
        ClaimableEXC[msg.sender] = 0;
        
        return success;
    }
    
    function ReInvest() public returns(bool success){
        require (Staked[msg.sender] > 0);
        
        ClaimableEXC[msg.sender] = ClaimableEXC[msg.sender].add((Staked[msg.sender]*(200*(block.number.sub(BlockDeposit[msg.sender]))))/100000);
        
        ERC20(EXC).Mint(address(this),ClaimableEXC[msg.sender]);
        
        Staked[msg.sender] = Staked[msg.sender].add(ClaimableEXC[msg.sender]);
        BlockDeposit[msg.sender] = block.number;
        ClaimableEXC[msg.sender] = 0;
        
        return success;
    }
    
    
    //view functions
    
    function StakedEXC(address Staker) public view returns(uint256){
        return Staked[Staker];
    }
    
    function UnclaimedEXC(address Staker) public view returns(uint256){
        return ClaimableEXC[Staker].add((Staked[Staker]*(200*(block.number.sub(BlockDeposit[Staker]))))/100000);
    }
    
    function TotalStaked()public view returns(uint256){
        return ERC20(EXC).balanceOf(address(this));
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
  function Mint(address _MintTo, uint256 _MintAmount) external;
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool); 
  function totalSupply() external view returns (uint);
}    
