# Prophecy

Prophecy is the contract framework for enabling trusted devices (such as Pebble) to trade the data stream it produces with end-to-end trustworthiness.


## Workflow

1. A device sends meta information to the contract to register itself. This is a one-time effort.
  
2. When the device started, it listens to the contract.

3. When it sees its order, the device switches to use `buyers` MQTT endpoint to send data too. Note that the buyer has to setup the backend (hmq+min.io+Thingsboard) as documented [here](https://github.com/iotexproject/pebble-backend).

## Details

Details can be found here - https://github.com/iotexproject/pebble-prophecy/tree/main/contracts.
