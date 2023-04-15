// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Subscriptions {
    using Counters for Counters.Counter;

    struct Service {
        uint256 id;
        string name;
        uint256 unitPrice;
        uint256 durationTime;
        address provider;
        bool isActive;
    }

    struct Subscription {
        uint256 id;
        address user;
        uint256 serviceId;
        uint256 lastPurchaseDate;
        uint256 expDate;
        bool autoRenew;
    }

    event ServiceCreated(
        uint256 id,
        string name,
        uint256 unitPrice,
        uint256 durationTime,
        bool isActive
    );

    event Subscribe(
        uint256 id,
        address user,
        uint256 serviceId,
        address provider,
        uint256 expDate,
        bool isRenew
    );

    event Unsubscribe(
        uint256 subId,
        address user,
        uint256 serviceId,
        address provider
    );

    event AllowanceRemaining(address indexed user, uint256 allowance);

    mapping(uint256 => Service) private services;
    mapping(uint256 => Subscription) private subscriptions;

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
    ) external returns (uint256 newServiceId) {
        _serviceIds.increment();

        newServiceId = _serviceIds.current();

        services[newServiceId] = Service({
            id: newServiceId,
            name: _name,
            unitPrice: _unitPrice,
            durationTime: _durationTime,
            provider: msg.sender,
            isActive: true
        });

        emit ServiceCreated(
            newServiceId,
            _name,
            _unitPrice,
            _durationTime,
            true
        );
    }

    function toggleServiceStatus(uint256 _serviceId) external {
        Service storage service = services[_serviceId];
        require(service.id != 0, "Service does not exist");
        require(
            msg.sender == service.provider,
            "Only provider can toggle service status"
        );

        service.isActive = !service.isActive;
    }

    function subscribe(
        uint256 _serviceId,
        bool _autoRenew
    ) external returns (uint256 newSubId) {
        Service storage service = services[_serviceId];
        require(service.id != 0, "Service does not exist");
        require(service.isActive, "Service is not active");

        _subIds.increment();
        newSubId = _subIds.current();

        uint256 requiredAmount = service.unitPrice;

        require(
            paymentToken.allowance(msg.sender, address(this)) >= requiredAmount,
            "Token transfer not approved"
        );

        require(
            paymentToken.transferFrom(
                msg.sender,
                service.provider,
                requiredAmount
            ),
            "Token transfer failed"
        );

        uint256 expDate = block.timestamp + service.durationTime;

        subscriptions[newSubId] = Subscription({
            id: newSubId,
            user: msg.sender,
            serviceId: _serviceId,
            lastPurchaseDate: block.timestamp,
            expDate: expDate,
            autoRenew: _autoRenew
        });

        // Emit an event to show the remaining allowance of the user
        uint256 remainingAllowance = paymentToken.allowance(
            msg.sender,
            address(this)
        );
        emit AllowanceRemaining(msg.sender, remainingAllowance);

        emit Subscribe(
            newSubId,
            msg.sender,
            _serviceId,
            service.provider,
            expDate,
            false
        );
    }

    function transferSubscriptionFees(uint256[] calldata subIds) external {
        for (uint256 i = 0; i < subIds.length; i++) {
            uint256 subId = subIds[i];
            Subscription storage _subscription = subscriptions[subId];
            if (!_subscription.autoRenew) {
                continue;
            }

            Service storage service = services[_subscription.serviceId];
            require(service.isActive, "Service is not active");

            uint256 requiredAmount = service.unitPrice;
            require(
                paymentToken.allowance(_subscription.user, address(this)) >=
                    requiredAmount,
                "Token transfer not approved"
            );

            require(
                paymentToken.transferFrom(
                    _subscription.user,
                    service.provider,
                    requiredAmount
                ),
                "Token transfer failed"
            );

            uint256 newExpDate = service.durationTime +
                (
                    _subscription.expDate < block.timestamp
                        ? block.timestamp
                        : _subscription.expDate
                );

            _subscription.lastPurchaseDate = block.timestamp;
            _subscription.expDate = newExpDate;

            // Emit an event to show the remaining allowance of the user
            uint256 remainingAllowance = paymentToken.allowance(
                _subscription.user,
                address(this)
            );
            emit AllowanceRemaining(_subscription.user, remainingAllowance);

            emit Subscribe(
                _subscription.id,
                _subscription.user,
                service.id,
                service.provider,
                _subscription.expDate,
                true
            );
        }
    }

    function getAllServices() public view returns (Service[] memory) {
        Service[] memory allServices = new Service[](_serviceIds.current());

        for (uint256 i = 1; i <= _serviceIds.current(); i++) {
            allServices[i - 1] = services[i];
        }

        return allServices;
    }

    function getServiceDetails(
        uint256 _serviceId
    )
        public
        view
        returns (uint256, string memory, uint256, uint256, address, bool)
    {
        Service memory service = services[_serviceId];
        return (
            service.id,
            service.name,
            service.unitPrice,
            service.durationTime,
            service.provider,
            service.isActive
        );
    }

    function unsubscribe(uint256 _subId) public {
        Subscription storage subn = subscriptions[_subId];
        require(subn.id != 0, "Subscription does not exist");
        require(
            subn.user == msg.sender,
            "You do not have permission to unsubscribe"
        );

        Service storage service = services[subn.serviceId];
        require(service.isActive, "Service is not active");

        // Remove the subscription from the subscriptions mapping
        subscriptions[_subId].autoRenew = false;

        emit Unsubscribe(_subId, msg.sender, subn.serviceId, service.provider);
    }

    function getAllowance(address _owner) public view returns (uint256) {
        IERC20 token = IERC20(paymentToken);
        return token.allowance(_owner, address(this));
    }
}
