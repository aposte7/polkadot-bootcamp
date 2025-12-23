// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdfundingCampaign {
   string private campaignName;
   string private campaignDescription;
   uint256 private fundGoal;
   uint private totalFund;
   address private owner;

   uint256 private deadline;
   uint256 private minimumFund;
   bool private isActive;

   constructor(){
        owner = msg.sender;
   }
    
    function createCampaign(string calldata _campaignName, string calldata _campaignDescription, uint _fundGoal, uint _deadline, uint256 _minimumFund) public {
        require(_deadline >= block.timestamp + 1 hours, "deadline should be at least 1 hour from now");
        require(bytes(_campaignName).length >= 3, "campaign name should be at least 3 characters");
        require(bytes(_campaignDescription).length >= 5, "campaign description should be at least 5 characters");
        require(_fundGoal > 1 ether, "Fund goal should be more than 1 ETH");

        campaignName = _campaignName;
        campaignDescription = _campaignDescription;
        fundGoal = _fundGoal;
        deadline = _deadline;
        minimumFund = _minimumFund;
        isActive = true;
    }

    function fund() external payable {
        require(isActive, "Campaign is not active");
        require(block.timestamp < deadline, "Campaign deadline has passed");
        require(msg.value >= minimumFund, "Contribution below minimum");
        require(totalFund + msg.value <= fundGoal, "Would exceed funding goal");

        totalFund += msg.value;
        if (totalFund >= fundGoal) {
            isActive = false;
        }
    }

    function getName() external view returns (string memory) {
        return campaignName;
    }

    function getDescription() external view returns (string memory) {
        return campaignDescription;
    }

    function getFundingGoal() external view returns (uint256) {
        return fundGoal;
    }

    function getCreator() external view returns (address) {
        return owner;
    }

    function getTotalFundsRaised() external view returns (uint256) {
        return totalFund;
    }

    function getDeadline() external view returns (uint256) {
        return deadline;
    }

    function getMinContribution() external view returns (uint256) {
        return minimumFund;
    }

    function getIsActive() external view returns (bool) {
        return isActive;
    }

    function getRemainingFunding() external view returns (uint256) {
        if (totalFund >= fundGoal) {
            return 0;
        }
        return fundGoal - totalFund;
    }

    function getDaysUntilDeadline() external view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return (deadline - block.timestamp) / 86400; 
    }

    function isAcceptingDonations() public view returns (bool) {
        return isActive && (block.timestamp < deadline) && (totalFund < fundGoal);
    }


    function setStatus() public {
        uint256 currentTime = block.timestamp;

        if(currentTime >= deadline){
            isActive = false;
        }
    }

    receive() external payable { 
        fund();
    }

    fallback() external payable { 
        fund();
    }

}