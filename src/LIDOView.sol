// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Balance, Type} from "./Shared/TokenSet.sol";
import {IERC20Token} from "./Shared/IERC20Token.sol";
import {IWithdrawalQueue, WithdrawalRequestStatus} from "./Shared/IWithdrawalQueue.sol";

contract LIDOView {
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
                index: 0,
                balance: token.balanceOf(addresses[i]),
                tokenAddress: tokenAddress,
                tokenType: Type.ERC20
            });
        }

        return balances;
    }

    function withdrawlsOf(address[] memory addresses, address tokenAddress) public view returns (Balance[] memory) {
        require(addresses.length > 0, "Addresses array is empty");
        require(tokenAddress != address(0), "Token address is empty");

        IWithdrawalQueue token = IWithdrawalQueue(tokenAddress);

        // Variable to store the total number of withdrawal requests across all users
        uint256 totalRequests = 0;

        // First, calculate how many requests we need to process across all users
        for (uint256 i = 0; i < addresses.length; i++) {
            uint256[] memory requestIds = token.getWithdrawalRequests(addresses[i]);
            totalRequests += requestIds.length;
        }

        // Create an array large enough to hold all withdrawal statuses
        Balance[] memory balances = new Balance[](totalRequests);

        uint256 balanceIndex = 0;
        for (uint256 i = 0; i < addresses.length; i++) {
            // Get withdrawal requests for the current user (addresses[i])
            uint256[] memory requestIds = token.getWithdrawalRequests(addresses[i]);

            // If there are no requests for the current address, continue to the next
            if (requestIds.length == 0) {
                continue;
            }

            // Fetch the withdrawal statuses for all request IDs at once
            WithdrawalRequestStatus[] memory statuses = token.getWithdrawalStatus(requestIds);

            // Loop through each requestId and its corresponding status
            for (uint256 j = 0; j < requestIds.length; j++) {
                uint256 requestId = requestIds[j];
                WithdrawalRequestStatus memory status = statuses[j];

                // Skip if the request is already claimed
                if (status.isClaimed) {
                    continue;
                }

                // If the request is finalized, add logic for claiming (if necessary)
                if (status.isFinalized) {
                    // You can implement additional logic here to handle finalized requests
                    // For example, triggering claim actions or marking the request for claiming.
                }

                // Populate the balances array with valid, non-claimed requests
                balances[balanceIndex] = Balance({
                    name: token.name(),
                    symbol: token.symbol(),
                    decimals: 0, // Assuming decimals do not apply for stETH withdrawal requests
                    index: requestId,
                    balance: status.amountOfStETH,
                    tokenAddress: tokenAddress,
                    tokenType: Type.ERC721
                });

                balanceIndex++;
            }
        }

        // Resize the balances array to remove empty slots from skipped/claimed requests
        Balance[] memory validBalances = new Balance[](balanceIndex);
        for (uint256 k = 0; k < balanceIndex; k++) {
            validBalances[k] = balances[k];
        }

        return validBalances;
    }
}
