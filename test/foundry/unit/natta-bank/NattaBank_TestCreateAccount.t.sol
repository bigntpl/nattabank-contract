// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "./NattaBankBaseTest.t.sol";

// solhint-disable
contract NattaBank_TestCreateAccount is NattaBankBaseTest {
  event CreateAccount(address caller, string accountName);

  /// @dev foundry's setUp method
  function setUp() public override {
    super.setUp();
  }

  function test_WhenCreateAccountSuccess() external {
    vm.startPrank(ALICE);
    string memory accountName = "Hello World";
    vm.expectEmit(true, true, true, true);
    emit CreateAccount(ALICE, accountName);
    nattaBank.createAccount(accountName);

    (string memory _accName1, ) = nattaBank.accountInfo(ALICE, 0);
    assertEq(accountName, _accName1);
    assertEq(1, nattaBank.getAccountLength());

    vm.stopPrank();
  }

  function test_WhenCreateMultipleAccountsSuccess() external {
    vm.startPrank(ALICE);
    string[] memory accountName = new string[](3);
    accountName[0] = "Hello World";
    accountName[1] = "Nattapon";
    accountName[2] = "NattaBankFounder";

    // Alice create multiple accounts
    for (uint8 i = 0; i < accountName.length; i++) {
      vm.expectEmit(true, true, true, true);
      emit CreateAccount(ALICE, accountName[i]);
      nattaBank.createAccount(accountName[i]);
    }

    for (uint8 i = 0; i < nattaBank.getAccountLength(); i++) {
      (string memory _accName, ) = nattaBank.accountInfo(ALICE, i);
      assertEq(accountName[i], _accName);
    }
    assertEq(accountName.length, nattaBank.getAccountLength());

    vm.stopPrank();
  }

  function test_WhenCreateExistedAccountName() external {
    vm.startPrank(ALICE);
    string memory accountName1 = "Hello World";
    string memory accountName2 = "Hello World";
    nattaBank.createAccount(accountName1);
    vm.expectRevert(NattaBank.NattaBank_NoExistedAccountNameIsAllowed.selector);
    nattaBank.createAccount(accountName2);
    vm.stopPrank();
  }

  function test_WhenMultipleUserCreateAccount() external {
    string memory accountName1 = "Alice Account";
    string memory accountName2 = "Bob Account";

    vm.startPrank(ALICE);
    vm.expectEmit(true, true, true, true);
    emit CreateAccount(ALICE, accountName1);
    nattaBank.createAccount(accountName1);

    (string memory _accName1, ) = nattaBank.accountInfo(ALICE, 0);
    assertEq(accountName1, _accName1);
    assertEq(1, nattaBank.getAccountLength());
    vm.stopPrank();

    vm.startPrank(BOB);
    vm.expectEmit(true, true, true, true);
    emit CreateAccount(BOB, accountName2);
    nattaBank.createAccount(accountName2);

    (string memory _accName2, ) = nattaBank.accountInfo(BOB, 0);
    assertEq(accountName2, _accName2);
    assertEq(1, nattaBank.getAccountLength());
    vm.stopPrank();
  }

  function test_WhenMultipleUsersCreateTheSameAccountName() external {
    string memory accountName1 = "Alice Account";
    string memory accountName2 = "Alice Account";

    vm.startPrank(ALICE);
    vm.expectEmit(true, true, true, true);
    emit CreateAccount(ALICE, accountName1);
    nattaBank.createAccount(accountName1);

    (string memory _accName1, ) = nattaBank.accountInfo(ALICE, 0);
    assertEq(accountName1, _accName1);
    assertEq(1, nattaBank.getAccountLength());
    vm.stopPrank();

    vm.startPrank(BOB);
    vm.expectRevert(NattaBank.NattaBank_NoExistedAccountNameIsAllowed.selector);
    nattaBank.createAccount(accountName2);
    vm.stopPrank();
  }
}
