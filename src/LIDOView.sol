// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Balance, Type, TokenSet, Action, Name} from "./Shared/TokenSet.sol";
import {IERC20Token} from "./Shared/IERC20Token.sol";
import {IWithdrawalQueue, WithdrawalRequestStatus} from "./Shared/IWithdrawalQueue.sol";

contract LIDOView {
    function stakeOf(address publicAddress, address tokenAddress) public view returns (TokenSet[] memory) {
        require(publicAddress != address(0), "Public Address is empty");
        require(tokenAddress != address(0), "Token address is empty");

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

        Action[] memory actions = new Action[](4);
        actions[0] = Action.SEND;
        actions[1] = Action.RECEIVE;
        actions[2] = Action.SWAP;
        actions[3] = Action.WITHDRAW_STAKE;

        TokenSet[] memory tokenSets = new TokenSet[](1);
        tokenSets[0] = TokenSet({name: Name.STAKE, inputs: inputs, outputs: outputs, actions: actions});

        return tokenSets;
    }

    function withdrawalsOf(address publicAddress, address tokenAddress) public view returns (TokenSet[] memory) {
        require(publicAddress != address(0), "Public Address is empty");
        require(tokenAddress != address(0), "Token address is empty");

        IWithdrawalQueue token = IWithdrawalQueue(tokenAddress);

        // Get withdrawal requests for the current user
        uint256[] memory requestIds = token.getWithdrawalRequests(publicAddress);

        // Fetch the withdrawal statuses for all request IDs at once
        WithdrawalRequestStatus[] memory statuses = token.getWithdrawalStatus(requestIds);

        // Create a dynamic array to hold valid TokenSets
        TokenSet[] memory tokenSets = new TokenSet[](requestIds.length);
        uint256 validTokenSetCount = 0;

        // Loop through each requestId and its corresponding status
        for (uint256 i = 0; i < requestIds.length; i++) {
            uint256 requestId = requestIds[i];
            WithdrawalRequestStatus memory status = statuses[i];

            // Skip if the request is already claimed
            if (status.isClaimed) {
                continue;
            }

            Balance memory balance = Balance({
                name: token.name(),
                symbol: token.symbol(),
                decimals: 0, // Assuming decimals do not apply for stETH withdrawal requests
                index: requestId,
                balance: status.amountOfStETH,
                tokenAddress: tokenAddress,
                tokenType: Type.ERC721
            });

            Balance[] memory inputs = new Balance[](1);
            inputs[0] = balance;

            Balance[] memory outputs = new Balance[](0);

            if (status.isFinalized) {
                Action[] memory actions = new Action[](2);
                actions[0] = Action.SEND;
                actions[1] = Action.CLAIM;

                tokenSets[validTokenSetCount] =
                    TokenSet({name: Name.CLAIM, inputs: inputs, outputs: outputs, actions: actions});
            } else {
                Action[] memory actions = new Action[](1);
                actions[0] = Action.SEND;

                tokenSets[validTokenSetCount] =
                    TokenSet({name: Name.CLAIM, inputs: inputs, outputs: outputs, actions: actions});
            }

            validTokenSetCount++;
        }

        // Resize the tokenSets array to remove empty slots
        TokenSet[] memory validTokenSets = new TokenSet[](validTokenSetCount);
        for (uint256 k = 0; k < validTokenSetCount; k++) {
            validTokenSets[k] = tokenSets[k];
        }

        return validTokenSets;
    }
}
