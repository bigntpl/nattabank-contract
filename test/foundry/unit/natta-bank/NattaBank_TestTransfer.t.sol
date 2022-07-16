// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "./NattaBankBaseTest.t.sol";

// solhint-disable
contract NattaBank_TestTransfer is NattaBankBaseTest {
  using FixedPointMathLib for uint256;

  event Transfer(address to, string accountName, uint256 amount);

  /// @dev foundry's setUp method
  function setUp() public override {
    super.setUp();

    // Mint some token to Alice
    erc20Token.mint(ALICE, 10000e18);
    erc20Token.mint(BOB, 10000e18);

    vm.startPrank(ALICE);
    // Pretend to be Alice and create 3 accounts
    _createAccountHelper("Alice", 3);
    erc20Token.approve(address(nattaBank), 10000e18);
    nattaBank.deposit(3000e18, "Alice 1");
    nattaBank.deposit(3000e18, "Alice 2");
    vm.stopPrank();

    vm.startPrank(BOB);
    // Pretend to be Bob and create 3 accounts
    _createAccountHelper("Bob", 3);
    erc20Token.approve(address(nattaBank), 10000e18);
    nattaBank.deposit(3000e18, "Bob 1");
    nattaBank.deposit(3000e18, "Bob 2");
    vm.stopPrank();
  }

  function test_WhenTransferSuccessToOtherAccount() external {
    uint256 transferAmount = 1000e18;
    uint256 feeAmount = transferAmount.mulWadDown(1e16);
    uint256 transferAmountAfterDeducted = transferAmount - feeAmount;

    (, uint256 aliceAccountInfoAmountBeforeTransfer) = nattaBank.accountInfo(
      ALICE,
      0
    );
    (, uint256 bobAccountInfoAmountBeforeTransfer) = nattaBank.accountInfo(
      BOB,
      1
    );
    uint256 platformFeeBeforeUserTransfer = nattaBank.platformFee();

    vm.startPrank(ALICE);
    (address ownerAddress, ) = nattaBank.findOwnerOfAccount("Bob 2");
    vm.expectEmit(true, true, true, true);
    emit Transfer(ownerAddress, "Bob 2", transferAmountAfterDeducted);
    nattaBank.transfer("Alice 1", "Bob 2", transferAmount);
    vm.stopPrank();

    (, uint256 aliceAccountInfoAmountAfterTransfer) = nattaBank.accountInfo(
      ALICE,
      0
    );
    (, uint256 bobAccountInfoAmountAfterTransfer) = nattaBank.accountInfo(
      BOB,
      1
    );
    uint256 platformFeeAfterUserTransfer = nattaBank.platformFee();

    assertEq(
      aliceAccountInfoAmountAfterTransfer,
      aliceAccountInfoAmountBeforeTransfer - transferAmount
    );
    assertEq(
      bobAccountInfoAmountAfterTransfer,
      bobAccountInfoAmountBeforeTransfer + transferAmountAfterDeducted
    );
    assertEq(
      platformFeeAfterUserTransfer,
      platformFeeBeforeUserTransfer + feeAmount
    );
  }
}
