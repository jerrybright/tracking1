// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Tracking {
    enum ShipmentStatus { PENDING, IN_TRANSIT, DELIVERED }

    struct Shipment {
        address sender;
        address receiver;
        uint256 pickupTime;
        uint256 deliveredTime;
        uint256 distance;
        uint256 price;
        ShipmentStatus status;
        bool isPaid;
    }

    mapping(address => Shipment[]) public shipments;
    uint256 public shipmentCount;

    struct TypeShipment {
        address sender;
        address receiver;
        uint256 pickupTime;
        uint256 deliveryTime;
        uint256 distance;
        uint256 price;
        ShipmentStatus status;
        bool isPaid;
    }

    TypeShipment[] public typeShipments;
    
    event ShipmentCreated(address indexed sender, address indexed receiver, uint256 pickupTime, uint256 distance, uint256 price);
    event ShipmentInTransit(address indexed sender, address indexed receiver, uint256 pickupTime);
    event ShipmentDelivered(address indexed sender, address indexed receiver, uint256 deliveryTime);
    event ShipmentPaid(address indexed sender, address indexed receiver, uint256 amount);

    modifier onlySender(uint256 _index) {
        require(msg.sender == shipments[msg.sender][_index].sender, "Only the sender can call this function");
        _;
    }

    constructor() {
        shipmentCount = 0;
    }

    function createShipment(address _receiver, uint256 _pickupTime, uint256 _distance, uint256 _price) public payable {
        require(msg.value == _price, "Payment amount must match the price");

        Shipment memory shipment = Shipment({
            sender: msg.sender,
            receiver: _receiver,
            pickupTime: _pickupTime,
            deliveredTime: 0,
            distance: _distance,
            price: _price,
            status: ShipmentStatus.PENDING,
            isPaid: false
        });

        shipments[msg.sender].push(shipment);
        shipmentCount++;

        typeShipments.push(TypeShipment({
            sender: msg.sender,
            receiver: _receiver,
            pickupTime: _pickupTime,
            deliveryTime: 0,
            distance: _distance,
            price: _price,
            status: ShipmentStatus.PENDING,
            isPaid: false
        }));

        emit ShipmentCreated(msg.sender, _receiver, _pickupTime, _distance, _price);
    }

    function startShipment(address _receiver, uint256 _index) public {
        Shipment storage shipment = shipments[msg.sender][_index];
        TypeShipment storage typeShipment = typeShipments[_index];

        require(shipment.receiver == _receiver, "Invalid receiver.");
        require(shipment.status == ShipmentStatus.PENDING, "Shipment already in transit.");

        shipment.status = ShipmentStatus.IN_TRANSIT;
        typeShipment.status = ShipmentStatus.IN_TRANSIT;

        emit ShipmentInTransit(msg.sender, _receiver, shipment.pickupTime);
    }

    function completeShipment(address _receiver, uint256 _index) public payable onlySender(_index) {
        Shipment storage shipment = shipments[msg.sender][_index];
        TypeShipment storage typeShipment = typeShipments[_index];

        require(shipment.receiver == _receiver, "Invalid receiver.");
        require(shipment.status == ShipmentStatus.IN_TRANSIT, "Shipment not in transit");
        require(!shipment.isPaid, "Shipment already paid.");

        shipment.status = ShipmentStatus.DELIVERED;
        typeShipment.status = ShipmentStatus.DELIVERED;
        typeShipment.deliveryTime = block.timestamp;
        shipment.deliveredTime = block.timestamp;

        uint256 amount = shipment.price;

        payable(shipment.sender).transfer(amount);
        shipment.isPaid = true;
        typeShipment.isPaid = true;

        emit ShipmentDelivered(msg.sender, _receiver, shipment.deliveredTime);
        emit ShipmentPaid(msg.sender, _receiver, amount);
    }

    function getShipment(address _receiver, uint256 _index) public view returns (address, address, uint256, uint256, uint256, uint256, ShipmentStatus, bool) {
        Shipment memory shipment = shipments[_receiver][_index];
        return (shipment.sender, shipment.receiver, shipment.pickupTime, shipment.deliveredTime, shipment.distance, shipment.price, shipment.status, shipment.isPaid);
    }

    function getShipmentsCount() public view returns (uint256) {
        return shipments[msg.sender].length;
    }

    function getAllTransactions() public view returns (TypeShipment[] memory) {
        return typeShipments;
    }
}
