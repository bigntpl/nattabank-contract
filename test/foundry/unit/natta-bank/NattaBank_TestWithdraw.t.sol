// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "./NattaBankBaseTest.t.sol";

// solhint-disable
contract NattaBank_TestWithdraw is NattaBankBaseTest {
  event Withdraw(string accountName, uint256 amount);

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

  function test_WhenWithdrawSuccess() external {
    uint256 withdrawalAmount = 500e18;
    string memory accountName = "Account 1";

    // Prepare test scenario:
    // assuming the deposit function working properly
    // Pretend to be Alice and deposit to the account
    vm.startPrank(ALICE);
    erc20Token.approve(address(nattaBank), 10000e18);
    nattaBank.deposit(10000e18, accountName);
    vm.stopPrank();

    (, uint256 accountInfoAmountBeforeWithdrawal) = nattaBank.accountInfo(
      ALICE,
      0
    );
    uint256 amountInWalletBeforeWithdrawal = erc20Token.balanceOf(ALICE);
    uint256 allBalanceBeforeWithdrawal = nattaBank.allBalance();

    // Pretend to be Alice and withdraw with 500 Tokens
    vm.startPrank(ALICE);
    vm.expectEmit(true, true, true, true);
    emit Withdraw(accountName, withdrawalAmount);
    nattaBank.withdraw(withdrawalAmount, accountName);
    vm.stopPrank();

    (, uint256 accountInfoAmountAfterWithdrawal) = nattaBank.accountInfo(
      ALICE,
      0
    );
    uint256 amountInWalletAfterWithdrawal = erc20Token.balanceOf(ALICE);
    uint256 allBalanceAfterWithdrawal = nattaBank.allBalance();

    assertEq(
      accountInfoAmountAfterWithdrawal,
      accountInfoAmountBeforeWithdrawal - withdrawalAmount
    );
    assertEq(
      amountInWalletAfterWithdrawal,
      amountInWalletBeforeWithdrawal + withdrawalAmount
    );
    assertEq(
      allBalanceAfterWithdrawal,
      allBalanceBeforeWithdrawal - withdrawalAmount
    );
  }

  function test_WhenWithdrawSuccessWithFuzzyAmount(uint256 _withdrawalAmount)
    external
  {
    _withdrawalAmount = bound(_withdrawalAmount, 1e18, 10000e18);
    string memory accountName = "Account 1";

    // Prepare test scenario:
    // assuming the deposit function working properly
    // Pretend to be Alice and deposit to the account
    vm.startPrank(ALICE);
    erc20Token.approve(address(nattaBank), 10000e18);
    nattaBank.deposit(10000e18, accountName);
    vm.stopPrank();

    (, uint256 accountInfoAmountBeforeWithdrawal) = nattaBank.accountInfo(
      ALICE,
      0
    );
    uint256 amountInWalletBeforeWithdrawal = erc20Token.balanceOf(ALICE);
    uint256 allBalanceBeforeWithdrawal = nattaBank.allBalance();

    // Pretend to be Alice and withdraw with fuzzy amount 1 - 10000 Tokens
    vm.startPrank(ALICE);
    vm.expectEmit(true, true, true, true);
    emit Withdraw(accountName, _withdrawalAmount);
    nattaBank.withdraw(_withdrawalAmount, accountName);
    vm.stopPrank();

    (, uint256 accountInfoAmountAfterWithdrawal) = nattaBank.accountInfo(
      ALICE,
      0
    );
    uint256 amountInWalletAfterWithdrawal = erc20Token.balanceOf(ALICE);
    uint256 allBalanceAfterWithdrawal = nattaBank.allBalance();

    assertEq(
      accountInfoAmountAfterWithdrawal,
      accountInfoAmountBeforeWithdrawal - _withdrawalAmount
    );
    assertEq(
      amountInWalletAfterWithdrawal,
      amountInWalletBeforeWithdrawal + _withdrawalAmount
    );
    assertEq(
      allBalanceAfterWithdrawal,
      allBalanceBeforeWithdrawal - _withdrawalAmount
    );
  }

  function test_WhenWithdrawSuccess_WithMultipleAccounts() external {
    // didn't set withdrawalAmount1 because it's stack too deep :(
    uint256 withdrawalAmount2 = 1000e18;
    string memory accountName1 = "Account 1";
    string memory accountName2 = "Account 2";

    // Prepare test scenario:
    // assuming the deposit function working properly
    // Pretend to be Alice and deposit to the account1 and account2
    vm.startPrank(ALICE);
    erc20Token.approve(address(nattaBank), 6000e18);
    nattaBank.deposit(6000e18, accountName1);
    erc20Token.approve(address(nattaBank), 4000e18);
    nattaBank.deposit(4000e18, accountName2);
    vm.stopPrank();

    (, uint256 firstAccountInfoAmountBeforeWithdrawal) = nattaBank.accountInfo(
      ALICE,
      0
    );
    (, uint256 secondAccountInfoAmountBeforeWithdrawal) = nattaBank.accountInfo(
      ALICE,
      1
    );
    uint256 amountInWalletBefore1stWithdrawal = erc20Token.balanceOf(ALICE);
    uint256 allBalanceBeforeFirstWithdrawal = nattaBank.allBalance();

    // Pretend to be Alice and withdraw with 500 Tokens
    vm.startPrank(ALICE);
    vm.expectEmit(true, true, true, true);
    emit Withdraw(accountName1, 500e18);
    nattaBank.withdraw(500e18, accountName1);
    vm.stopPrank();

    (, uint256 firstAccountInfoAmountAfterWithdrawal) = nattaBank.accountInfo(
      ALICE,
      0
    );
    uint256 amountInWalletAfterWithdrawalFirstAccount = erc20Token.balanceOf(
      ALICE
    );
    uint256 allBalanceAfterFirstWithdrawal = nattaBank.allBalance();

    assertEq(
      firstAccountInfoAmountAfterWithdrawal,
      firstAccountInfoAmountBeforeWithdrawal - 500e18
    );
    assertEq(
      amountInWalletAfterWithdrawalFirstAccount,
      amountInWalletBefore1stWithdrawal + 500e18
    );
    assertEq(
      allBalanceAfterFirstWithdrawal,
      allBalanceBeforeFirstWithdrawal - 500e18
    );

    // Pretend to be Alice and withdraw with 1000 Tokens
    vm.startPrank(ALICE);
    vm.expectEmit(true, true, true, true);
    emit Withdraw(accountName2, withdrawalAmount2);
    nattaBank.withdraw(withdrawalAmount2, accountName2);
    vm.stopPrank();

    (, uint256 secondAccountInfoAmountAfterWithdrawal) = nattaBank.accountInfo(
      ALICE,
      1
    );
    uint256 amountInWalletAfterWithdrawalSecondAccount = erc20Token.balanceOf(
      ALICE
    );
    uint256 allBalanceAfterSecondWithdrawal = nattaBank.allBalance();

    assertEq(
      secondAccountInfoAmountAfterWithdrawal,
      secondAccountInfoAmountBeforeWithdrawal - withdrawalAmount2
    );
    assertEq(
      amountInWalletAfterWithdrawalSecondAccount,
      amountInWalletBefore1stWithdrawal + 500e18 + withdrawalAmount2
    );
    assertEq(
      allBalanceAfterSecondWithdrawal,
      allBalanceBeforeFirstWithdrawal - 500e18 - withdrawalAmount2
    );
  }

  function test_WhenAmountIsInvalid() external {
    vm.startPrank(ALICE);
    // Alice can't withdraw because Alice didn't deposit any token
    vm.expectRevert(NattaBank.NattaBank_InvalidWithdrawalAmount.selector);
    nattaBank.withdraw(1000, "Account 1");
    vm.stopPrank();
  }
}
