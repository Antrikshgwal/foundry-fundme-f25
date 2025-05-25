//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console } from "forge-std/Test.sol";
import {FundMe} from "../../src/Fundme.sol";
import {DeployFundme} from "../../script/DeployFundme.s.sol";
import {FundFundme,WithDrawFundMe} from "../../script/interactions.s.sol";


contract FundmeIntgrationTest is Test{
FundMe fundme;
address USER = makeAddr("user");
uint256 constant SEND_VALUE = 0.1 ether;
uint256 constant STARTING_BALANCE = 10 ether;
uint256 constant GAS_PRICE = 1;


function setUp() external{
DeployFundme deployFundMe = new DeployFundme(); // Deploys the contract same as the deployment script
fundme = deployFundMe.run();
vm.deal(USER,STARTING_BALANCE);
}

function test_user_can_fund_and_withdraw() public {
    FundFundme fundFundme = new FundFundme();// Instaniate the variable
    fundFundme.fundFundme(address(fundme));

    WithDrawFundMe withDrawFundMe = new WithDrawFundMe(); // Instaniate the variable
    withDrawFundMe.withDrawFundMe(address(fundme));
    assertEq(address(fundme).balance, 0); // Check if the balance is zero after withdraw
}

}