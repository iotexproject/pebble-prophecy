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
```
ioctl contract invoke function io128vsgx4fg7rmd2n8s090f5phamfagc4rryj4u6 a.abi preRegisterDevice --with-arguments '{"_deviceIdHash":"0x1f214438d7c061ad56f98540db9a082d372df1ba9a3c96367f0103aa16c2fe9a"}' --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/a551a42da2eaa8921af05d07b89f47ac64e4c5ba49db97ba6176cd09d88b7f72```
