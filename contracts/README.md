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
We use `io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28` deployed on testnet (via this [action](https://testnet.iotexscan.io/action/2d371248a62be44370e6b10c6ba11ff7491674e84546bcc1f711fb955c6a032c)) as an example to invoke.

**setRegistrationFee()**
```
ioctl contract invoke function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi setRegistrationFee --with-arguments '{"fee":"1"}' --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/1ec24eff9325997e5db149b31882676bbca1f2b8daaf157136dd217c32ffe054
```

**registrationFee()**
```
ioctl contract test function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi registrationFee --endpoint api.testnet.iotex.one:443
return: 1
```

**setSubscriptionFee()**
```
ioctl contract invoke function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi setSubscriptionFee --with-arguments '{"fee":"1"}' --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/b9587a00d06d69f0210469f1ab7627dab0d8e800649b8c6b748a4d2ce9574e85
```

**subscriptionFee()**
```
ioctl contract test function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi subscriptionFee --endpoint api.testnet.iotex.one:443
return: 1
```

**preRegisterDevice()**
Assume deivce id is 352656100794612
```
ioctl contract invoke function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi preRegisterDevice --with-arguments '{"_deviceIdHash":"0x87b94e1b4114ed2746e032605265993b811798401bee23d749a8f3c61f0ae16a"}' --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/8d72d2843a8b36ac644e58c8259f9f7485fa514204d6cf970e954415a273cd5e
```

**registerDevice()**
Assume deivce id is 352656100794612
```
ioctl contract invoke function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi registerDevice --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373934363132","_devicePubKeyX":"0x22346c407294b5e37487395f193faa48dabfc2225ab33fe47b335299f46505b1","_devicePubKeyY":"0x689f0d96fd53bd19971fe47f310669cf6260dcdc23318454814a4fe904f4d384","_freq":"30","_price":"1","_spec":"trypebble.io/123"}' -l 10000000 --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/ffec6719c510bec3bd3e68df4e594bb318fb5a40b875ef653c913707970de32a
```

**getDeviceInfoByID()**
```
ioctl contract test function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi getDeviceInfoByID --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373934363132"}' --endpoint api.testnet.iotex.one:443
return: 22346c407294b5e37487395f193faa48dabfc2225ab33fe47b335299f46505b1689f0d96fd53bd19971fe47f310669cf6260dcdc23318454814a4fe904f4d38400000000000000000000000053fbc28faf9a52dfe5f591948a23189e900381b5000000000000000000000000000000000000000000000000000000000000001e00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000010747279706562626c652e696f2f31323300000000000000000000000000000000
```

**subscribe()**
Assume deivce id is 352656100794612, subscribe for 4 blocks
```
ioctl contract invoke function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi subscribe 10 --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373934363132","_duration":"4","_storageEPoint":"trypebble.io/123456","_storageToken":"abcdef"}' -l 10000000 --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/f7626ce6784cbbcb80cef065d3bb2a0ba9870d4e735dbe3e202e7a75b19531b5
```

**getDeviceOrderByID()**
```
ioctl contract test function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi getDeviceOrderByID --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373934363132"}' --endpoint api.testnet.iotex.one:443
return: 00000000000000000000000000000000000000000000000000000000005f77f80000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000013747279706562626c652e696f2f3132333435360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066162636465660000000000000000000000000000000000000000000000000000 
```
