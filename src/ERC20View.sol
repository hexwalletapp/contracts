// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Balance, Type} from "./Shared/TokenBundle.sol";

contract ERC20View {
    function balanceOf(address[] memory addresses, address[] memory tokenAddresses)
        public
        view
        returns (Balance[] memory)
    {
        require(addresses.length > 0, "Addresses array is empty");
        require(tokenAddresses.length > 0, "Token addresses array is empty");

        Balance[] memory balances = new Balance[](addresses.length * tokenAddresses.length);
        uint256 index = 0;

        for (uint256 i = 0; i < addresses.length; i++) {
            for (uint256 j = 0; j < tokenAddresses.length; j++) {
                ERC20 token = ERC20(tokenAddresses[j]);

                balances[index] = Balance({
                    name: token.name(),
                    symbol: token.symbol(),
                    decimals: token.decimals(),
                    balance: token.balanceOf(addresses[i]),
                    tokenAddress: tokenAddresses[j],
                    tokenType: Type.ERC20
                });

                index++;
            }
        }

        return balances;
    }
}
