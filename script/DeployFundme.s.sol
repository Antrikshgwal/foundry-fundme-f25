//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;


import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/Fundme.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundme is Script {
    function run() external returns (FundMe)  { // By calling this functuon the contract gets deployed
    // not a real tx
    HelperConfig helperConfig = new HelperConfig(); // Deploys the HelperConfig contract
    address ethUSDPriceAddress = helperConfig.activeNetworkConfig();

    // Any real tx will start from here
        vm.startBroadcast();
        // Mock contracts - anvil deploys to local testnet which can be used for tests
        FundMe fundMe = new FundMe(ethUSDPriceAddress); // Here FundMe gets deployed with constructor arguments
        vm.stopBroadcast();
        return fundMe ; // and return the deployment

    }
}