pragma solidity ^0.8.4;


contract ExpanseCashTest2 {
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
    event BurnEvent(address indexed burner, uint256 indexed buramount);
    event ManageMinterEvent(address indexed newminter);
    //Event Declarations 
    
    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;
    
    mapping(address => uint)minter;
    
    constructor(uint256 _TokenCap, string memory _name, string memory _symbol, uint8 _decimals){
    TokenCap = _TokenCap;
    TotalSupply = 0;
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    ownerAddy = msg.sender;
    //Deployment Constructors
    }
    
    

    
    function balanceOf(address Address) public view returns (uint256 balance){
        return balances[Address];

    }

    function approve(address delegate, uint _amount) public returns (bool) {
        allowed[msg.sender][delegate] = _amount;
        emit Approval(msg.sender, delegate, _amount);
        return true;
    }
    //Approves an address to spend your coins

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(_amount <= balances[_from]);    
        require(_amount <= allowed[_from][msg.sender]);
    
        balances[_from] = balances[_from]-(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender]-(_amount);
        balances[_to] = balances[_to]+(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }
    //Transfer From an other address


    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-(_amount);
        balances[_to] = balances[_to]+(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }


    function Mint(address _MintTo, uint256 _MintAmount) public {
        require (minter[msg.sender] == 1);
        require (TotalSupply+(_MintAmount) <= TokenCap);
        balances[_MintTo] = balances[_MintTo]+(_MintAmount);
        TotalSupply = TotalSupply+(_MintAmount);
        ZeroAddress = 0x0000000000000000000000000000000000000000;
        emit Transfer(ZeroAddress ,_MintTo, _MintAmount);
    }
    //Mints tokens to your address 


    function Burn(uint256 _BurnAmount) public {
        require (balances[msg.sender] >= _BurnAmount);
        balances[msg.sender] = balances[msg.sender]-(_BurnAmount);
        TotalSupply = TotalSupply-(_BurnAmount);
        ZeroAddress = 0x0000000000000000000000000000000000000000;
        emit Transfer(msg.sender, ZeroAddress, _BurnAmount);
        emit BurnEvent(msg.sender, _BurnAmount);
        
    }

    function ManageMinter(uint _addremove, address _address) public returns(address){
        require (msg.sender == ownerAddy);
        if (_addremove == 1){
            minter[_address] = 1;
        }
        if (_addremove == 2){
            minter[_address] = 0;
        }
        emit ManageMinterEvent(_address);
        return (_address);
    }


      function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    
    }


}

