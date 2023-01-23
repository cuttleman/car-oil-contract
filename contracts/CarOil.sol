// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract CarOil is Ownable {
    struct Contributor {
      address user;
      uint256 amount;
    }
    struct ClaimHistory { 
      uint when;
      uint256 totalAmount;
      Contributor[] contributors;
   }

    ClaimHistory[] claimHistories;
    Contributor[] contributors;

    uint32 round;
    // erc20 address => true/false
    mapping (address => bool) whitelist;
    
    event Deposit(address from, address to, uint amount, uint when);
    event Claim(address from, address to, uint amount, uint when);
    event Withdraw(address to, uint amount, uint when);
    event ValueReceived(address from, uint amount, uint when);
    event SetWhitelist(address token, uint when);

    constructor() Ownable() {
      round = 1;
    }

    // deposit erc20 token
    function deposit(address _token, uint256 _amount) public {
      require(whitelist[_token], "That token is a disallowed token.");

      IERC20(_token).transferFrom(msg.sender, address(this), _amount);

      contributors.push();
	    uint256 newIndex = contributors.length - 1;
	    contributors[newIndex].user = msg.sender;
      contributors[newIndex].amount = _amount;

      emit Deposit(msg.sender, address(this), _amount, block.timestamp); 
    }

    // withdraw erc20 token
    function claim(address _token, address _targetUser) public onlyOwner {
      require(whitelist[_token], "That token is a disallowed token.");

      uint256 carOilBalance = getErc20Balance(_token);

      IERC20 erc20 = IERC20(_token);
      uint256 allowance = erc20.allowance(address(this), address(this));
      
      if (allowance < carOilBalance) {
        erc20.approve(address(this), carOilBalance);
      }
      
      IERC20(_token).transferFrom(address(this), _targetUser, carOilBalance);

      claimHistories.push();
	    uint256 newIndex = claimHistories.length - 1;
	    claimHistories[newIndex].when = block.timestamp;
      claimHistories[newIndex].totalAmount = carOilBalance;
      claimHistories[newIndex].contributors = contributors;

      delete contributors;

      round++;
       
      emit Claim(address(this), _targetUser ,carOilBalance, block.timestamp);
    }

    // withdraw native token
    function withdraw(address payable _to, uint256 _amount) public onlyOwner {
      (bool sent,) = _to.call{value: _amount}("");

      require(sent, "Failed to send BNB");

      emit Withdraw(_to, _amount, block.timestamp);
    }

    function setWhitelist(address _token) public onlyOwner {
      require(whitelist[_token], "already added.");
      
      whitelist[_token] = true;

      emit SetWhitelist(_token, block.timestamp);
    }

    function checkWhitelist(address _token) public view returns (bool){
      return whitelist[_token];
    }

    // view claim history
    function getHistory() external view returns (ClaimHistory[] memory) {
      return claimHistories;
    }

    // view contributors of current round
    function getContributor() external view returns (Contributor[] memory) {
      return contributors;
    }

    // view current round
    function getCurrentRound() external view returns (uint32) {
      return round;
    }

    // view balance of native token
    function getNativeBalance() external view returns (uint256) {
      return address(this).balance;
    }

    function getErc20Balance(address _token) public view returns (uint256){
      return IERC20(_token).balanceOf(address(this));
    }

    // native receiver
    receive() external payable {
      emit ValueReceived(msg.sender, msg.value, block.timestamp);
    }
}
