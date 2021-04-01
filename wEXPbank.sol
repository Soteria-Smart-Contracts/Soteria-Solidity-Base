pragma solidity ^0.7.5;

contract ExpanseBank0x19 {
    
    address BankCustomer = msg.sender;
    address payable wEXP = 0x331631B4bb93b9B8962faE15860BD538a389395A;
    uint256 BankBalance;
    uint256 LeftoverBalance;
    
    using SafeMath for uint256;
    
    function CheckBalance()public view returns(uint256){
    return ERC20(wEXP).balanceOf(address(this));
    }
    

    
    function Withdraw(uint256 _WithdrawlAmount) public payable returns(bool success, uint256){
        require (msg.sender == BankCustomer);
        BankBalance = ERC20(wEXP).balanceOf(address(this));
        LeftoverBalance = BankBalance.sub(_WithdrawlAmount);
        require (_WithdrawlAmount <= BankBalance);
        ERC20(wEXP).transfer(BankCustomer, _WithdrawlAmount);
        return (success,LeftoverBalance);
        
        
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
  function transferFrom(address from, address to, uint value) external returns (bool); 
}    
