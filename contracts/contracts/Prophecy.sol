pragma solidity <6.0 >=0.4.24;

import "./Pausable.sol";
import "./SafeMath.sol";

contract Prophecy is Pausable {
  using SafeMath for uint256;

  event Registered(bytes32 indexed deviceID, address indexed owner); // add more details if necessary
  event Subscribed(bytes32 indexed deviceID, address indexed subscriber, uint256 startHeight, uint256 duration, uint256 income);
  event Claimed(bytes32 indexed deviceID, address indexed claimer, uint256 amount);
  event Updated(bytes32 indexed deviceID, address indexed owner); // add more details if necessary

  /// STORAGE MAPPINGS
  bytes32[] public deviceIDs;
  mapping (bytes32 => Device) public devices;
  mapping (bytes32 => bool) public allowedIDHashes; // allowed hashes of IDs

  uint256 public registrationFee;
  uint256 public subscriptionFee;
  uint256 public registrationFeeTotal;
  uint256 public subscriptionFeeTotal;

  uint256 public constant maxDuration = 86400 / 5 * 90; // 90 days

  /// TYPES
  struct Device {
      // Intrinsic properties
      bytes32 devicePubKeyX; // device public key X co-ordinate
      bytes32 devicePubKeyY; // device public key Y co-ordinate
      address owner;        // owner's address
      uint256 freq;         // how many seconds per data point
      uint256 pricePerBlock; // in terms of IOTX
      uint256 settledBalance; // balance ready to claim
      uint256 pendingBalance; // balance in pending
      string  spec;         // link to the spec

      // Order info
      uint256 startHeight;    // the height starting from which this device's data stream is bought
      uint256 duration;       // how many blocks this order lasts
      string storageEPoint;  // storage endpoint buyer provides
      string storageToken;   // access token to the storage endpoint, encrypted by devicePublicKey
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
  function preRegisterDevice(bytes32 _deviceIdHash)
    public onlyOwner whenNotPaused returns (bool)
    {
      require(!allowedIDHashes[_deviceIdHash], "already whitelisted");

      allowedIDHashes[_deviceIdHash] = true;
      return true;
    }

  // Pay to Register the device
  function registerDevice(
    bytes32 _deviceId,
    bytes32 _devicePubKeyX,
    bytes32 _devicePubKeyY,
    uint256 _freq,
    string memory _spec,
    uint256 _price
    )
    public whenNotPaused payable returns (bool)
    {
      require(allowedIDHashes[keccak256(abi.encodePacked(_deviceId))], "id not allowed");
      require(devices[_deviceId].devicePubKeyX == 0, "already registered");
      require(devices[_deviceId].devicePubKeyY == 0, "already registered");
      require(_devicePubKeyX != 0, "device public key X required");
      require(_devicePubKeyY != 0, "device public key Y required");
      require(_freq >= 0, "frequence needs to be positive");
      require(bytes(_spec).length > 0, "spec url is required");
      require(msg.value >= registrationFee, "not enough fee");

      registrationFeeTotal += msg.value;
      allowedIDHashes[keccak256(abi.encodePacked(_deviceId))] = false;
      devices[_deviceId] = Device(_devicePubKeyX, _devicePubKeyY, msg.sender, _freq,
        _price, 0, 0, _spec, 0, 0, "", "");
      deviceIDs.push(_deviceId);
      emit Registered(_deviceId, msg.sender);
      return true;
    }

    // Update info about a registered device
    function updateDevice(
      bytes32 _deviceId,
      bytes32 _devicePubKeyX,
      bytes32 _devicePubKeyY,
      uint256 _freq,
      string memory _spec,
      uint256 _price
      )
      public whenNotPaused returns (bool)
      {
        require(devices[_deviceId].devicePubKeyX != 0, "not yet registered");
        require(devices[_deviceId].devicePubKeyY != 0, "not yet registered");
        require(devices[_deviceId].owner == msg.sender, "not owner");
        require(_devicePubKeyX != 0, "device public key X required");
        require(_devicePubKeyY != 0, "device public key Y required");
        require(_freq >= 0, "frequence needs to be positive");
        require(bytes(_spec).length > 0, "spec url is required");

        // To be on the safe side, tho we can allow change when a device is subscribed
        uint256 endHeight = devices[_deviceId].startHeight + devices[_deviceId].duration;
        require(endHeight == 0 || endHeight < block.number, "device in active subscription");

        devices[_deviceId] = Device(_devicePubKeyX, _devicePubKeyY, msg.sender, _freq, _price,
          devices[_deviceId].settledBalance, devices[_deviceId].pendingBalance, _spec,
          devices[_deviceId].startHeight, devices[_deviceId].duration,
          devices[_deviceId].storageEPoint, devices[_deviceId].storageToken);

        emit Updated(_deviceId, msg.sender);
        return true;
      }

  // Pay to subscribe to the device's data stream
  function subscribe(
    bytes32 _deviceId,
    string memory _storageEPoint,
    string memory _storageToken,
    uint256 _duration
    ) public whenNotPaused payable returns (bool)
  {
    require(devices[_deviceId].devicePubKeyX != 0, "no such device");
    require(devices[_deviceId].devicePubKeyY != 0, "no such device");
    require(bytes(_storageEPoint).length > 0, "storage endpoint required");
    require(bytes(_storageToken).length > 0, "storage access token required");
    require(_duration > 0 && _duration <= maxDuration, "inappropriate duration");
    require(msg.value >= subscriptionFee + _duration.mul(devices[_deviceId].pricePerBlock), "not enough fee");
    uint256 endHeight = devices[_deviceId].startHeight + devices[_deviceId].duration;
    require(endHeight == 0 || endHeight < block.number, "device in active subscription");

    subscriptionFeeTotal += subscriptionFee;
    devices[_deviceId].startHeight = block.number;
    devices[_deviceId].storageEPoint = _storageEPoint;
    devices[_deviceId].storageToken = _storageToken;
    devices[_deviceId].duration = _duration;
    if (devices[_deviceId].pendingBalance > 0) {
      devices[_deviceId].settledBalance = devices[_deviceId].settledBalance.add(devices[_deviceId].pendingBalance);
    }
    devices[_deviceId].pendingBalance = msg.value.sub(subscriptionFee);
    emit Subscribed(_deviceId, msg.sender, block.number, _duration, devices[_deviceId].pendingBalance);
    return true;
  }

  // Device owner claims the payment after its matured
  function claim(bytes32 _deviceId) public whenNotPaused returns (bool)
  {
    require(devices[_deviceId].owner == msg.sender, "not owner");
    require(devices[_deviceId].devicePubKeyX != 0, "no such device");
    require(devices[_deviceId].devicePubKeyY != 0, "no such device");
    uint256 endHeight = devices[_deviceId].startHeight + devices[_deviceId].duration;
    require(endHeight > 0, "device not yet subscribed");
    require(endHeight < block.number, "device in active subscription");
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

  // Get device IDs with pagination
  function getDeviceIDs(uint256 _offset, uint8 limit)
    public view returns (uint256 count, bytes32[] memory ids) {
      require(_offset < deviceIDs.length && limit != 0);

      ids = new bytes32[](limit);
      for (uint256 i = 0; i < limit; i++) {
          if (_offset + i >= deviceIDs.length) {
              break;
          }
          ids[count] = deviceIDs[_offset + i];
          count++;
      }
  }

  // Get device info by ID
  function getDeviceInfoByID(
    bytes32 _deviceId
  ) public view returns (bytes32, bytes32, address, uint256, uint256, uint256, uint256, string memory) {
    require(devices[_deviceId].devicePubKeyX != 0, "no such device");
    require(devices[_deviceId].devicePubKeyY != 0, "no such device");

    Device memory d = devices[_deviceId];
    return (d.devicePubKeyX, d.devicePubKeyY, d.owner, d.freq, d.pricePerBlock,
      d.settledBalance, d.pendingBalance, d.spec);
  }

  // Get device order by ID
  function getDeviceOrderByID(
      bytes32 _deviceId
    ) public view returns (uint256, uint256, string memory, string memory) {
      require(devices[_deviceId].devicePubKeyX != 0, "no such device");
      require(devices[_deviceId].devicePubKeyY != 0, "no such device");

      Device memory d = devices[_deviceId];
      return (d.startHeight, d.duration, d.storageEPoint, d.storageToken);
    }
}
