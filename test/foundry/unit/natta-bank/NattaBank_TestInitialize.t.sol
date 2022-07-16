// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.14;

import "./NattaBankBaseTest.t.sol";

contract NattaBank_TestInitialize is NattaBankBaseTest {
  /// @dev foundry's setUp method
  function setUp() public override {
    // testInitialize involves no setUp()
  }

  function test_WhenInitializeSuccess() external {
    erc20Token = _setupFakeERC20("ERC20 Token", "ERC20");

    NattaBank _impl = new NattaBank();

    TransparentUpgradeableProxy _proxy = new TransparentUpgradeableProxy(
      address(_impl),
      address(proxyAdmin),
      abi.encodeWithSelector(bytes4(keccak256("initialize(address)")), erc20Token)
    );
    nattaBank = NattaBank(payable(_proxy));

    assertEq(erc20Token.name(), "ERC20 Token");
    assertEq(erc20Token.symbol(), "ERC20");

    assertEq(address(nattaBank.erc20Token()), address(erc20Token));
  }
}
