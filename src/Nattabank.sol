// SPDX-License-Identifier: BUSL1.1

pragma solidity 0.8.14;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";

contract Nattabank is OwnableUpgradeable, ReentrancyGuardUpgradeable {

  struct AccountInfo {
    string accountName;
    uint256 amount;
  }

  mapping(address => mapping(string => AccountInfo)) public accountInfo;

  /// @notice Upgradeable's initialization function
  function initialize() external initializer {
    // Initialize the contract.
    // This function is called by the constructor.
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
  }

  function createAccount() external {}

  function deposit() external {}

  function withdraw() external {}

  function transferMultipleAcc() external {}
}
