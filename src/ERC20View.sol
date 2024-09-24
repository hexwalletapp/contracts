// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Balance, Type, TokenSet, Action, Name} from "./Shared/TokenSet.sol";
import {IERC20Token} from "./Shared/IERC20Token.sol";

contract ERC20View {
    function balanceOf(address publicAddress, address tokenAddress) public view returns (TokenSet[] memory) {
        require(publicAddress != address(0), "Invalid public key");
        require(tokenAddress != address(0), "Invalid token address");

        IERC20Token token = IERC20Token(tokenAddress);

        TokenSet[] memory tokenSets = new TokenSet[](1);
        tokenSets[0] = TokenSet({
            note: "",
            name: Name.COIN,
            inputs: new Balance[](1),
            outputs: new Balance[](0),
            actions: new Action[](3)
        });

        tokenSets[0].inputs[0] = Balance({
            name: token.name(),
            symbol: token.symbol(),
            decimals: token.decimals(),
            index: 0,
            balance: token.balanceOf(publicAddress),
            tokenAddress: tokenAddress,
            tokenType: Type.ERC20
        });

        tokenSets[0].actions[0] = Action.SEND;
        tokenSets[0].actions[1] = Action.RECEIVE;
        tokenSets[0].actions[2] = Action.SWAP;

        return tokenSets;
    }
}
