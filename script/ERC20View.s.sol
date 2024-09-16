// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ERC20View} from "../src/ERC20View.sol";

contract CounterScript is Script {
    ERC20View public erc20View;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        erc20View = new ERC20View();
        console.log("ERC20View:", address(erc20View));

        vm.stopBroadcast();
    }
}
