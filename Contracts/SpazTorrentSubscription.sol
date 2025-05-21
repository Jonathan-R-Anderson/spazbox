// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SpazTorrentSubscription {
    address public owner;
    uint256 public monthlyPrice;        // Subscription fee in wei
    uint256 public gracePeriod;         // Time after expiry before deletion is allowed

    // Mapping: user => magnet => expiration timestamp
    mapping(address => mapping(string => uint256)) public subscriptions;

    event SpazSeedingStarted(address indexed user, string magnetURI, uint256 expiresAt);
    event SpazSeedingPaused(address indexed user, string magnetURI);
    event SpazSeedingDeleted(address indexed user, string magnetURI);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(uint256 _monthlyPrice, uint256 _gracePeriod) {
        owner = msg.sender;
        monthlyPrice = _monthlyPrice;
        gracePeriod = _gracePeriod;
    }

    function updateMonthlyPrice(uint256 newPrice) public onlyOwner {
        monthlyPrice = newPrice;
    }

    function updateGracePeriod(uint256 newPeriod) public onlyOwner {
        gracePeriod = newPeriod;
    }

    function subscribeToSpaz(string memory magnetURI) public payable {
        require(msg.value >= monthlyPrice, "Insufficient payment");

        uint256 currentExpiration = subscriptions[msg.sender][magnetURI];
        uint256 newExpiration = block.timestamp;

        if (currentExpiration > block.timestamp) {
            newExpiration = currentExpiration + 30 days;
        } else {
            newExpiration = block.timestamp + 30 days;
        }

        subscriptions[msg.sender][magnetURI] = newExpiration;

        emit SpazSeedingStarted(msg.sender, magnetURI, newExpiration);
    }

    function checkAndPauseSpaz(string memory magnetURI, address user) public {
        if (subscriptions[user][magnetURI] < block.timestamp) {
            emit SpazSeedingPaused(user, magnetURI);
        }
    }

    function checkAndDeleteSpaz(string memory magnetURI, address user) public onlyOwner {
        uint256 expiration = subscriptions[user][magnetURI];
        require(expiration > 0, "No subscription found");
        require(block.timestamp > expiration + gracePeriod, "Grace period not over");

        delete subscriptions[user][magnetURI];
        emit SpazSeedingDeleted(user, magnetURI);
    }
}
