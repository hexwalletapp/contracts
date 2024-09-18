// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC20View} from "../src/ERC20View.sol";
import {Balance, Type} from "../src/Shared/TokenBundle.sol";
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
        mockToken1.mint(testWallet, 1000 * 10**18);
        mockToken2.mint(testWallet, 500 * 10**6);
    }

    function test_WalletHasTokens() public {
        address[] memory addresses = new address[](1);
        addresses[0] = testWallet;

        address[] memory tokenAddresses = new address[](2);
        tokenAddresses[0] = address(mockToken1);
        tokenAddresses[1] = address(mockToken2);

        Balance[] memory balanceResults = erc20View.balanceOf(addresses, tokenAddresses);

        assertEq(balanceResults.length, 2, "Should return 2 balance results");

        // Check Token1 balance
        assertEq(balanceResults[0].name, "Token1", "Token1 name mismatch");
        assertEq(balanceResults[0].symbol, "TKN1", "Token1 symbol mismatch");
        assertEq(balanceResults[0].decimals, 18, "Token1 decimals mismatch");
        assertEq(balanceResults[0].balance, 1000 * 10**18, "Token1 balance mismatch");
        assertEq(balanceResults[0].tokenAddress, address(mockToken1), "Token1 address mismatch");
        assertEq(uint(balanceResults[0].tokenType), uint(Type.ERC20), "Token1 type mismatch");

        // Check Token2 balance
        assertEq(balanceResults[1].name, "Token2", "Token2 name mismatch");
        assertEq(balanceResults[1].symbol, "TKN2", "Token2 symbol mismatch");
        assertEq(balanceResults[1].decimals, 6, "Token2 decimals mismatch");
        assertEq(balanceResults[1].balance, 500 * 10**6, "Token2 balance mismatch");
        assertEq(balanceResults[1].tokenAddress, address(mockToken2), "Token2 address mismatch");
        assertEq(uint(balanceResults[1].tokenType), uint(Type.ERC20), "Token2 type mismatch");
    }
}