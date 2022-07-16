// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.14;

import "../_base/BaseTest.sol";
import "../_mock/MockERC20.sol";
import "../../../../contracts/NattaBank.sol";

contract NattaBankBaseTest is BaseTest {
  NattaBank nattaBank;
  MockERC20 internal ntToken;

  /// @dev Foundry's setUp method
  function setUp() public virtual {
    ntToken = _setupFakeERC20("NT", "Natta Token");
    nattaBank = _setupNattaBank(address(ntToken));
  }

  // █░█ ▀█▀ █ █░░ █▀
  // █▄█ ░█░ █ █▄▄ ▄█

  function _setupNattaBank(address _NTToken) internal returns (NattaBank) {
    NattaBank _impl = new NattaBank();

    TransparentUpgradeableProxy _proxy = new TransparentUpgradeableProxy(
      address(_impl),
      address(proxyAdmin),
      abi.encodeWithSelector(bytes4(keccak256("initialize(address)")), _NTToken)
    );

    return NattaBank(payable(_proxy));
  }

  function _setupFakeERC20(string memory _name, string memory _symbol)
    internal
    returns (MockERC20)
  {
    MockERC20 _impl = new MockERC20();
    TransparentUpgradeableProxy _proxy = new TransparentUpgradeableProxy(
      address(_impl),
      address(proxyAdmin),
      abi.encodeWithSelector(
        bytes4(keccak256("initialize(string,string)")),
        _name,
        _symbol
      )
    );
    return MockERC20(payable(_proxy));
  }
}
