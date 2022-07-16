// SPDX-License-Identifier: BUSL1.1

pragma solidity 0.8.14;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";

contract NattaBank is OwnableUpgradeable, ReentrancyGuardUpgradeable {
  // dev errors
  error NattaBank_NoExistedAccountNameIsAllowed();
  // dev events
  event CreateAccount(address caller, string accountName);

  struct AccountInfo {
    string accountName;
    uint256 amount;
  }

  IERC20Upgradeable public NTToken;
  mapping(address => AccountInfo[]) public accountInfo;

  /// @notice Upgradeable's initialization function
  function initialize(address _NTToken) external initializer {
    // Initialize the contract.
    // This function is called by the constructor.
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();

    NTToken = IERC20Upgradeable(_NTToken);
  }

  function getAccountLength() public view returns (uint256) {
    return accountInfo[msg.sender].length;
  }

  function createAccount(string memory _accountName) external {
    for (uint8 i = 0; i < getAccountLength(); i++) {
      string memory accountName = accountInfo[msg.sender][i].accountName;
      if (keccak256(bytes(accountName)) == keccak256(bytes(_accountName))) {
        revert NattaBank_NoExistedAccountNameIsAllowed();
      }
    }

    accountInfo[msg.sender].push(
      AccountInfo({ accountName: _accountName, amount: 0 })
    );

    emit CreateAccount(msg.sender, _accountName);
  }

  function deposit() external {}

  function withdraw() external {}

  function transferMultipleAcc() external {}
}
