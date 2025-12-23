// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {PriceFeed} from "./PriceFeedLibrary.sol";

error TransferFailed();

contract CrowdfundingCampaign {

    using PriceFeed for uint;

    address private owner;
    string private campaignName;
    string private campaignDescription;

    uint256 private fundGoalUSD;       
    uint256 private totalFundedUSD;    

    uint256 private deadline;
    uint256 private minimumFundUSD;

    bool private isActive;


    mapping(address => uint256) public contributionsETH;
    address[] fundersAddress;

    event CampaignCreated(
        string name,
        uint256 goalUSD,
        uint256 deadline
    );

    event Funded(
        address indexed contributor,
        uint256 ethAmount,
        uint256 usdAmount
    );

    event Withdrawn(uint256 ethAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function CreateCampaign (string calldata _name, string calldata _description, uint256 _fundGoalUSD, uint256 _deadline, uint256 _minimumFundUSD) public onlyOwner {

        require(bytes(_name).length >= 3, "Name too short");
        require(bytes(_description).length >= 5, "Description too short");
        require(_fundGoalUSD > 0, "Goal must be > 0");
        require(_minimumFundUSD > 0, "Minimum must be > 0");
        require(_deadline >= block.timestamp + 1 hours, "Deadline too soon");

        campaignName = _name;
        campaignDescription = _description;

        fundGoalUSD = _fundGoalUSD * 1e18;     
        minimumFundUSD = _minimumFundUSD * 1e18;

        totalFundedUSD = 0;
        deadline = _deadline;
        isActive = true;

        emit CampaignCreated(_name, fundGoalUSD, _deadline);
    }

    function contribute() public  payable {
        require(isActive, "Campaign inactive");
        require(block.timestamp < deadline, "Deadline passed");

        uint256 usdAmount = msg.value.getUSDValue();

        require(usdAmount >= minimumFundUSD, "Below minimum");

        contributionsETH[msg.sender] += msg.value;
        fundersAddress.push(msg.sender);
        totalFundedUSD += usdAmount;

        emit Funded(msg.sender, msg.value, usdAmount);

        if (totalFundedUSD == fundGoalUSD) {
            isActive = false;
        }
    }


    function withdraw() public onlyOwner{
        for(uint i = 0; i < fundersAddress.length; i++){
            address funder = fundersAddress[i];
            delete contributionsETH[funder];
        }

        fundersAddress = new address[](0);

        (bool success,) = payable (msg.sender).call{value: address(this).balance}("");
        
       if(!success) revert TransferFailed();

    }

    function getCampaignName() external  view returns(string memory){
        return campaignName;
    }
    function getCampaignDescription() external  view returns(string memory){
        return campaignDescription;
    }

    function getFundingGoal() external view returns (uint256) { 
        return fundGoalUSD; 
    } 
    
    function getCreator() external view returns (address) {
         return owner; 
    } 

    function getTotalFundsRaised() external view returns (uint256) {
        return totalFundedUSD; 
    }

    function getDeadline() external view returns (uint256) {
        return deadline; 
    }

    function getMinContribution() external view returns (uint256) {
        return minimumFundUSD; 
    }

    function getIsActive() external view returns (bool) {
        return isActive; 
    }

    function getRemainingFunding() external view returns (uint256) { 
        if (totalFundedUSD >= fundGoalUSD) { return 0; } return fundGoalUSD - totalFundedUSD; 
    } 
    function getDaysUntilDeadline() external view returns (uint256) { 
        if (block.timestamp >= deadline) { return 0; } return (deadline - block.timestamp) / 86400; 
    }
    

    receive() external payable {
        contribute();
    }
}