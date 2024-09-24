// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Balance, Type, TokenSet, Action, Name} from "./Shared/TokenSet.sol";

contract AAVEView {
    function getDeposits(address publicAddress, address tokenAddress) public view returns (TokenSet[] memory) {
        return new TokenSet[](0);
    }

    function getLoans(address publicAddress, address tokenAddress) public view returns (TokenSet[] memory) {
        return new TokenSet[](0);
    }
}
