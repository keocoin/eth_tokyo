// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Subn {
    using Counters for Counters.Counter;

    struct Subscription {
        address userId;
        uint256 serviceId;
        uint256 lastPurchaseDate;
        uint256 expDate;
        bool autoRenew;
    }

    struct Service {
        uint256 Id;
        string name;
        uint256 unitPrice;
        uint256 durationTime;
        uint256 providerId;
        bool isActive;
    }

    struct Provider {
        uint256 Id;
        string name;
        address providerAddress;
    }

    event ProviderCreated(uint256 providerId, string name);

    event ServiceCreated(
        uint256 serviceId,
        string name,
        uint256 unitPrice,
        uint256 durationTime,
        bool isActive
    );

    event UserSubsed(
        address userAddress,
        uint256 tokeId,
        uint256 serviceId,
        uint256 providerId,
        uint256 expDate
    );

    event SubnRenewed(
        address userAddress,
        uint256 tokeId,
        uint256 serviceId,
        uint256 providerId,
        uint256 expDate
    );

    mapping(uint256 => Service) services;
    mapping(uint256 => Provider) providers;
    mapping(uint256 => Subscription) subscriptions;

    Counters.Counter private _providerIds;
    Counters.Counter private _serviceIds;
    Counters.Counter private _subIds;

    IERC20 public paymentToken;

    constructor(address _paymentToken) {
        paymentToken = IERC20(_paymentToken);
    }

    function createService(
        string memory _name,
        uint256 _unitPrice,
        uint256 _durationTime
    ) public returns (uint256) {
        uint256 providerId;
        for (uint256 i = 0; i < _providerIds.current(); i++) {
            Provider memory provider = providers[i];
            if (provider.providerAddress == msg.sender) {
                providerId = provider.Id;
                break;
            }
        }

        require(providerId > 0, "Provider not found");

        _serviceIds.increment();

        uint256 newServiceId = _serviceIds.current();

        services[newServiceId] = Service({
            Id: newServiceId,
            name: _name,
            unitPrice: _unitPrice,
            durationTime: _durationTime,
            providerId: providerId,
            isActive: true
        });

        return newServiceId;
    }

    function createProvider(string memory _name) public returns (uint256) {
        _providerIds.increment();
        uint256 newProviderId = _providerIds.current();
        providers[newProviderId] = Provider({
            name: _name,
            providerAddress: msg.sender,
            Id: newProviderId
        });

        return newProviderId;
    }

    function toggleServiceStatus(uint256 _serviceId) public {
        Service storage service = services[_serviceId];
        require(service.Id != 0, "Service does not exist");
        require(
            msg.sender == providers[service.providerId].providerAddress,
            "Only provider can toggle service status"
        );

        service.isActive = !service.isActive;
    }

    function subscription(uint256 _serviceId, bool _autoRenew) external {
        Service memory service = services[_serviceId];
        require(service.Id != 0, "Service does not exist");
        require(service.isActive, "Service is not active");

        _subIds.increment();
        uint256 newSubId = _subIds.current();

        // Transfer payment token from payer to provider payout address
        Provider memory provider = providers[service.providerId];
        uint256 requiredAmount = service.unitPrice;

        require(
            paymentToken.allowance(msg.sender, address(this)) >= requiredAmount,
            "Token transfer not approved"
        );
        require(
            paymentToken.transferFrom(
                msg.sender,
                provider.providerAddress,
                requiredAmount
            ),
            "Token transfer failed"
        );

        uint256 expDate = block.timestamp + service.durationTime;

        subscriptions[newSubId] = Subscription({
            userId: msg.sender,
            serviceId: _serviceId,
            lastPurchaseDate: block.timestamp,
            expDate: expDate,
            autoRenew: _autoRenew
        });

        emit UserSubsed(msg.sender, newSubId, _serviceId, provider.Id, expDate);
    }

    function transferSubscriptionFees(uint256[] memory subIds) external {
        // Iterate over the subscription IDs and transfer payment to the service provider
        for (uint256 i = 1; i < subIds.length; i++) {
            uint256 subId = subIds[i];
            Subscription memory subn = subscriptions[subId];
            if (!subn.autoRenew) {
                continue;
            }

            // Check if auto-renew is enabled for the subscription and expiration date is within 3 days
            if (
                subn.expDate < block.timestamp ||
                subn.expDate - block.timestamp <= 3 days
            ) {
                Service memory service = services[subn.serviceId];
                require(service.isActive, "Service is not active");

                uint256 requiredAmount = service.unitPrice;
                require(
                    paymentToken.allowance(
                        subscriptions[subId].userId,
                        address(this)
                    ) >= requiredAmount,
                    "Token transfer not approved"
                );

                Provider memory provider = providers[service.providerId];
                require(
                    paymentToken.transferFrom(
                        subscriptions[subId].userId,
                        provider.providerAddress,
                        requiredAmount
                    ),
                    "Token transfer failed"
                );

                uint256 newExpDate = service.durationTime +
                    (
                        subn.expDate < block.timestamp
                            ? block.timestamp
                            : subn.expDate
                    );
                subscriptions[subId].lastPurchaseDate = block.timestamp;
                subscriptions[subId].expDate = newExpDate;

                emit SubnRenewed(
                    msg.sender,
                    subId,
                    service.Id,
                    provider.Id,
                    newExpDate
                );
            }
        }
    }

    function getService(
        uint256 _serviceId
    ) public view returns (Service memory) {
        return services[_serviceId];
    }

    function getProvider(
        uint256 _providerId
    ) public view returns (Provider memory) {
        return providers[_providerId];
    }
}
