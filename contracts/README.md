This contract implements the registration and pay-to-subscribe flow of the device.

## Compile
```truffle compile```

## Test
```truffle test```

## Testnet

### Deploy
```ioctl contract compile Prophecy --abi-out a.abi --bin-out a.bin```
``` ioctl contract deploy bin a.bin --endpoint api.testnet.iotex.one:443```

### Invoke
We use `io128vsgx4fg7rmd2n8s090f5phamfagc4rryj4u6` deployed on testnet (via this [action](https://testnet.iotexscan.io/action/715f555489d03d9a44e618a0113e75ef1777e0201acf9e984b67c75770386b51)) as an example to invoke.

**setRegistrationFee()**
```
ioctl contract invoke function io128vsgx4fg7rmd2n8s090f5phamfagc4rryj4u6 a.abi setRegistrationFee --with-arguments '{"fee":"1"}' --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/2dc76d074c97b6dea0a377b9f0fde77b5067ce99b7f0a3a4441576fb2de5c88f
```

**registrationFee()**
```
ioctl contract test function io128vsgx4fg7rmd2n8s090f5phamfagc4rryj4u6 a.abi registrationFee --endpoint api.testnet.iotex.one:443
return: 1
```

**preRegisterDevice()**
Assume deivce id is 352656100794612
```
ioctl contract invoke function io128vsgx4fg7rmd2n8s090f5phamfagc4rryj4u6 a.abi preRegisterDevice --with-arguments '{"_deviceIdHash":"0xd8617ccedb8339fc2e7e790455c868828acde6b3e95919a8c31aed3c6cc45a95"}' --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/4ab39cf18d86624eba0ff51a54d8b58c763ed515896cd3a9434197d913275578
```

**registerDevice()**
Assume deivce id is 352656100794612
```
ioctl contract invoke function io128vsgx4fg7rmd2n8s090f5phamfagc4rryj4u6 a.abi registerDevice --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373934363132","_devicePubKeyX":"0x0000000000000000000000000000000000000000000000000000000000012345","_devicePubKeyY":"0x0000000000000000000000000000000000000000000000000000000000012345","_freq":"30","_spec":"trypebble.io/123","_price":"1"}' -l 10000000 --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/16bc89698809e640d57be750ff22f87b8dfcfed4b2d03721e37398e5f57b4323
```


