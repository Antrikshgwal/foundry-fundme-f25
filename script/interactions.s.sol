// SPDX-License-Idenifier : MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/Fundme.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundme is Script {
uint256 constant SEND_VALUE = 0.01 ether;
function  fundFundme(address mostRecentlyDeployed) public  {
vm.startBroadcast();
FundMe(payable (mostRecentlyDeployed)).fund{value:SEND_VALUE}();
vm.stopBroadcast();
console.log("Funded Fundme with %s", SEND_VALUE);
}

function run() external {
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Fundme",
    block.chainid
    );
fundFundme(mostRecentlyDeployed);
}

}

contract WithDrawFundMe is Script {


function withDrawFundMe(address mostRecentlyDeployed) public  {
        vm.startBroadcast();
FundMe(payable (mostRecentlyDeployed)).withdraw();
vm.stopBroadcast();

console.log("Withdraw fundme balance");
    }
function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        WithDrawFundMe(mostRecentlyDeployed);
    }
}



