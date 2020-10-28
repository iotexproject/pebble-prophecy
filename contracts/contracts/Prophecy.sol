pragma solidity <6.0 >=0.4.24;

import "./Pausable.sol";
import "./SafeMath.sol";

contract Prophecy is Pausable {
  using SafeMath for uint256;

  event Registered(bytes32 indexed deviceID, address indexed owner); // add more details if necessary
  event Subscribed(bytes32 indexed deviceID, address indexed subscriber, uint256 startHeight, uint256 duration);
  event Claimed(address indexed claimer, uint256 amount);

  /// STORAGE MAPPINGS
  mapping (bytes32 => Device) public devices;
  mapping (bytes32 => bool) public allowedIDHashes; // allowed hashes of IDs
  mapping (address => uint256) public balanceOf;   // unclaimed payments

  uint256 public registrationFee;
  uint256 public subscriptionFee;
  uint256 public registrationFeeTotal;
  uint256 public subscriptionFeeTotal;

  /// TYPES
  struct Device {
      // Intrinsic properties
      bytes32 devicePublicKey;
      address owner;        // owner's address
      uint256 freq;         // how many seconds per data point
      bytes32 dimensions;   // we need an encoding rule for this
      string  spec;         // link to the spec
      uint256 pricePerBlock; // in terms of IOTX

      // Order info
      uint256 startHeight;    // the height starting from which this device's data stream is bought
      bytes32 storageEPoint;  // storage endpoint buyer provides
      string  storageToken;   // access token to the storage endpoint, encrypted by devicePublicKey
      uint256 duration;       // how many blocks this order lasts
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
    bytes32 _devicePublicKey,
    uint256 _freq,
    bytes32 _dimensions,
    string memory _spec,
    uint256 _price
    )
    public whenNotPaused payable returns (bool)
    {
      require(allowedIDHashes[keccak256(abi.encodePacked(_deviceId))], "id not allowed");
      require(devices[_deviceId].devicePublicKey != 0, "already registered");
      require(_devicePublicKey != 0, "device public key is required");
      require(_freq >= 0, "frequence needs to be positive");
      require(bytes(_spec).length > 0, "spec url is required");
      require(msg.value >= registrationFee, "not enough fee");

      registrationFeeTotal += msg.value;
      allowedIDHashes[keccak256(abi.encodePacked(_deviceId))] = false;
      devices[_deviceId] = Device(_devicePublicKey, msg.sender, _freq, _dimensions, _spec,
        _price, 0, 0, "", 0);
      emit Registered(_deviceId, msg.sender);
      return true;
    }

  // Pay to subscribe to the device's data stream
  function subscribe(
    bytes32 _deviceId,
    bytes32 _storageEPoint,
    string memory _storageToken,
    uint256 _duration
    ) public whenNotPaused payable returns (bool)
  {
    require(devices[_deviceId].devicePublicKey != 0, "no such a device");
    require(_storageEPoint != 0, "storage endpoint is required");
    require(bytes(_storageToken).length > 0, "storage access token is required");
    require(_duration > 0, "duration is required");
    require(msg.value >= subscriptionFee + _duration.mul(devices[_deviceId].pricePerBlock), "not enough fee");
    require(devices[_deviceId].startHeight + devices[_deviceId].duration >= block.number, "the device has been subscribed");

    subscriptionFeeTotal += subscriptionFee;
    balanceOf[devices[_deviceId].owner] += msg.value - subscriptionFee;
    devices[_deviceId].startHeight = block.number;
    devices[_deviceId].storageEPoint = _storageEPoint;
    devices[_deviceId].storageToken = _storageToken;
    devices[_deviceId].duration = _duration;
    emit Subscribed(_deviceId, msg.sender, block.number, _duration);
    return true;
  }

  // Device owner claims the payment after its matured
  function claim(bytes32 _deviceId) public whenNotPaused returns (bool)
  {
    require(devices[_deviceId].devicePublicKey != 0, "no such a device");
    require(devices[_deviceId].startHeight + devices[_deviceId].duration >= block.number, "the device has been subscribed");
    require(devices[_deviceId].owner == msg.sender, "not owner");
    uint256 balance = balanceOf[msg.sender];
    require(balance > 0, "no balance");

    balanceOf[msg.sender] = 0;
    msg.sender.transfer(balance);
    emit Claimed(msg.sender, balance);
    return true;
  }

  // Contract owner collect the fee
  function collectFees() onlyOwner public {
    uint256 total = registrationFeeTotal + subscriptionFeeTotal;
    if (total > 0) {
      registrationFeeTotal = 0;
      subscriptionFeeTotal = 0;
      msg.sender.transfer(total);
    }
  }

}
