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
    
    event Deposit(address from, address to, uint amount, uint when);
    event Claim(address from, address to, uint amount, uint when);
    event ValueReceived(address from, uint amount, uint when);

    function _getErc20BalanceOf(address _token) internal view returns (uint256){
      return IERC20(_token).balanceOf(address(this));
    }

    function deposit(address _token, uint256 _amount) public {
      IERC20(_token).transferFrom(msg.sender, address(this), _amount);

      contributors.push();
	    uint256 newIndex = contributors.length - 1;
	    contributors[newIndex].user = msg.sender;
      contributors[newIndex].amount = _amount;

      emit Deposit(msg.sender, address(this), _amount, block.timestamp); 
    }


    function claim(address _token, address _targetUser) public onlyOwner {
      uint256 carOilBalance = _getErc20BalanceOf(_token);

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
       
      emit Claim(address(this), _targetUser ,carOilBalance, block.timestamp);
    }

    function withdraw(address payable _to, uint256 _amount) public onlyOwner {
      (bool sent,) = _to.call{value: _amount}("");
      require(sent, "Failed to send BNB");
    }

    function history() external view returns (ClaimHistory[] memory) {
      return claimHistories;
    }

    function contributor() external view returns (Contributor[] memory) {
      return contributors;
    }

    function nativeBalance() external view returns (uint256) {
      return address(this).balance;
    }

    receive() external payable {
      emit ValueReceived(msg.sender, msg.value, block.timestamp);
    }
}
