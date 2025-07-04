// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Note: The AggregatorV3Interface might be at a different location than what was in the video!
import {AggregatorV3Interface} from "@chainlink/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConvertor.sol";

error Fundme_NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address private /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed; // instaniate the PriceFeed contract

    constructor(address priceFeed) {
        i_owner = msg.sender;
     s_priceFeed = AggregatorV3Interface(priceFeed);

    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {

        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert Fundme_NotOwner();
        _;
    }

    function cheaper_withdraw () public onlyOwner {
        uint256 funders_length = s_funders.length ;
        for ( uint funderIndex = 0 ; funderIndex < funders_length ; funderIndex++ ){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);


        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }


    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    function getAddresstoAmountFunded(address funder) external view returns (uint256){
        uint256 amt = s_addressToAmountFunded[funder];
        return amt;
    }
    function getFunder(uint256 index) external view returns (address){
        address funder = s_funders[index];
        return funder;
    }
    function getOwner() view external returns (address){
        return i_owner;
    }
}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly