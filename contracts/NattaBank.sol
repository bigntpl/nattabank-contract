// SPDX-License-Identifier: BUSL1.1

pragma solidity 0.8.14;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "../lib/solmate/src/utils/FixedPointMathLib.sol";
import "forge-std/Test.sol";

contract NattaBank is OwnableUpgradeable, ReentrancyGuardUpgradeable {
  using SafeERC20Upgradeable for IERC20Upgradeable;
  using FixedPointMathLib for uint256;

  // dev errors
  error NattaBank_NoExistedAccountNameIsAllowed();
  error NattaBank_InvalidDepositAmount();
  error NattaBank_InvalidWithdrawalAmount();
  error NattaBank_AccountNameNotFound();
  error NattaBank_InsufficientAmountToBeTransferred();
  error NattaBank_NotTheOwnerOfAccount();

  // dev events
  event CreateAccount(address caller, string accountName);
  event Deposit(string accountName, uint256 amount);
  event Withdraw(string accountName, uint256 amount);
  event Transfer(address to, string accountName, uint256 amount);

  struct AccountInfo {
    string accountName;
    uint256 amount;
  }

  IERC20Upgradeable public erc20Token;
  uint256 public allBalance;
  mapping(address => AccountInfo[]) public accountInfo;
  string[] public allAccountNames;
  address[] public allUsers;
  uint256 public platformFee;

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

  function findOwnerOfAccount(string calldata _accountName)
    public
    view
    returns (address, uint256)
  {
    for (uint256 i = 0; i < allUsers.length; i++) {
      for (uint256 j = 0; j < accountInfo[allUsers[i]].length; j++) {
        string memory accountFromAddress = accountInfo[allUsers[i]][j]
          .accountName;
        if (
          keccak256(bytes(accountFromAddress)) == keccak256(bytes(_accountName))
        ) {
          return (allUsers[i], j);
        }
      }
    }
    revert NattaBank_AccountNameNotFound();
  }

  /// @dev function for creating bank account
  /// @param _accountName account name for creating bank account
  function createAccount(string calldata _accountName) external {
    // - CHECK -
    for (uint8 i = 0; i < allAccountNames.length; i++) {
      string memory accountName = allAccountNames[i];
      if (keccak256(bytes(accountName)) == keccak256(bytes(_accountName))) {
        revert NattaBank_NoExistedAccountNameIsAllowed();
      }
    }

    // - EFFECT -
    for (uint8 i = 0; i < allAccountNames.length; i++) {
      if (
        keccak256(bytes(allAccountNames[i])) != keccak256(bytes(_accountName))
      ) {
        allUsers.push(msg.sender);
      }
    }
    allAccountNames.push(_accountName);
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
    // - CHECK -
    if (_amount == 0) {
      revert NattaBank_InvalidDepositAmount();
    }

    // - EFFECT -
    uint256 accountId = getAccountId(_accountName);
    accountInfo[msg.sender][accountId].amount += _amount;
    allBalance += _amount;

    // - INTERACTION -
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
    // - CHECK -
    uint256 accountId = getAccountId(_accountName);
    if (_amount > accountInfo[msg.sender][accountId].amount || _amount == 0) {
      revert NattaBank_InvalidWithdrawalAmount();
    }

    // - EFFECT -
    accountInfo[msg.sender][accountId].amount -= _amount;
    allBalance -= _amount;

    // - INTERACTION -
    erc20Token.safeTransfer(msg.sender, _amount);

    emit Withdraw(_accountName, _amount);
  }

  function transfer(
    string calldata _from,
    string calldata _to,
    uint256 _amount
  ) external {
    // - CHECK -
    (address ownerAddress, uint256 fromAccountId) = findOwnerOfAccount(_from);
    if (msg.sender != ownerAddress) {
      revert NattaBank_NotTheOwnerOfAccount();
    }
    if (_amount > accountInfo[msg.sender][fromAccountId].amount) {
      revert NattaBank_InsufficientAmountToBeTransferred();
    }

    // - EFFECT -
    accountInfo[msg.sender][fromAccountId].amount -= _amount;

    uint256 feeAmount;
    (address receiverAddress, uint256 toAccountId) = findOwnerOfAccount(_to);
    if (receiverAddress != msg.sender) {
      feeAmount = _amount.mulWadDown(1e16);
      _amount = _amount - feeAmount;
    }

    accountInfo[receiverAddress][toAccountId].amount += _amount;
    platformFee += feeAmount;

    emit Transfer(receiverAddress, _to, _amount);
  }
}
