// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {ZaisanMain} from "../ZaisanMain.sol";

contract DeployZKDrop is Script {
    bytes16 immutable sismoAppId = 0x894df154e55ed8ea5ab5a9f3a407e667;
    bytes constant _worldCoinAppId =
        bytes("app_staging_a359d7eb83b06a341767bd8bc4623131");

    function run() public {
        vm.startBroadcast();
        ZaisanMain zaisan = new ZaisanMain(sismoAppId, _worldCoinAppId);
        console.log("ZaisanMain deployed at", address(zaisan));
        vm.stopBroadcast();
    }
}
