// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "./NattaBankBaseTest.t.sol";

// solhint-disable
contract NattaBank_TestDeposit is NattaBankBaseTest {
  event Deposit(string accountName, uint256 amount);

  /// @dev foundry's setUp method
  function setUp() public override {
    super.setUp();

    // Mint some token to Alice
    erc20Token.mint(ALICE, 10000e18);
    vm.startPrank(ALICE);
    // Pretend to be Alice and create 3 accounts
    _createAccountHelper(3);
    vm.stopPrank();
  }

  function test_WhenDepositSuccess() external {
    uint256 depositAmount = 500e18;
    string memory accountName = "Account 1";

    (, uint256 accountInfoAmountBeforeDeposit) = nattaBank.accountInfo(
      ALICE,
      0
    );
    uint256 amountInWalletBeforeDeposit = erc20Token.balanceOf(ALICE);
    uint256 allBalanceBeforeDeposit = nattaBank.allBalance();

    // Pretend to be Alice and deposit erc20Token
    vm.startPrank(ALICE);
    erc20Token.approve(address(nattaBank), depositAmount);
    vm.expectEmit(true, true, true, true);
    emit Deposit(accountName, depositAmount);
    nattaBank.deposit(depositAmount, accountName);
    vm.stopPrank();

    (, uint256 accountInfoAmountAfterDeposit) = nattaBank.accountInfo(ALICE, 0);
    uint256 amountInWalletAfterDeposit = erc20Token.balanceOf(ALICE);
    uint256 allBalanceAfterDeposit = nattaBank.allBalance();

    assertEq(
      accountInfoAmountAfterDeposit,
      accountInfoAmountBeforeDeposit + depositAmount
    );
    assertEq(
      amountInWalletAfterDeposit,
      amountInWalletBeforeDeposit - depositAmount
    );
    assertEq(allBalanceAfterDeposit, allBalanceBeforeDeposit + depositAmount);
  }

  function test_WhenDepositSuccessWithFuzzyAmount(uint256 _depositAmount)
    external
  {
    _depositAmount = bound(_depositAmount, 1e18, 10000e18);
    string memory accountName = "Account 1";

    (, uint256 accountInfoAmountBeforeDeposit) = nattaBank.accountInfo(
      ALICE,
      0
    );
    uint256 amountInWalletBeforeDeposit = erc20Token.balanceOf(ALICE);
    uint256 allBalanceBeforeDeposit = nattaBank.allBalance();

    // Pretend to be Alice and deposit with fuzzy amount 1 - 10000 of Tokens
    vm.startPrank(ALICE);
    erc20Token.approve(address(nattaBank), _depositAmount);
    vm.expectEmit(true, true, true, true);
    emit Deposit(accountName, _depositAmount);
    nattaBank.deposit(_depositAmount, accountName);
    vm.stopPrank();

    (, uint256 accountInfoAmountAfterDeposit) = nattaBank.accountInfo(ALICE, 0);
    uint256 amountInWalletAfterDeposit = erc20Token.balanceOf(ALICE);
    uint256 allBalanceAfterDeposit = nattaBank.allBalance();

    assertEq(
      accountInfoAmountAfterDeposit,
      accountInfoAmountBeforeDeposit + _depositAmount
    );
    assertEq(
      amountInWalletAfterDeposit,
      amountInWalletBeforeDeposit - _depositAmount
    );
    assertEq(allBalanceAfterDeposit, allBalanceBeforeDeposit + _depositAmount);
  }

  function test_WhenDepositSuccess_WithMultipleAccounts() external {
    // didn't set depositamount1 because it's stack too deep :(
    uint256 depositAmount2 = 1000e18;
    string memory accountName1 = "Account 1";
    string memory accountName2 = "Account 2";

    (, uint256 firstAccountInfoAmountBeforeDeposit) = nattaBank.accountInfo(
      ALICE,
      0
    );
    (, uint256 secondAccountInfoAmountBeforeDeposit) = nattaBank.accountInfo(
      ALICE,
      1
    );
    uint256 amountInWalletBefore1stDeposit = erc20Token.balanceOf(ALICE);
    uint256 allBalanceBeforeFirstDeposit = nattaBank.allBalance();

    // Pretend to be Alice and deposit first time with 500 amount of Tokens
    vm.startPrank(ALICE);
    erc20Token.approve(address(nattaBank), 500e18);
    vm.expectEmit(true, true, true, true);
    emit Deposit(accountName1, 500e18);
    nattaBank.deposit(500e18, accountName1);
    vm.stopPrank();

    (, uint256 firstAccountInfoAmountAfterDeposit) = nattaBank.accountInfo(
      ALICE,
      0
    );
    uint256 amountInWalletAfterDepositFirstAccount = erc20Token.balanceOf(
      ALICE
    );
    uint256 allBalanceAfterFirstDeposit = nattaBank.allBalance();

    assertEq(
      firstAccountInfoAmountAfterDeposit,
      firstAccountInfoAmountBeforeDeposit + 500e18
    );
    assertEq(
      amountInWalletAfterDepositFirstAccount,
      amountInWalletBefore1stDeposit - 500e18
    );
    assertEq(
      allBalanceAfterFirstDeposit,
      allBalanceBeforeFirstDeposit + 500e18
    );

    // Pretend to be Alice and deposit first time with 1000 amount of Tokens
    vm.startPrank(ALICE);
    erc20Token.approve(address(nattaBank), depositAmount2);
    vm.expectEmit(true, true, true, true);
    emit Deposit(accountName2, depositAmount2);
    nattaBank.deposit(depositAmount2, accountName2);
    vm.stopPrank();

    (, uint256 secondAccountInfoAmountAfterDeposit) = nattaBank.accountInfo(
      ALICE,
      1
    );
    uint256 amountInWalletAfterDepositSecondAccount = erc20Token.balanceOf(
      ALICE
    );
    uint256 allBalanceAfterSecondDeposit = nattaBank.allBalance();

    assertEq(
      secondAccountInfoAmountAfterDeposit,
      secondAccountInfoAmountBeforeDeposit + depositAmount2
    );
    assertEq(
      amountInWalletAfterDepositSecondAccount,
      amountInWalletBefore1stDeposit - 500e18 - depositAmount2
    );
    assertEq(
      allBalanceAfterSecondDeposit,
      allBalanceBeforeFirstDeposit + 500e18 + depositAmount2
    );
  }

  function test_WhenAmountIsInvalid() external {
    vm.startPrank(ALICE);
    vm.expectRevert(NattaBank.NattaBank_InvalidDepositingAmount.selector);
    nattaBank.deposit(0, "Account 1");
    vm.stopPrank();
  }
}
