// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Subscription Service
 * @dev A smart contract for managing subscription-based services with automatic renewals
 */
contract Project {
    struct Subscription {
        uint256 price;
        uint256 duration;
        bool active;
        string name;
        string description;
    }

    struct UserSubscription {
        uint256 planId;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        uint256 renewalCount;
    }

    address public owner;
    uint256 public planCounter;
    uint256 public totalRevenue;

    mapping(uint256 => Subscription) public subscriptionPlans;
    mapping(address => UserSubscription) public userSubscriptions;
    mapping(address => uint256) public userBalances;

    event SubscriptionPlanCreated(uint256 indexed planId, string name, uint256 price, uint256 duration);
    event SubscriptionPurchased(address indexed user, uint256 indexed planId, uint256 endTime);
    event SubscriptionRenewed(address indexed user, uint256 indexed planId, uint256 newEndTime);
    event SubscriptionCancelled(address indexed user, uint256 indexed planId);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier validPlan(uint256 _planId) {
        require(_planId > 0 && _planId <= planCounter, "Invalid plan ID");
        require(subscriptionPlans[_planId].active, "Plan is not active");
        _;
    }

    constructor() {
        owner = msg.sender;
        planCounter = 0;
        totalRevenue = 0;
    }

    /**
     * @dev Creates a new subscription plan
     */
    function createSubscriptionPlan(
        string memory _name,
        string memory _description,
        uint256 _price,
        uint256 _duration
    ) external onlyOwner {
        require(_price > 0, "Price must be greater than 0");
        require(_duration > 0, "Duration must be greater than 0");
        require(bytes(_name).length > 0, "Name cannot be empty");

        planCounter++;
        subscriptionPlans[planCounter] = Subscription({
            price: _price,
            duration: _duration,
            active: true,
            name: _name,
            description: _description
        });

        emit SubscriptionPlanCreated(planCounter, _name, _price, _duration);
    }

    /**
     * @dev Allows users to subscribe to a plan
     */
    function subscribe(uint256 _planId) external payable validPlan(_planId) {
        Subscription memory plan = subscriptionPlans[_planId];
        require(msg.value >= plan.price, "Insufficient payment");

        UserSubscription storage userSub = userSubscriptions[msg.sender];
        if (userSub.isActive && block.timestamp < userSub.endTime) {
            revert("User already has an active subscription");
        }

        userSub.planId = _planId;
        userSub.startTime = block.timestamp;
        userSub.endTime = block.timestamp + plan.duration;
        userSub.isActive = true;
        userSub.renewalCount = 0;

        totalRevenue += plan.price;

        if (msg.value > plan.price) {
            payable(msg.sender).transfer(msg.value - plan.price);
        }

        emit SubscriptionPurchased(msg.sender, _planId, userSub.endTime);
    }

    /**
     * @dev Allows users to renew their subscription
     */
    function renewSubscription() external payable {
        UserSubscription storage userSub = userSubscriptions[msg.sender];
        require(userSub.isActive, "No active subscription found");

        Subscription memory plan = subscriptionPlans[userSub.planId];
        require(plan.active, "Subscription plan is no longer active");
        require(msg.value >= plan.price, "Insufficient payment for renewal");

        if (block.timestamp < userSub.endTime) {
            userSub.endTime += plan.duration;
        } else {
            userSub.startTime = block.timestamp;
            userSub.endTime = block.timestamp + plan.duration;
        }

        userSub.renewalCount++;
        totalRevenue += plan.price;

        if (msg.value > plan.price) {
            payable(msg.sender).transfer(msg.value - plan.price);
        }

        emit SubscriptionRenewed(msg.sender, userSub.planId, userSub.endTime);
    }

    /**
     * @dev Allows users to cancel their subscription
     */
    function cancelSubscription() external {
        UserSubscription storage userSub = userSubscriptions[msg.sender];
        require(userSub.isActive, "No active subscription found");

        userSub.isActive = false;

        emit SubscriptionCancelled(msg.sender, userSub.planId);
    }

    /**
     * @dev Check if a user's subscription is currently active
     */
    function isSubscriptionActive(address _user) external view returns (bool) {
        UserSubscription memory userSub = userSubscriptions[_user];
        return userSub.isActive && block.timestamp < userSub.endTime;
    }

    /**
     * @dev Get subscription details for a user
     */
    function getUserSubscription(address _user) external view returns (UserSubscription memory) {
        return userSubscriptions[_user];
    }

    /**
     * @dev Get subscription plan details
     */
    function getSubscriptionPlan(uint256 _planId) external view returns (Subscription memory) {
        require(_planId > 0 && _planId <= planCounter, "Invalid plan ID");
        return subscriptionPlans[_planId];
    }

    /**
     * @dev Toggle subscription plan active status
     */
    function togglePlanStatus(uint256 _planId) external onlyOwner {
        require(_planId > 0 && _planId <= planCounter, "Invalid plan ID");
        subscriptionPlans[_planId].active = !subscriptionPlans[_planId].active;
    }

    /**
     * @dev Withdraw contract balance to owner
     */
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner).transfer(balance);
        emit FundsWithdrawn(owner, balance);
    }

    /**
     * @dev Get contract balance
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Get total number of subscription plans
     */
    function getTotalPlans() external view returns (uint256) {
        return planCounter;
    }

    /**
     * @dev Transfer ownership of the contract
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner cannot be zero address");
        owner = _newOwner;
    }

    /**
     * @dev Get all active subscription plans
     */
    function getAllActivePlans() external view returns (Subscription[] memory activePlans) {
        uint256 count = 0;

        for (uint256 i = 1; i <= planCounter; i++) {
            if (subscriptionPlans[i].active) {
                count++;
            }
        }

        activePlans = new Subscription[](count);
        uint256 index = 0;

        for (uint256 i = 1; i <= planCounter; i++) {
            if (subscriptionPlans[i].active) {
                activePlans[index] = subscriptionPlans[i];
                index++;
            }
        }
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
