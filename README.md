# VotingPower

This contract is for computing the voting power score of governance token holders (e.g. for an offchain Snapshot vote).

There are three mechanisms through which a token holder can gain voting power with their tokens
1) lock up their tokens for a period of time (see ITOKENLOCK)
2) stake their tokens directly on this contract 
3) stake through a staking proxy contract which could offer rewards or yield for staking

For holders with locked tokens a scaling factor serves to reduce or increase the voting power of locked tokens.
The scaling factor changes over time, and is looked up based on the current blocktime.

Assumptions:
The deployer is responsible for supplying a governance token_ implementing ERC20 and ILOCKER. 
The deployer is trusted to know & have verified the token code token code is appropriate.


## constructor(address token_, bytes memory scaling_, uint256 epoch_)
initialize the contract
token_ is the token that is staked or locked to get voting power
scaling_ is an array of uint8 (bytes) percentage discounts for each epoch
epoch_ is the duration of one epoch in seconds

## function votingPower(address who) public view returns (uint256) 
Returns the voting power for `who`
who indicates the address whose votingPower to compute
returns the voting power for who
    
## function stake(uint256 amount) external override nonReentrant returns (uint256)
Stakes the specified `amount` of tokens, this will attempt to transfer the given amount from the caller.
It will count the actual number of tokens trasferred as being staked
MUST emit Staked event.
Returns the number of tokens actually staked

## function stakeFor(address voter, address staker, uint256 amount) external override nonReentrant returns (uint256)
Stakes the specified `amount` of tokens from `staker` on behalf of address `voter`,
this will attempt to transfer the given amount from the calling contract.
Must be called from an ISTAKINGPROXY contract that has been approved by `staker`.
Tokens will be staked towards the voting power of address `voter` allowing one address to delegate voting power to another. 
It will count the actual number of tokens trasferred as being staked
MUST trigger Staked event.
Returns the number of tokens actually staked

## function unstake(uint256 amount) public nonReentrant
Unstakes the specified `amount` of tokens, this SHOULD return the given amount of tokens to the caller, 
MUST trigger Unstaked event.

## function unstakeFor(address voter, address staker, uint256 amount) external override nonReentrant
Unstakes the specified `amount` of tokens currently staked by `staker` on behalf of `voter`, 
this SHOULD return the given amount of tokens to the calling contract
calling contract is responsible for returning tokens to `staker` if applicable.
MUST trigger Unstaked event.
    
## function totalStakedFor(address addr) external override view returns (uint256)
Returns the current total of tokens staked for address `addr`.

## function stakedFor(address voter, address staker) external override view returns (uint256)
Returns the current tokens staked by address `staker` for address `voter`.

## function totalStaked() public view returns (uint256)
Returns the number of current total tokens staked.
   
## function token() public view returns (address){
address of the token being used by the staking interface
