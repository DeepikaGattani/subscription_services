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

    address[] private subscribers;

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

        bool isNewSubscriber = true;
        for (uint i = 0; i < subscribers.length; i++) {
            if (subscribers[i] == msg.sender) {
                isNewSubscriber = false;
                break;
            }
        }
        if (isNewSubscriber) {
            subscribers.push(msg.sender);
        }

        if (msg.value > plan.price) {
            payable(msg.sender).transfer(msg.value - plan.price);
        }

        emit SubscriptionPurchased(msg.sender, _planId, userSub.endTime);
    }

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

    function cancelSubscription() external {
        UserSubscription storage userSub = userSubscriptions[msg.sender];
        require(userSub.isActive, "No active subscription found");

        userSub.isActive = false;

        emit SubscriptionCancelled(msg.sender, userSub.planId);
    }

    function isSubscriptionActive(address _user) external view returns (bool) {
        UserSubscription memory userSub = userSubscriptions[_user];
        return userSub.isActive && block.timestamp < userSub.endTime;
    }

    function getUserSubscription(address _user) external view returns (UserSubscription memory) {
        return userSubscriptions[_user];
    }

    function getSubscriptionPlan(uint256 _planId) external view returns (Subscription memory) {
        require(_planId > 0 && _planId <= planCounter, "Invalid plan ID");
        return subscriptionPlans[_planId];
    }

    function togglePlanStatus(uint256 _planId) external onlyOwner {
        require(_planId > 0 && _planId <= planCounter, "Invalid plan ID");
        subscriptionPlans[_planId].active = !subscriptionPlans[_planId].active;
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner).transfer(balance);
        emit FundsWithdrawn(owner, balance);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTotalPlans() external view returns (uint256) {
        return planCounter;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner cannot be zero address");
        owner = _newOwner;
    }

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

    function getUserRemainingTime(address _user) external view returns (uint256) {
        UserSubscription memory userSub = userSubscriptions[_user];
        if (!userSub.isActive || block.timestamp >= userSub.endTime) {
            return 0;
        }
        return userSub.endTime - block.timestamp;
    }

    function getUserSubscriptionStatus(address _user)
        external
        view
        returns (
            string memory planName,
            bool isActive,
            uint256 timeLeft,
            uint256 renewalCount
        )
    {
        UserSubscription memory userSub = userSubscriptions[_user];
        if (!userSub.isActive || block.timestamp >= userSub.endTime) {
            return ("No Active Plan", false, 0, userSub.renewalCount);
        }

        Subscription memory plan = subscriptionPlans[userSub.planId];
        return (plan.name, true, userSub.endTime - block.timestamp, userSub.renewalCount);
    }

    function getUserSubscriptionHistory(address _user)
        external
        view
        returns (
            uint256 planId,
            uint256 totalDuration,
            uint256 renewals
        )
    {
        UserSubscription memory userSub = userSubscriptions[_user];
        planId = userSub.planId;
        renewals = userSub.renewalCount;
        totalDuration = userSub.endTime > userSub.startTime
            ? userSub.endTime - userSub.startTime
            : 0;
    }

    function getUserPlanName(address _user) external view returns (string memory) {
        UserSubscription memory userSub = userSubscriptions[_user];
        if (!userSub.isActive || block.timestamp >= userSub.endTime) {
            return "No Active Plan";
        }
        return subscriptionPlans[userSub.planId].name;
    }

    function getAllUserData(address _user)
        external
        view
        returns (
            string memory planName,
            string memory description,
            bool isActive,
            uint256 startTime,
            uint256 endTime,
            uint256 remainingTime,
            uint256 renewalCount
        )
    {
        UserSubscription memory userSub = userSubscriptions[_user];
        if (!userSub.isActive || block.timestamp >= userSub.endTime) {
            return ("No Active Plan", "", false, 0, 0, 0, userSub.renewalCount);
        }

        Subscription memory plan = subscriptionPlans[userSub.planId];
        return (
            plan.name,
            plan.description,
            true,
            userSub.startTime,
            userSub.endTime,
            userSub.endTime - block.timestamp,
            userSub.renewalCount
        );
    }

    function getAllActiveSubscribers() external view onlyOwner returns (address[] memory activeUsers) {
        uint256 count = 0;
        for (uint256 i = 0; i < subscribers.length; i++) {
            UserSubscription memory userSub = userSubscriptions[subscribers[i]];
            if (userSub.isActive && block.timestamp < userSub.endTime) {
                count++;
            }
        }

        activeUsers = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < subscribers.length; i++) {
            UserSubscription memory userSub = userSubscriptions[subscribers[i]];
            if (userSub.isActive && block.timestamp < userSub.endTime) {
                activeUsers[index] = subscribers[i];
                index++;
            }
        }
    }

    function getAllSubscribers() external view onlyOwner returns (address[] memory) {
        return subscribers;
    }

    // ✅ New Function: Get all subscribers for a specific plan
    function getPlanSubscribers(uint256 _planId) external view onlyOwner returns (address[] memory) {
        require(_planId > 0 && _planId <= planCounter, "Invalid plan ID");

        uint256 count = 0;
        for (uint256 i = 0; i < subscribers.length; i++) {
            if (userSubscriptions[subscribers[i]].planId == _planId) {
                count++;
            }
        }

        address[] memory planSubscribers = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < subscribers.length; i++) {
            if (userSubscriptions[subscribers[i]].planId == _planId) {
                planSubscribers[index] = subscribers[i];
                index++;
            }
        }

        return planSubscribers;
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
