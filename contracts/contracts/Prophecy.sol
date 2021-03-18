pragma solidity <6.0 >=0.4.24;

import "./Pausable.sol";
import "./SafeMath.sol";

contract Prophecy is Pausable {
  using SafeMath for uint256;

  event Registered(address indexed deviceID, address indexed owner); // add more details if necessary
  event Subscribed(address indexed deviceID, address indexed subscriber, uint256 startHeight, uint256 duration, uint256 income);
  event Claimed(address indexed deviceID, address indexed claimer, uint256 amount);
  event Updated(address indexed deviceID, address indexed owner); // add more details if necessary

  /// STORAGE MAPPINGS
  address[] public deviceIDs;
  mapping (address => Device) public devices;
  mapping (address => Order) public orders;
  mapping (address => uint8) public whitelist; // whitelisted device addresses

  uint256 public registrationFee;
  uint256 public subscriptionFee;
  uint256 public registrationFeeTotal;
  uint256 public subscriptionFeeTotal;

  uint256 public constant maxDuration = 86400 / 5 * 90; // 90 days

  /// TYPES
  struct Device {
      // Intrinsic properties
      address owner;          // owner's address
      bool    hasOrder;       // order placed
      uint32  freq;           // how many seconds per data point
      uint256 pricePerBlock;  // in terms of IOTX, in RAUL/Wei (which 1e-18)
      uint256 settledBalance; // balance ready to claim
      uint256 pendingBalance; // balance in pending
      string  spec;           // link to the spec
      bytes   rsaPubkeyN;     // RSA public key N
      bytes   rsaPubkeyE;     // RSA public key E
  }

  struct Order {
      // Order info
      uint256 startHeight;  // the height starting from which this device's data stream is bought
      uint256 duration;     // how many blocks this order lasts
      string storageEPoint; // storage endpoint buyer provides
      string storageToken;  // access token to the storage endpoint, encrypted by devicePublicKey
  }

  // CONSTRUCTOR
  constructor () public {
  }

  // EXTERNAL FUNCTIONS
  function setRegistrationFee(uint256 fee) public onlyOwner {
    registrationFee = fee;
  }

  function setSubscriptionFee(uint256 fee) public onlyOwner {
    subscriptionFee = fee;
  }

  // Populate the whitelist after manufacturing
  function preRegisterDevice(address _deviceId)
    public onlyOwner whenNotPaused returns (bool)
    {
      require(whitelist[_deviceId] == 0, "already whitelisted");

      whitelist[_deviceId] = 1;
      return true;
    }

  // Pay to Register the device
  function registerDevice(
    address _deviceId,
    uint32 _freq,
    uint256 _price,
    string memory _spec,
    bytes memory _rsaPubkeyN,
    bytes memory _rsaPubkeyE
    )
    public whenNotPaused payable returns (bool)
    {
      //require(_ownerAddr != address(0), "invalid owner address");
      require(whitelist[_deviceId] == 1, "id not allowed");
      require(devices[_deviceId].rsaPubkeyN.length == 0, "already registered");
      require(devices[_deviceId].rsaPubkeyE.length == 0, "already registered");
      require(_rsaPubkeyN.length != 0, "RSA public key N required");
      require(_rsaPubkeyE.length != 0, "RSA public key E required");
      require(_freq >= 0, "frequence needs to be positive");
      require(bytes(_spec).length > 0, "spec url is required");
      require(msg.value >= registrationFee, "not enough fee");

      registrationFeeTotal += msg.value;
      devices[_deviceId] = Device(msg.sender, false, _freq, _price, 0, 0, _spec, _rsaPubkeyN, _rsaPubkeyE);
      deviceIDs.push(_deviceId);
      whitelist[_deviceId] = 2;
      emit Registered(_deviceId, msg.sender);
      return true;
    }

    // Update info about a registered device
    function updateDevice(
      address _deviceId,
      uint32 _freq,
      uint256 _price,
      string memory _spec,
      bytes memory _rsaPubkeyN,
      bytes memory _rsaPubkeyE
      )
      public whenNotPaused returns (bool)
      {
        require(_deviceId != address(0), "invalid device address");
        require(devices[_deviceId].rsaPubkeyN.length != 0, "not yet registered");
        require(devices[_deviceId].rsaPubkeyE.length != 0, "not yet registered");
        require(devices[_deviceId].owner == msg.sender, "not owner");
        require(_rsaPubkeyN.length != 0, "RSA public key N required");
        require(_rsaPubkeyE.length != 0, "RSA public key E required");
        require(_freq != 0, "frequence cannot be zero");
        require(bytes(_spec).length > 0, "spec url is required");

        // To be on the safe side, tho we can allow change when a device is subscribed
        if (devices[_deviceId].hasOrder) {
          require(orders[_deviceId].startHeight + orders[_deviceId].duration < block.number, "device in active subscription");
        }

        devices[_deviceId].freq = _freq;
        devices[_deviceId].pricePerBlock = _price;
        devices[_deviceId].spec = _spec;
        devices[_deviceId].rsaPubkeyN = _rsaPubkeyN;
        devices[_deviceId].rsaPubkeyE = _rsaPubkeyE;
        emit Updated(_deviceId, msg.sender);
        return true;
      }

  // Pay to subscribe to the device's data stream
  function subscribe(
    address _deviceId,
    uint256 _duration,
    string memory _storageEPoint,
    string memory _storageToken
    ) public whenNotPaused payable returns (bool)
  {
    require(_deviceId != address(0), "invalid device address");
    require(devices[_deviceId].rsaPubkeyN.length != 0, "no such device");
    require(devices[_deviceId].rsaPubkeyE.length != 0, "no such device");
    require(bytes(_storageEPoint).length > 0, "storage endpoint required");
    require(_duration > 0 && _duration <= maxDuration, "inappropriate duration");
    require(msg.value >= subscriptionFee + _duration.mul(devices[_deviceId].pricePerBlock), "not enough fee");

    if (devices[_deviceId].hasOrder) {
      require(orders[_deviceId].startHeight + orders[_deviceId].duration < block.number, "device in active subscription");
      orders[_deviceId].startHeight = block.number;
      orders[_deviceId].duration = _duration;
      orders[_deviceId].storageEPoint = _storageEPoint;
      orders[_deviceId].storageToken = _storageToken;
    } else {
      // first time subscrible
      devices[_deviceId].hasOrder = true;
      orders[_deviceId] = Order(block.number, _duration, _storageEPoint, _storageToken);
    }

    subscriptionFeeTotal += subscriptionFee;
    if (devices[_deviceId].pendingBalance > 0) {
      devices[_deviceId].settledBalance = devices[_deviceId].settledBalance.add(devices[_deviceId].pendingBalance);
    }
    devices[_deviceId].pendingBalance = msg.value.sub(subscriptionFee);
    emit Subscribed(_deviceId, msg.sender, block.number, _duration, devices[_deviceId].pendingBalance);
    return true;
  }

  // Device owner claims the payment after its matured
  function claim(address _deviceId) public whenNotPaused returns (bool)
  {
    require(_deviceId != address(0), "invalid device address");
    require(devices[_deviceId].rsaPubkeyN.length != 0, "no such device");
    require(devices[_deviceId].rsaPubkeyE.length != 0, "no such device");
    require(devices[_deviceId].owner == msg.sender, "not owner");
    require(devices[_deviceId].hasOrder, "device not yet subscribed");
    require(orders[_deviceId].startHeight + orders[_deviceId].duration < block.number, "device in active subscription");

    if (devices[_deviceId].pendingBalance > 0) {
      devices[_deviceId].settledBalance = devices[_deviceId].settledBalance.add(devices[_deviceId].pendingBalance);
      devices[_deviceId].pendingBalance = 0;
    }
    uint256 balance = devices[_deviceId].settledBalance;
    require(balance > 0, "no balance");

    devices[_deviceId].settledBalance = 0;
    msg.sender.transfer(balance);
    emit Claimed(_deviceId, msg.sender, balance);
    return true;
  }

  // Contract owner collect the fee
  function collectFees() onlyOwner public returns (bool) {
    uint256 total = registrationFeeTotal + subscriptionFeeTotal;
    if (total > 0) {
      registrationFeeTotal = 0;
      subscriptionFeeTotal = 0;
      msg.sender.transfer(total);
    }
    return true;
  }

  // Get device addrs with pagination
  function getDeviceAddrs(uint256 _offset, uint8 limit)
    public view returns (uint256 count, address[] memory ids) {
      require(_offset < deviceIDs.length && limit != 0);

      ids = new address[](limit);
      for (uint256 i = 0; i < limit; i++) {
          if (_offset + i >= deviceIDs.length) {
              break;
          }
          ids[count] = deviceIDs[_offset + i];
          count++;
      }
  }

  // Get device info by addr
  function getDeviceInfoByAddr(
    address _deviceId
  ) public view returns (address, uint32, uint256, uint256, uint256, string memory, bytes memory, bytes memory) {
    require(_deviceId != address(0), "invalid device address");
    require(devices[_deviceId].rsaPubkeyN.length != 0, "no such device");
    require(devices[_deviceId].rsaPubkeyE.length != 0, "no such device");

    Device memory d = devices[_deviceId];
    return (d.owner, d.freq, d.pricePerBlock, d.settledBalance, d.pendingBalance, d.spec, d.rsaPubkeyN, d.rsaPubkeyE);
  }

  // Get device order by addr
  function getDeviceOrderByAddr(
      address _deviceId
    ) public view returns (uint256, uint256, string memory, string memory) {
      require(_deviceId != address(0), "invalid device address");
      require(devices[_deviceId].rsaPubkeyN.length != 0, "no such device");
      require(devices[_deviceId].rsaPubkeyE.length != 0, "no such device");

      if (devices[_deviceId].hasOrder) {
        Order memory o = orders[_deviceId];
        return (o.startHeight, o.duration, o.storageEPoint, o.storageToken);
      }
      return (0, 0, "", "");
    }
}
