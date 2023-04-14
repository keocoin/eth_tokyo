// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Subn is ERC721URIStorage {
    using Counters for Counters.Counter;

    struct Subscription {
        uint256 serviceId;
        uint256 purchaseDate;
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
        address controllerAddress;
        address payoutAddress;
        address paymentToken;
    }

    event ProviderCreated(
        uint256 providerId,
        string name,
        address payoutAddress,
        address paymentToken
    );

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
    Counters.Counter private _tokenIds;

    constructor() ERC721("GameItem", "ITM") {}

    function createService(
        string memory _name,
        uint256 _unitPrice,
        uint256 _durationTime,
        bool _isActive
    ) public returns (uint256) {
        uint256 newServiceId = _serviceIds.current();

        // Check if sender is a controller of any provider
        uint256 providerId;
        for (uint256 i = 0; i < _providerIds.current(); i++) {
            Provider memory provider = providers[i];
            if (provider.controllerAddress == msg.sender) {
                providerId = provider.Id;
                break;
            }
        }

        require(providerId >= 0, "Provider not found");

        services[newServiceId] = Service({
            Id: newServiceId,
            name: _name,
            unitPrice: _unitPrice,
            durationTime: _durationTime,
            providerId: providerId,
            isActive: _isActive
        });

        _serviceIds.increment();
        return newServiceId;
    }

    function createProvider(
        string memory _name,
        address _paymentToken
    ) public returns (uint256) {
        uint256 newProviderId = _providerIds.current();
        providers[newProviderId] = Provider({
            name: _name,
            payoutAddress: msg.sender,
            controllerAddress: msg.sender,
            paymentToken: _paymentToken,
            Id: newProviderId
        });

        _providerIds.increment();
        return newProviderId;
    }

    function toggleServiceStatus(uint256 _serviceId) public {
        Service storage service = services[_serviceId];
        require(service.Id != 0, "Service does not exist");
        require(
            msg.sender == providers[service.providerId].payoutAddress,
            "Only provider can toggle service status"
        );

        service.isActive = !service.isActive;
    }

    function subscription(uint256 _serviceId, bool _autoRenew) external {
        Service memory service = services[_serviceId];
        require(service.Id != 0, "Service does not exist");
        require(service.isActive, "Service is not active");

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);

        // Transfer payment token from payer to provider payout address
        Provider memory provider = providers[service.providerId];
        IERC20 paymentToken = IERC20(provider.paymentToken);
        uint256 requiredAmount = service.unitPrice;

        require(
            paymentToken.allowance(msg.sender, address(this)) >= requiredAmount,
            "Token transfer not approved"
        );
        require(
            paymentToken.transferFrom(
                msg.sender,
                provider.payoutAddress,
                requiredAmount
            ),
            "Token transfer failed"
        );

        uint256 expDate = block.timestamp + service.durationTime;

        subscriptions[newItemId] = Subscription({
            serviceId: _serviceId,
            purchaseDate: block.timestamp,
            expDate: expDate,
            autoRenew: _autoRenew
        });

        emit UserSubsed(
            msg.sender,
            newItemId,
            _serviceId,
            provider.Id,
            expDate
        );

        _tokenIds.increment();
    }

    function transferSubscriptionFees(uint256[] memory subIds) external {
        // Iterate over the subscription IDs and transfer payment to the service provider
        for (uint256 i = 0; i < subIds.length; i++) {
            uint256 subId = subIds[i];
            Subscription memory subn = subscriptions[subId];

            // Check if auto-renew is enabled for the subscription and expiration date is within 3 days
            if (subn.autoRenew && subn.expDate - block.timestamp <= 3 days) {
                Service memory service = services[subn.serviceId];
                require(service.isActive, "Service is not active");

                uint256 newExpDate = subn.expDate + service.durationTime;
                subscriptions[subId].purchaseDate = block.timestamp;
                subscriptions[subId].expDate = newExpDate;

                Provider memory provider = providers[service.providerId];
                address nftOwner = ownerOf(subId);
                IERC20 paymentToken = IERC20(provider.paymentToken);
                uint256 requiredAmount = service.unitPrice;

                require(
                    paymentToken.allowance(nftOwner, address(this)) >=
                        requiredAmount,
                    "Token transfer not approved"
                );
                require(
                    paymentToken.transferFrom(
                        nftOwner,
                        provider.payoutAddress,
                        requiredAmount
                    ),
                    "Token transfer failed"
                );

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

    function structToString(
        Subscription memory subn
    ) public pure returns (string memory) {
        bytes memory subscriptionData = abi.encode(subn);
        return string(subscriptionData);
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        Subscription memory subn = subscriptions[_tokenId];
        return structToString(subn);
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
