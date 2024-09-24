// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC20View} from "../src/ERC20View.sol";
import {Balance, Type, TokenSet, Action, Name} from "../src/Shared/TokenSet.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

contract ERC20ViewTest is Test {
    ERC20View public erc20View;
    MockERC20 public mockToken1;
    MockERC20 public mockToken2;
    address public testWallet;

    function setUp() public {
        erc20View = new ERC20View();
        mockToken1 = new MockERC20("Token1", "TKN1", 18);
        mockToken2 = new MockERC20("Token2", "TKN2", 6);
        testWallet = address(0x1234);
        // Mint some tokens to the test wallet
        mockToken1.mint(testWallet, 1000 * 10 ** 18);
        mockToken2.mint(testWallet, 500 * 10 ** 6);
    }

    function test_WalletHasToken1() public view {
        TokenSet[] memory result = erc20View.balanceOf(testWallet, address(mockToken1));
        assertEq(result.length, 1, "Should return 1 TokenSet");
        assertEq(result[0].inputs.length, 1, "Should return 1 balance result");
        Balance memory balance = result[0].inputs[0];
        assertEq(balance.name, "Token1", "Token1 name mismatch");
        assertEq(balance.symbol, "TKN1", "Token1 symbol mismatch");
        assertEq(balance.decimals, 18, "Token1 decimals mismatch");
        assertEq(balance.balance, 1000 * 10 ** 18, "Token1 balance mismatch");
        assertEq(balance.tokenAddress, address(mockToken1), "Token1 address mismatch");
        assertEq(uint256(balance.tokenType), uint256(Type.ERC20), "Token1 type mismatch");
    }

    function test_WalletHasToken2() public view {
        TokenSet[] memory result = erc20View.balanceOf(testWallet, address(mockToken2));
        assertEq(result.length, 1, "Should return 1 TokenSet");
        assertEq(result[0].inputs.length, 1, "Should return 1 balance result");
        Balance memory balance = result[0].inputs[0];
        assertEq(balance.name, "Token2", "Token2 name mismatch");
        assertEq(balance.symbol, "TKN2", "Token2 symbol mismatch");
        assertEq(balance.decimals, 6, "Token2 decimals mismatch");
        assertEq(balance.balance, 500 * 10 ** 6, "Token2 balance mismatch");
        assertEq(balance.tokenAddress, address(mockToken2), "Token2 address mismatch");
        assertEq(uint256(balance.tokenType), uint256(Type.ERC20), "Token2 type mismatch");
    }

    function test_TokenSetStructure() public view {
        TokenSet[] memory result = erc20View.balanceOf(testWallet, address(mockToken1));
        assertEq(result.length, 1, "Should return 1 TokenSet");
        assertEq(uint256(result[0].name), uint256(Name.COIN), "TokenSet name should be COIN");
        assertEq(result[0].inputs.length, 1, "Should have one input balance");
        assertEq(result[0].outputs.length, 0, "Should have no output balances");
        assertEq(result[0].actions.length, 3, "Should have three actions");
        assertEq(uint256(result[0].actions[0]), uint256(Action.SEND), "First action should be SEND");
        assertEq(uint256(result[0].actions[1]), uint256(Action.RECEIVE), "Second action should be RECEIVE");
        assertEq(uint256(result[0].actions[2]), uint256(Action.SWAP), "Third action should be SWAP");
    }

    function test_InvalidPublicAddress() public {
        vm.expectRevert("Invalid public key");
        erc20View.balanceOf(address(0), address(mockToken1));
    }

    function test_InvalidTokenAddress() public {
        vm.expectRevert("Invalid token address");
        erc20View.balanceOf(testWallet, address(0));
    }

    function test_ZeroBalance() public view {
        address emptyWallet = address(0x5678);
        TokenSet[] memory result = erc20View.balanceOf(emptyWallet, address(mockToken1));
        assertEq(result.length, 1, "Should return 1 TokenSet even for zero balance");
        assertEq(result[0].inputs.length, 1, "Should return 1 balance result");
        assertEq(result[0].inputs[0].balance, 0, "Balance should be zero");
    }
}
