// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Balance, Type, TokenSet, Action, Name} from "./Shared/TokenSet.sol";
import {IERC20Token} from "./Shared/IERC20Token.sol";

contract ERC20View {
    function balanceOf(address publicAddress, address tokenAddress) public view returns (TokenSet[] memory) {
        require(publicAddress != address(0), "Invalid public key");
        require(tokenAddress != address(0), "Invalid token address");

        IERC20Token token = IERC20Token(tokenAddress);

        Balance memory balance = Balance({
            name: token.name(),
            symbol: token.symbol(),
            decimals: token.decimals(),
            index: 0,
            balance: token.balanceOf(publicAddress),
            tokenAddress: tokenAddress,
            tokenType: Type.ERC20
        });

        Balance[] memory inputs = new Balance[](1);
        inputs[0] = balance;

        Balance[] memory outputs = new Balance[](0);

        Action[] memory actions = new Action[](3);
        actions[0] = Action.SEND;
        actions[1] = Action.RECEIVE;
        actions[2] = Action.SWAP;

        TokenSet[] memory tokenSets = new TokenSet[](1);
        tokenSets[0] = TokenSet({note: "", name: Name.COIN, inputs: inputs, outputs: outputs, actions: actions});

        return tokenSets;
    }
}
