pragma solidity ^0.7.5;


contract WrappedLitecoin {
    uint256 public TokenCap;
    uint256 public TotalSupply;
    uint256 public burntSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    address private ownerAddy;
    address private ZeroAddress;
    //variable Declarations
    
      
    event Transfer(address indexed from, address indexed to, uint256 value);    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    //Event Declarations 
    
    using SafeMath for uint256;
    
    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;
    
    
    
    constructor(uint256 _TokenCap, string memory _name, string memory _symbol, uint8 _decimals, address _owneraddy){
    TokenCap = _TokenCap;
    TotalSupply = 0;
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    ownerAddy = _owneraddy;
    //Deployment Constructors
    }
    
    

    
    function balanceOf(address Address) public view returns (uint256 balance){
        return balances[Address];

    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    //Approves an address to spend your coins

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);
    
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    //Transfer From an other address


    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }


    function Mint(address _MintTo, uint256 _MintAmount) public {
        require (msg.sender == ownerAddy);
        require (TotalSupply.add(_MintAmount) <= TokenCap);
        balances[_MintTo] = balances[_MintTo].add(_MintAmount);
        TotalSupply = TotalSupply.add(_MintAmount);
        ZeroAddress = 0x0000000000000000000000000000000000000000;
        emit Transfer(ZeroAddress ,_MintTo, _MintAmount);
    }
    //Mints tokens to your address 


    function Burn(uint256 _BurnAmount) public {
        require (balances[msg.sender] >= _BurnAmount);
        balances[msg.sender] = balances[msg.sender].sub(_BurnAmount);
        burntSupply = burntSupply.sub(_BurnAmount);
        ZeroAddress = 0x0000000000000000000000000000000000000000;
        emit Transfer(msg.sender, ZeroAddress, _BurnAmount);
        
    }


      function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    
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
