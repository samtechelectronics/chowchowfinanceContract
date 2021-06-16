// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

contract poofdefifarm {
    
    IERC20 private _token;
    address  _devPool;
    uint _percentageReturn ;
    uint _woofPeriod;
    address payable owner;
    
    address nextOwner;
    bool canSetContract;
    struct chow {
        address payable chowaddress;
        uint amount;
        uint releaseDate;
        bool active;
        uint percentageReturn;
    }
    struct breeder {
        bool active;
        address payable breederaddress;
        uint totalvaluelocked;
        uint[] breedids;
        mapping (uint => chow) chows;
        
    }
    
    mapping( address => breeder) breeders;
    
    constructor(  uint percentage , uint woofPeriod , address devpool )  {
           _devPool = devpool;
           canSetContract = true;
           _percentageReturn = percentage;
           _woofPeriod = woofPeriod;
           owner = payable(msg.sender);
     
        
    }
    function setChowChowContract(IERC20 token) external onlyOwner {
        require (canSetContract, "Contract can only be set once");
        _token = token;
        canSetContract = false;
    }
    function changeDevPool(address devpool) external onlyOwner {
        _devPool = devpool;
    }
    modifier onlyOwner {
        require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }
     modifier ContractReady {
        require (!canSetContract, "Contract not ready");
        _;
    }
    function approveNextOwner(address _nextOwner) external onlyOwner {
        require (_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() external {
        require (msg.sender == nextOwner, "Can only accept preapproved new owner.");
        owner = payable(nextOwner);
    }
    
    function changePercentage(uint percentage) public onlyOwner {
        require(percentage != 0 && !(percentage > 100 ), "percentage should be in the range 1 -100");
        _percentageReturn = percentage;
    }
    function changePoofPeriod(uint woofPeriod) public onlyOwner {
         _woofPeriod = woofPeriod;
    }
    function breedMyChowChow(uint amount , uint breedId) public  ContractReady {
        require(_token.balanceOf(msg.sender) >= amount && amount > 0 , "insuficient funds");
        _token.transferFrom(msg.sender, address(this), amount);
        breeder storage chowbreeder =  breeders[msg.sender];
        chow storage breederchow = chowbreeder.chows[breedId];
        breederchow.chowaddress = payable(msg.sender);
        breederchow.amount += amount;
        breederchow.releaseDate +=  block.timestamp + _woofPeriod * 1 days;
        breederchow.active = true; 
        breederchow.percentageReturn = _percentageReturn ;
        chowbreeder.breederaddress = payable(msg.sender);
        chowbreeder.totalvaluelocked += amount;
        chowbreeder.active = true;
        chowbreeder.breedids.push(breedId);
        
    }
    
    function claimMyChowChow(uint breedId) public  ContractReady{
        breeder storage chowbreeder = breeders[msg.sender];
       
       
        require(chowbreeder.active && chowbreeder.totalvaluelocked > 0, "You have no chow to claim");
        chow storage breederchow = chowbreeder.chows[breedId];
        require(breederchow.active && breederchow.amount > 0, "You have no chow to claim");
        uint256 valuePayableBeforeTax =breederchow.amount + ( breederchow.amount * breederchow.percentageReturn / 100);
        uint256 burnValue = valuePayableBeforeTax * 15 / 1000;
        uint256 devValue  = valuePayableBeforeTax * 15 / 1000;
        uint256 valuePayableAfterTax = valuePayableBeforeTax * 93 / 100;
         require(_token.balanceOf(address(this)) >  valuePayableBeforeTax , "Although your Breeding Period is over the pool is a little bit down hold on for a while." );
         _token.transfer(breederchow.chowaddress ,   valuePayableAfterTax);
         _token.transfer(_devPool ,   devValue);
         _token.burn(burnValue);
        //  _token.transfer(breederchow.chowaddress ,   developerContribution);
         chowbreeder.totalvaluelocked -= breederchow.amount;
          breederchow.amount = 0;
          breederchow.active = false;
    }
     function claimMyChowChowEarlier(uint breedId) public ContractReady{
        breeder storage chowbreeder = breeders[msg.sender];
       
        require(chowbreeder.active && chowbreeder.totalvaluelocked > 0, "You have no chow to claim");
        chow storage breederchow = chowbreeder.chows[breedId];
        require(breederchow.active && breederchow.amount > 0, "You have no chow to claim");
        uint256 valuePayableBeforeTax =breederchow.amount ;
        uint256 burnValue = valuePayableBeforeTax * 1 / 100;
        uint256 devValue  = valuePayableBeforeTax * 2 / 100;
        uint256 valuePayableAfterTax = valuePayableBeforeTax * 93 / 100;
         require(_token.balanceOf(address(this)) >  valuePayableBeforeTax , "the pool is a little bit down hold on for a while." );
         _token.transfer(breederchow.chowaddress ,   valuePayableAfterTax);
         _token.transfer(_devPool ,   devValue);
         _token.burn(burnValue);
        //  _token.transfer(breederchow.chowaddress ,   developerContribution);
         chowbreeder.totalvaluelocked -= breederchow.amount;
          breederchow.amount = 0;
          breederchow.active = false;
    }
    
    function getMyBreedIds() public view returns(uint[] memory) {
        breeder storage chowbreeder = breeders[msg.sender];
        return chowbreeder.breedids;
    }
    
     function getPercentage() public view returns(uint) {
        
        return _percentageReturn;
    }
     function getWoofPeriod() public view returns(uint) {
        
        return _woofPeriod;
    }
    function myTotalValueLocked() public view returns (uint){
          breeder storage chowbreeder = breeders[msg.sender];
        return chowbreeder.totalvaluelocked;
    }
    function chowStatus(uint breedid) public view returns (bool){
          breeder storage chowbreeder = breeders[msg.sender];
        return chowbreeder.chows[breedid].active;
    }

      function getMychow(uint breedid) public view returns (address , uint , uint , bool ,uint){
          breeder storage chowbreeder = breeders[msg.sender];
         chow storage activechow = chowbreeder.chows[breedid];
         return (activechow.chowaddress , activechow.amount, activechow.releaseDate , activechow.active , activechow.percentageReturn );
    }
     function TotalActiveChows() public view returns (uint) {
          breeder storage chowbreeder = breeders[msg.sender];
         uint totalActive;
         for(uint i = 0 ; i < chowbreeder.breedids.length ; i ++){
             if(chowbreeder.chows[chowbreeder.breedids[i]].active) {
                 totalActive= totalActive + 1;
             }
         }
         return totalActive;
    }
    function poolBalance() ContractReady public view ContractReady returns (uint)  { 
        
    return _token.balanceOf(address(this)) ;
    }
}
interface IERC20 {
    function burn(uint256 amount) external  returns (bool);
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}