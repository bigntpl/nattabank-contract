// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "./NattaBankBaseTest.t.sol";

// solhint-disable
contract NattaBank_TestCreateAccount is NattaBankBaseTest {
  using SafeCastUpgradeable for uint256;

  /// @dev foundry's setUp method
  function setUp() public override {
    super.setUp();
  }

  function testExample() external {
    assertTrue(true);
  }
}
