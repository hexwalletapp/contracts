// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Balance, Type, TokenSet, Action, Name} from "./Shared/TokenSet.sol";
import {IERC20Token} from "./Shared/IERC20Token.sol";
import {IWithdrawalQueue, WithdrawalRequestStatus} from "./Shared/IWithdrawalQueue.sol";

contract LIDOView {
    function stakeOf(address publicAddress, address tokenAddress) public view returns (TokenSet[] memory) {
        require(publicAddress != address(0), "Public Address is empty");
        require(tokenAddress != address(0), "Token address is empty");

        TokenSet[] memory tokenSets = new TokenSet[](1);
        tokenSets[0] = TokenSet({
            note: "",
            name: Name.STAKE,
            inputs: new Balance[](1),
            outputs: new Balance[](0),
            actions: new Action[](4)
        });

        tokenSets[0].inputs[0] = Balance({
            name: IERC20Token(tokenAddress).name(),
            symbol: IERC20Token(tokenAddress).symbol(),
            decimals: IERC20Token(tokenAddress).decimals(),
            index: 0,
            balance: IERC20Token(tokenAddress).balanceOf(publicAddress),
            tokenAddress: tokenAddress,
            tokenType: Type.ERC20
        });

        tokenSets[0].actions[0] = Action.SEND;
        tokenSets[0].actions[1] = Action.RECEIVE;
        tokenSets[0].actions[2] = Action.SWAP;
        tokenSets[0].actions[3] = Action.WITHDRAW_STAKE;

        return tokenSets;
    }

    function withdrawalsOf(address publicAddress, address tokenAddress) public view returns (TokenSet[] memory) {
        require(publicAddress != address(0), "Public Address is empty");
        require(tokenAddress != address(0), "Token address is empty");

        IWithdrawalQueue token = IWithdrawalQueue(tokenAddress);
        uint256[] memory requestIds = token.getWithdrawalRequests(publicAddress);
        WithdrawalRequestStatus[] memory statuses = token.getWithdrawalStatus(requestIds);

        TokenSet[] memory tokenSets = new TokenSet[](requestIds.length);
        uint256 validTokenSetCount = 0;

        for (uint256 i = 0; i < requestIds.length; i++) {
            if (statuses[i].isClaimed) {
                continue;
            }

            tokenSets[validTokenSetCount] = TokenSet({
                note: "",
                name: Name.CLAIM,
                inputs: new Balance[](1),
                outputs: new Balance[](0),
                actions: statuses[i].isFinalized ? new Action[](2) : new Action[](1)
            });

            tokenSets[validTokenSetCount].inputs[0] = Balance({
                name: token.name(),
                symbol: token.symbol(),
                decimals: 0,
                index: requestIds[i],
                balance: statuses[i].amountOfStETH,
                tokenAddress: tokenAddress,
                tokenType: Type.ERC721
            });

            tokenSets[validTokenSetCount].actions[0] = Action.SEND;
            if (statuses[i].isFinalized) {
                tokenSets[validTokenSetCount].actions[1] = Action.CLAIM;
            }

            validTokenSetCount++;
        }

        TokenSet[] memory validTokenSets = new TokenSet[](validTokenSetCount);
        for (uint256 k = 0; k < validTokenSetCount; k++) {
            validTokenSets[k] = tokenSets[k];
        }

        return validTokenSets;
    }
}
