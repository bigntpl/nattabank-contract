// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../_base/BaseTest.sol";
import "../_mock/MockERC20.sol";
import "../../../../contracts/NattaBank.sol";

contract NattaBankBaseTest is BaseTest {
  NattaBank nattaBank;
  MockERC20 internal erc20Token;

  /// @dev Foundry's setUp method
  function setUp() public virtual {
    erc20Token = _setupFakeERC20("NT", "Natta Token");
    nattaBank = _setupNattaBank(address(erc20Token));
  }

  // █░█ ▀█▀ █ █░░ █▀
  // █▄█ ░█░ █ █▄▄ ▄█

  function _setupNattaBank(address _erc20Token) internal returns (NattaBank) {
    NattaBank _impl = new NattaBank();

    TransparentUpgradeableProxy _proxy = new TransparentUpgradeableProxy(
      address(_impl),
      address(proxyAdmin),
      abi.encodeWithSelector(
        bytes4(keccak256("initialize(address)")),
        _erc20Token
      )
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

  function _createAccountHelper(uint256 _accountAmount) internal {
    // Helper function for creating a new account
    // account i: name = Account i + 1
    string[] memory accountName = new string[](_accountAmount);
    for (uint8 i = 0; i < _accountAmount; i++) {
      accountName[i] = string.concat("Account ", Strings.toString(i + 1));
      nattaBank.createAccount(accountName[i]);
    }
  }
}
