// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC721Metadata} from "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";

/// @notice output format struct for `_getWithdrawalStatus()` method
struct WithdrawalRequestStatus {
    /// @notice stETH token amount that was locked on withdrawal queue for this request
    uint256 amountOfStETH;
    /// @notice amount of stETH shares locked on withdrawal queue for this request
    uint256 amountOfShares;
    /// @notice address that can claim or transfer this request
    address owner;
    /// @notice timestamp of when the request was created, in seconds
    uint256 timestamp;
    /// @notice true, if request is finalized
    bool isFinalized;
    /// @notice true, if request is claimed. Request is claimable if (isFinalized && !isClaimed)
    bool isClaimed;
}

interface IWithdrawalQueue is IERC721Metadata {
    function getWithdrawalRequests(address _owner) external view returns (uint256[] memory requestsIds);

    function getWithdrawalStatus(uint256[] calldata _requestIds)
        external
        view
        returns (WithdrawalRequestStatus[] memory statuses);
}
