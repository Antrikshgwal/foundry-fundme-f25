//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console } from "forge-std/Test.sol";
import {FundMe} from "../../src/Fundme.sol";
import {DeployFundme} from "../../script/DeployFundme.s.sol";


contract FundmeTest is Test{
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

 modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        assert(address(fundme).balance > 0);
        _;
    }

function testIsOwner() public{
console.log(fundme.getOwner()); // deployment script
console.log(address(this));
console.log(msg.sender);

// assertEq(fundme.MINIMUM_USD(),5*1e18);
assertEq(fundme.getOwner() /* DeployScript is the owner */, msg.sender /* this is this test contract  */);
}

function testPriceFeedVersion()public{
    assertEq(fundme.getVersion(), 4);
}

function testMinimumDollarisfive() public{
    assertEq(fundme.MINIMUM_USD(), 5 * 1e18);
}

function testFundMeFailsWithoutMinimumETH() public {
    vm.expectRevert();
    fundme.fund();
}
function testDataStructuresareUpdated() public{
    vm.prank(USER); // Next tx will be sent by  the USER
    fundme.fund{value:SEND_VALUE}();
uint256 amountFunded = fundme.getAddresstoAmountFunded(USER);
assertEq(amountFunded, SEND_VALUE);
}

function testAddsFundertoArray() public{
    vm.prank(USER); // Next tx will be sent by  the USER
    fundme.fund{value:SEND_VALUE}();
    address funder = fundme.getFunder(0);
    assertEq(funder, USER);
}

function testOnlyOwnerCanWithdraw() public {
    vm.prank(USER);
    fundme.fund{value:SEND_VALUE}();

    vm.prank(USER);
    vm.expectRevert();
    fundme.withdraw();
    }


     function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundme).balance;
        uint256 startingOwnerBalance = fundme.getOwner().balance;

        vm.txGasPrice(GAS_PRICE) ;
        uint256 gasStart = gasleft();
        // /Act
        vm.startPrank(fundme.getOwner());  // startPrank -> containing txs will be signed by the this address
        fundme.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert
        uint256 endingFundMeBalance = address(fundme).balance;
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }

    // Can we do our withdraw function a cheaper way?
    function testWithdrawFromMultipleFunders() public funded  {
//Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        // Act
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), STARTING_BALANCE);
            fundme.fund{value: SEND_VALUE}();
        }

        uint256 startingFundedeBalance = address(fundme).balance;
        uint256 startingOwnerBalance = fundme.getOwner().balance;

        vm.startPrank(fundme.getOwner());
        fundme.withdraw(); // withdraws all of the funds
        vm.stopPrank();

        assert(address(fundme).balance == 0); // thats why this assert got passed
        assert(startingFundedeBalance + startingOwnerBalance == fundme.getOwner().balance);

    }
    function testWithdrawFromMultipleFunders_withCheaperwithdraw() public funded  {
//Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        // Act
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), STARTING_BALANCE);
            fundme.fund{value: SEND_VALUE}();
        }

        uint256 startingFundedeBalance = address(fundme).balance;
        uint256 startingOwnerBalance = fundme.getOwner().balance;

        vm.startPrank(fundme.getOwner());
        fundme.cheaper_withdraw(); // withdraws all of the funds
        vm.stopPrank();

        assert(address(fundme).balance == 0); // thats why this assert got passed
        assert(startingFundedeBalance + startingOwnerBalance == fundme.getOwner().balance);

    }
}