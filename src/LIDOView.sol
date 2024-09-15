// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Balance, Type} from "./Shared/TokenBundle.sol";
import {IERC20Token} from "./Shared/IERC20Token.sol";

contract ERC20View {
    function stakeOf(address[] memory addresses, address tokenAddress) public view returns (Balance[] memory) {
        require(addresses.length > 0, "Addresses array is empty");
        require(tokenAddress != address(0), "Token address is empty");

        Balance[] memory balances = new Balance[](addresses.length);

        IERC20Token token = IERC20Token(tokenAddress);

        for (uint256 i = 0; i < addresses.length; i++) {
            balances[i] = Balance({
                name: token.name(),
                symbol: token.symbol(),
                decimals: token.decimals(),
                balance: token.balanceOf(addresses[i]),
                tokenAddress: tokenAddress,
                tokenType: Type.ERC20
            });
        }

        return balances;
    }
}
