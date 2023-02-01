// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.17;

contract PAWPairStaking{
    address Creator;
    address PairContract;
    address PAW;
    string public PAWPair;
    uint Multiplier;
    uint OnOff;
    
    mapping(address => uint256) Staked;
    mapping(address => uint256) ClaimablePAW;
    mapping(address => uint256) BlockDeposit;
    
    constructor(address payable _PAW, address payable _PairContract, string memory _Pair){
        PairContract = _PairContract;
        PAW = _PAW;
        PAWPair = _Pair;
        Creator = msg.sender;
    }
    
    event Deposit(address indexed sender, uint indexed amount);
    event Withdraw(address indexed sender, uint256 indexed amount);
    
    function Stake(uint256 _amount) public payable returns(bool success){
        require (ERC20(PairContract).balanceOf(msg.sender) >= _amount);
        require (ERC20(PairContract).allowance(msg.sender,(address(this))) >= _amount);
        require (OnOff == 1);
        
        ERC20(PairContract).transferFrom(msg.sender, (address(this)), _amount);
        
        if (Staked[msg.sender] > 0){
            ClaimablePAW[msg.sender] = UnclaimedPAW(msg.sender);
        }
        Staked[msg.sender] = Staked[msg.sender]+(_amount);
        BlockDeposit[msg.sender] = block.number;
        
        emit Deposit (msg.sender, _amount);
        return success;
        
        
    }
    
    
    function ClaimPAW() public payable returns(bool success){
        require (Staked[msg.sender] > 0);
        require (OnOff == 1);
        
        ClaimablePAW[msg.sender] = UnclaimedPAW(msg.sender);
        
        ERC20(PAW).Mint(msg.sender, ClaimablePAW[msg.sender]);
        
        emit Withdraw(address(this),ClaimablePAW[msg.sender]);
        
        ClaimablePAW[msg.sender] = 0;
        BlockDeposit[msg.sender] = block.number;
        return success;
    }
    
    
    function Unstake(uint256 _amount) public payable returns(bool success){
        require (Staked[msg.sender] > 0);
        require (Staked[msg.sender] >= _amount);
        
        ClaimablePAW[msg.sender] = UnclaimedPAW(msg.sender);
        
        ERC20(PAW).Mint(msg.sender, ClaimablePAW[msg.sender]);
        ERC20(PairContract).transfer(msg.sender, _amount);
        
        Staked[msg.sender] = Staked[msg.sender]-(_amount);
        BlockDeposit[msg.sender] = block.number;
        ClaimablePAW[msg.sender] = 0;
        
        return success;
    }
    
    function StakedELP(address Staker) public view returns(uint256){
        return Staked[Staker];
    }
    
    function UnclaimedPAW(address Staker) public view returns(uint256){
        return ClaimablePAW[Staker]+((((CalculatePAWequivalent(Staked[Staker])*(12594*(block.number-(BlockDeposit[Staker]))))/10000000000)/1000)*Multiplier);
    }
    
    function TotalStaked()public view returns(uint256){
        return ERC20(PairContract).balanceOf(address(this));
    }

    function CalculatePAWequivalent(uint256 _amount) public view returns(uint256){
        return (((ERC20(PAW).balanceOf(PairContract)*((((1000000000000000000 * _amount) / (Pair(PairContract).totalSupply())))) / 1000000000000000000))*2);
        
    }
    
    function CallPair() public view returns(uint256){
        return Pair(PairContract).totalSupply();
        
    }
    
    //Creator functions
    
    function Toggle(uint OneOnTwoClosed) public returns(bool success){
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
    
    function ChangeMultiplier(uint256 NewMultiplier) public returns(bool success){
        require (msg.sender == Creator);
        require (NewMultiplier >= 100 && NewMultiplier <= 10000);
        
        Multiplier = NewMultiplier;
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

interface Pair {
    function totalSupply() external view returns (uint);
    
}