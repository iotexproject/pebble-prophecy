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
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/2dc76d074c97b6dea0a377b9f0fde77b5067ce99b7f0a3a4441576fb2de5c88f
```

**registrationFee()**
```
ioctl contract test function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi registrationFee --endpoint api.testnet.iotex.one:443
return: 1
```

**preRegisterDevice()**
Assume deivce id is 352656100794612
```
ioctl contract invoke function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi preRegisterDevice --with-arguments '{"_deviceIdHash":"0x87b94e1b4114ed2746e032605265993b811798401bee23d749a8f3c61f0ae16a"}' --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/4ab39cf18d86624eba0ff51a54d8b58c763ed515896cd3a9434197d913275578
```

**registerDevice()**
Assume deivce id is 352656100794612
```
ioctl contract invoke function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi registerDevice --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373934363132","_devicePubKeyX":"0x22346c407294b5e37487395f193faa48dabfc2225ab33fe47b335299f46505b1","_devicePubKeyY":"0x689f0d96fd53bd19971fe47f310669cf6260dcdc23318454814a4fe904f4d384","_freq":"30","_price":"1","_spec":"trypebble.io/123"}' -l 10000000 --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/16bc89698809e640d57be750ff22f87b8dfcfed4b2d03721e37398e5f57b4323
```

**getDeviceInfoByID()**
```
ioctl contract test function io1zclqa7w3gxpk47t3y3g9gzujgtl44lastfth28 a.abi getDeviceInfoByID --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373934363132"}' --endpoint api.testnet.iotex.one:443
return: 22346c407294b5e37487395f193faa48dabfc2225ab33fe47b335299f46505b1689f0d96fd53bd19971fe47f310669cf6260dcdc23318454814a4fe904f4d38400000000000000000000000053fbc28faf9a52dfe5f591948a23189e900381b5000000000000000000000000000000000000000000000000000000000000001e00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000010747279706562626c652e696f2f31323300000000000000000000000000000000
```
