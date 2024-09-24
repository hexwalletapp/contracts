// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Balance, Type, TokenSet, Action, Name} from "./Shared/TokenSet.sol";
import {IERC20Token} from "./Shared/IERC20Token.sol";
import {IPool} from "aave-v3-core/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";

contract AAVEView {
    function getDeposits(address publicAddress, address tokenAddress) public view returns (TokenSet[] memory) {
        require(publicAddress != address(0), "Public Address is empty");
        require(tokenAddress != address(0), "Token address is empty");

        IPool pool = IPool(IPoolAddressesProvider(tokenAddress).getPool());

        (uint256 totalCollateralBase,,,,,) = pool.getUserAccountData(publicAddress);

        TokenSet[] memory tokenSets = new TokenSet[](1);
        tokenSets[0] = TokenSet({
            note: "",
            name: Name.CREDIT,
            inputs: new Balance[](1),
            outputs: new Balance[](1),
            actions: new Action[](2)
        });

        tokenSets[0].inputs[0] = Balance({
            name: IERC20Token(tokenAddress).name(),
            symbol: IERC20Token(tokenAddress).symbol(),
            decimals: IERC20Token(tokenAddress).decimals(),
            index: 0,
            balance: totalCollateralBase,
            tokenAddress: tokenAddress,
            tokenType: Type.ERC20
        });

        tokenSets[0].outputs[0] = Balance({
            name: IERC20Token(tokenAddress).name(),
            symbol: IERC20Token(tokenAddress).symbol(),
            decimals: IERC20Token(tokenAddress).decimals(),
            index: 0,
            balance: pool.getReserveNormalizedIncome(tokenAddress),
            tokenAddress: tokenAddress,
            tokenType: Type.ERC20
        });

        tokenSets[0].actions[0] = Action.DEPOSIT_CREDIT;
        tokenSets[0].actions[1] = Action.WITHDRAW_CREDIT;

        return tokenSets;
    }
}
