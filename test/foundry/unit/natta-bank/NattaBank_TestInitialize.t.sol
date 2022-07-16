// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.14;

import "./NattaBankBaseTest.t.sol";

contract NattaBank_TestInitialize is NattaBankBaseTest {
  /// @dev foundry's setUp method
  function setUp() public override {
    // testInitialize involves no setUp()
  }

  function test_WhenInitializeSuccess() external {
    ntToken = _setupFakeERC20("NT Token", "NT");

    NattaBank _impl = new NattaBank();

    TransparentUpgradeableProxy _proxy = new TransparentUpgradeableProxy(
      address(_impl),
      address(proxyAdmin),
      abi.encodeWithSelector(bytes4(keccak256("initialize(address)")), ntToken)
    );
    nattaBank = NattaBank(payable(_proxy));

    assertEq(ntToken.name(), "NT Token");
    assertEq(ntToken.symbol(), "NT");

    assertEq(address(nattaBank.NTToken()), address(ntToken));
  }
}
