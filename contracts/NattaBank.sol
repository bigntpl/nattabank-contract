// SPDX-License-Identifier: BUSL1.1

pragma solidity 0.8.14;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";

contract NattaBank is OwnableUpgradeable, ReentrancyGuardUpgradeable {
  using SafeERC20Upgradeable for IERC20Upgradeable;

  // dev errors
  error NattaBank_NoExistedAccountNameIsAllowed();
  error NattaBank_InvalidDepositAmount();
  error NattaBank_InvalidWithdrawalAmount();
  error NattaBank_AccountNameNotFound();

  // dev events
  event CreateAccount(address caller, string accountName);
  event Deposit(string accountName, uint256 amount);
  event Withdraw(string accountName, uint256 amount);

  struct AccountInfo {
    string accountName;
    uint256 amount;
  }

  IERC20Upgradeable public erc20Token;
  uint256 public allBalance;
  mapping(address => AccountInfo[]) public accountInfo;

  /// @notice Upgradeable's initialization function
  /// @param _erc20Token address of ERC20 token
  function initialize(address _erc20Token) external initializer {
    // Initialize the contract.
    // This function is called by the constructor.
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();

    erc20Token = IERC20Upgradeable(_erc20Token);
  }

  /// @dev function for viewing length of accountInfo
  function getAccountLength() public view returns (uint256) {
    return accountInfo[msg.sender].length;
  }

  /// @dev function for retrieve account Id for accountName given
  /// @param _accountName account name that wants to be retrieved
  function getAccountId(string calldata _accountName)
    public
    view
    returns (uint256)
  {
    uint256 i;
    for (i = 0; i < getAccountLength(); i++) {
      string memory accountName = accountInfo[msg.sender][i].accountName;
      if (keccak256(bytes(accountName)) == keccak256(bytes(_accountName))) {
        return i;
      }
    }
    revert NattaBank_AccountNameNotFound();
  }

  /// @dev function for creating bank account
  /// @param _accountName account name for creating bank account
  function createAccount(string calldata _accountName) external {
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

  /// @dev function for deposit token to bank account
  /// @param _amount amount to deposit
  /// @param _accountName account name for depositing token
  function deposit(uint256 _amount, string calldata _accountName)
    external
    nonReentrant
  {
    if (_amount == 0) {
      revert NattaBank_InvalidDepositAmount();
    }

    uint256 accountId = getAccountId(_accountName);
    accountInfo[msg.sender][accountId].amount += _amount;
    allBalance += _amount;

    erc20Token.safeTransferFrom(msg.sender, address(this), _amount);

    emit Deposit(_accountName, _amount);
  }

  /// @dev function for withdraw token from bank account
  /// @param _amount amount to withdraw
  /// @param _accountName account name for withdrawing token
  function withdraw(uint256 _amount, string calldata _accountName)
    external
    nonReentrant
  {
    uint256 accountId = getAccountId(_accountName);
    if (_amount > accountInfo[msg.sender][accountId].amount || _amount == 0) {
      revert NattaBank_InvalidWithdrawalAmount();
    }

    accountInfo[msg.sender][accountId].amount -= _amount;
    allBalance -= _amount;

    erc20Token.safeTransferFrom(address(this), msg.sender, _amount);

    emit Withdraw(_accountName, _amount);
  }

  function transferMultipleAcc() external {}
}
