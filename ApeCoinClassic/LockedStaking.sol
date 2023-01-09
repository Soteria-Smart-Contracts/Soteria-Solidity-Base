//SPDX-License-Identifier:UNLICENSE
pragma solidity ^0.8.7;

contract LockedStaking{
    //Variable Declarations
    address ACE;
    address Operator;
    uint256 public TotalDeposits;
    //Array for each person
    mapping(address => Lock[]) public UserLocks;
    mapping(address => uint256) public ActiveLocks;
    mapping(uint8 => uint256) LockTypeTime;
    mapping(uint8 => uint256) LockTypeMultiplier;

    constructor(address _ACE){
        ACE = _ACE; 
        Operator = msg.sender;
        LockTypeTime[1] = 2592000;//30 Days 2592000
        LockTypeTime[2] = 2592000;
        LockTypeMultiplier[1] = 250;
        LockTypeMultiplier[2] = 320;
    }
    //Lock Types:
    //6M 10% 
    //11M 22.5% 

    struct Lock{
        uint256 ID;
        address User;
        uint8 Type;
        uint256 DepositAmount;
        uint256 WithdrawAmount;
        uint256 Expiration; //In Unix
    }


    //Public Functions
    function CreateLock(uint8 Type, uint256 amount) public returns(bool success){
        require(amount >= 1000000000000000000, "The minimum deposit for staking is 1 ACE");
        require(ERC20(ACE).balanceOf(msg.sender) >= amount, "You do not have enough ACE to stake this amount");
        require(ERC20(ACE).allowance(msg.sender, address(this)) >= amount, "You have not given the staking contract enough allowance");
        require((ActiveLocks[msg.sender] + 1) <= 3);

        uint256 NewLockID = UserLocks[msg.sender].length;
        uint256 AmountOnWithdraw = ((amount * LockTypeMultiplier[Type]) / 10000) + amount;
        uint256 Expiration = (block.timestamp + LockTypeTime[Type]);
        Lock memory NewLock = Lock(NewLockID, msg.sender, Type, amount, AmountOnWithdraw, Expiration);

        ERC20(ACE).transferFrom(msg.sender, address(this), amount);

        ActiveLocks[msg.sender] = ActiveLocks[msg.sender] + 1;
        UserLocks[msg.sender].push(NewLock);
        TotalDeposits = TotalDeposits + amount;

        return(success);
    }

    function ClaimLock(uint256 ID) public returns(bool success){
        require(UserLocks[msg.sender][ID].Expiration <= block.timestamp, "This lock has not acheived its maturity date yet");
        if(UserLocks[msg.sender][ID].Type == 66){
            revert("This lock has already been claimed");
        }
        uint256 amount = UserLocks[msg.sender][ID].WithdrawAmount;
        if(((ERC20(ACE).balanceOf(address(this)) - (UserLocks[msg.sender][ID].WithdrawAmount - UserLocks[msg.sender][ID].DepositAmount)) <= TotalDeposits)){ //This exists as protection in the case that the contract has not been refilled with ACE in time
             amount = UserLocks[msg.sender][ID].DepositAmount; 
        }

        TotalDeposits = TotalDeposits - UserLocks[msg.sender][ID].DepositAmount;
        UserLocks[msg.sender][ID].Type = 66;
        UserLocks[msg.sender][ID].User = address(0);
        UserLocks[msg.sender][ID].DepositAmount = 0;
        UserLocks[msg.sender][ID].WithdrawAmount = 0;
        UserLocks[msg.sender][ID].Expiration = 3093517607560;

        ActiveLocks[msg.sender] = ActiveLocks[msg.sender] - 1;
        
        ERC20(ACE).transfer(msg.sender, amount);
        return(success);
    }

    //Informatical View Functions

    function GetDaysLeft(address User, uint256 ID) public view returns(uint256 Days){
        return(((UserLocks[User][ID].Expiration - block.timestamp) / 86400));
    }

    function GetTimeLeft(address User, uint256 ID) public view returns(uint256 Seconds){
        if(UserLocks[User][ID].Expiration > block.timestamp){
        return((UserLocks[User][ID].Expiration - block.timestamp));
        }
        else{
            revert("This Lock has Expired already");
        }
    }

    function GetActiveUserLocks(address User) public view returns(uint256 Number){
        return(UserLocks[User].length);
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