/*
THIS IS AN UNAUDITED MOCK CONTRACT FOR TESTING
DO NOT USE IN PRODUCTION!
*/
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../ISTAKING.sol";
import "../ISTAKINGPROXY.sol";

contract MockStakingProxy is ISTAKINGPROXY{
    using SafeERC20 for IERC20;

    string NOTICE = "THIS MOCK CONTRACT IS UNAUDITED AND NOT FOR PRODUCTION USE";

    struct Stake{
        uint256 stakedTime;
        uint256 stakedAmount;
    }

    IERC20 token;
    ISTAKING staking;
    //staker => delegate => Stake
    mapping (address => mapping(address => Stake)) public stakes;
    uint256 tokenReward; // per token per second

    mapping (address => uint256) public accruedRewards;

    //assume staking token is also used to pay rewards
    constructor(address token_, address staking_, uint256 reward_){
        token = IERC20(token_);
        staking = ISTAKING(staking_);
        tokenReward = reward_; //token per second
    }

    function proxyTransfer(address from, uint256 amount) external override{
        require(msg.sender == address(staking));
        IERC20(token).transferFrom(from, address(staking), amount);
        //do bookkeeping here?
    }

    //user staking function - stake on their own behalf
    function stake(uint256 amount) external{
        //bookkeeping to do beforehand
        accruedRewards[msg.sender] = accruedRewards[msg.sender] + stakes[msg.sender][msg.sender].stakedAmount*(block.timestamp - stakes[msg.sender][msg.sender].stakedTime);
        stakes[msg.sender][msg.sender].stakedAmount = stakes[msg.sender][msg.sender].stakedAmount + ISTAKING(staking).stakeFor(msg.sender, msg.sender, amount);
        //bookkeeping
        stakes[msg.sender][msg.sender].stakedTime = block.timestamp;        
    }

    function unstake(uint256 amount) external {
        //do bookkeeping
        accruedRewards[msg.sender] = accruedRewards[msg.sender] + stakes[msg.sender][msg.sender].stakedAmount*(block.timestamp - stakes[msg.sender][msg.sender].stakedTime);
        ISTAKING(staking).unstakeFor(msg.sender, msg.sender, amount);
        stakes[msg.sender][msg.sender].stakedAmount = stakes[msg.sender][msg.sender].stakedAmount - amount;
        stakes[msg.sender][msg.sender].stakedTime = block.timestamp;        
    }

    //staking function - stake for another user's voting power
    function stakeFor(address delegate, uint256 amount) external{
        //bookkeeping to do beforehand
        accruedRewards[msg.sender] = accruedRewards[msg.sender] + stakes[msg.sender][delegate].stakedAmount*(block.timestamp - stakes[msg.sender][delegate].stakedTime);
        //need to use a lookup here staker->delegate->amount *** self staking will have staker==delegate
        stakes[msg.sender][delegate].stakedAmount = stakes[msg.sender][delegate].stakedAmount+ ISTAKING(staking).stakeFor(delegate, msg.sender, amount);
        //bookkeeping
        stakes[msg.sender][delegate].stakedTime = block.timestamp;        
    }
    function unstakeFor(address delegate, uint256 amount) external {
        //do bookkeeping
        accruedRewards[msg.sender] = accruedRewards[msg.sender] + stakes[msg.sender][delegate].stakedAmount*(block.timestamp - stakes[msg.sender][delegate].stakedTime);
        ISTAKING(staking).unstakeFor(delegate, msg.sender, amount);
        stakes[msg.sender][delegate].stakedAmount = stakes[msg.sender][delegate].stakedAmount - amount;
        stakes[msg.sender][delegate].stakedTime = block.timestamp;        
    }

    function claim() external{
        uint256 amt = accruedRewards[msg.sender];
        accruedRewards[msg.sender] = 0;
        IERC20(token).transfer(msg.sender, amt);
    }


}