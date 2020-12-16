This contract implements the registration and pay-to-subscribe flow of the device.

## Compile
```truffle compile```

## Test
```truffle test```

## Testnet

### Deploy
```ioctl contract compile Prophecy --abi-out a.abi --bin-out a.bin```

```ioctl contract deploy bin a.bin --endpoint api.testnet.iotex.one:443```

### Invoke
We use `io199q0c2l48lett4psh5g4kp3tcqrq5383szwfgr` deployed on testnet (via this [action](https://testnet.iotexscan.io/action/fa2ffff0d850d36551af119d08c17b9fd7899cc51e720f31630ec88a58e59211)) as an example to invoke.

**setRegistrationFee()**
```
ioctl contract invoke function io199q0c2l48lett4psh5g4kp3tcqrq5383szwfgr a.abi setRegistrationFee --with-arguments '{"fee":"1"}' --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/1ec24eff9325997e5db149b31882676bbca1f2b8daaf157136dd217c32ffe054
```

**registrationFee()**
```
ioctl contract test function io199q0c2l48lett4psh5g4kp3tcqrq5383szwfgr a.abi registrationFee --endpoint api.testnet.iotex.one:443
return: 1
```

**setSubscriptionFee()**
```
ioctl contract invoke function io199q0c2l48lett4psh5g4kp3tcqrq5383szwfgr a.abi setSubscriptionFee --with-arguments '{"fee":"1"}' --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/b9587a00d06d69f0210469f1ab7627dab0d8e800649b8c6b748a4d2ce9574e85
```

**subscriptionFee()**
```
ioctl contract test function io199q0c2l48lett4psh5g4kp3tcqrq5383szwfgr a.abi subscriptionFee --endpoint api.testnet.iotex.one:443
return: 1
```

**preRegisterDevice()**
Assume deivce id is 352656100794612
```
ioctl contract invoke function io199q0c2l48lett4psh5g4kp3tcqrq5383szwfgr a.abi preRegisterDevice --with-arguments '{"_deviceIdHash":"0x87b94e1b4114ed2746e032605265993b811798401bee23d749a8f3c61f0ae16a"}' --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/8d72d2843a8b36ac644e58c8259f9f7485fa514204d6cf970e954415a273cd5e
```

**registerDevice()**
Assume deivce id is 352656100794612
```
ioctl contract invoke function io199q0c2l48lett4psh5g4kp3tcqrq5383szwfgr a.abi registerDevice --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373834343135","_freq":"30","_price":"1","_spec":"trypebble.io/123","_rsaPubkeyN":"0xB4CB45541BBBE9CF3DC64D33F6E0E3F922472EE09992A47D540A220B11C022C81D9CFEEE16611C422C629E66D81661B3A1A3D8464A57D61DAEDF7CEB85B2132D33355C54D8E1FBA9D751F70BC9FDA355D008BBB94CCBE64F5EA4658EA4907614D77447616FB3D1A903FB8285596446EDF5FF830F2BE657F0DAF4F63E0C2B922C48C5DE828D9A4642D875385FEE431170F60DC6E98ED7FD50FC20CC067A795E10F4B916908DCAA272EA240F1BB82871A2A3F4FFF0D028133F4220E0C829F592D93B2E52F04F4553E36DF9FC6A958959F91361ABD206476063AC1535C427384AACAA2B15873731A7681B29E4D7F2A525DE681E410E156BDBDAB57489DCDD56BD71","_rsaPubkeyE":"0x010001"}' -l 10000000 --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/ffec6719c510bec3bd3e68df4e594bb318fb5a40b875ef653c913707970de32a
```

**updateDevice()**
```
ioctl contract invoke function io199q0c2l48lett4psh5g4kp3tcqrq5383szwfgr a.abi updateDevice --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373834343135","_freq":"30","_price":"1","_spec":"trypebble.io/123","_rsaPubkeyN":"0xB4CB45541BBBE9CF3DC64D33F6E0E3F922472EE09992A47D540A220B11C022C81D9CFEEE16611C422C629E66D81661B3A1A3D8464A57D61DAEDF7CEB85B2132D33355C54D8E1FBA9D751F70BC9FDA355D008BBB94CCBE64F5EA4658EA4907614D77447616FB3D1A903FB8285596446EDF5FF830F2BE657F0DAF4F63E0C2B922C48C5DE828D9A4642D875385FEE431170F60DC6E98ED7FD50FC20CC067A795E10F4B916908DCAA272EA240F1BB82871A2A3F4FFF0D028133F4220E0C829F592D93B2E52F04F4553E36DF9FC6A958959F91361ABD206476063AC1535C427384AACAA2B15873731A7681B29E4D7F2A525DE681E410E156BDBDAB57489DCDD56BD71","_rsaPubkeyE":"0x010001"}' -l 10000000 --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash:iotexscan.io/action/db36a5b8452e35102a34c844b30e13655d5fcde2ed3903967dd6aa8d72879459
```
**getDeviceInfoByID()**
```
ioctl contract test function io199q0c2l48lett4psh5g4kp3tcqrq5383szwfgr a.abi getDeviceInfoByID --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373934363132"}' --endpoint api.testnet.iotex.one:443
return: 22346c407294b5e37487395f193faa48dabfc2225ab33fe47b335299f46505b1689f0d96fd53bd19971fe47f310669cf6260dcdc23318454814a4fe904f4d38400000000000000000000000053fbc28faf9a52dfe5f591948a23189e900381b5000000000000000000000000000000000000000000000000000000000000001e00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000010747279706562626c652e696f2f31323300000000000000000000000000000000
```

**subscribe()**
Assume deivce id is 352656100794612, subscribe for 4 blocks
```
ioctl contract invoke function io199q0c2l48lett4psh5g4kp3tcqrq5383szwfgr a.abi subscribe 10 --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373934363132","_duration":"4","_storageEPoint":"0x890e6f22a4d4f512759a748deb7a7afe435615bf81fc97f9147e2c801c1aa49719cc7c9002c4e034d6e9cae8a1fa528c208a6038c296e0de833211251c5a2e41f4a2247cfd05b7b3a9312b1c76421f47f1526e1763ce04bafa519a860c9e10504cd02c3d20b95fc49bd575f1763f566dcd413cb302e2ef993ea86e3ea07198586e842c9e7ef4beb06341838370ce7e1a840ef93f3530df01e516a16f23ee2ccf0b83f4717334d23c834ff1880fffb316c4c6251ac3ec7b96b9182bc3da340595453464f65249eebe8e99c96d6864acda636981a775daadb7cc09963413631d1f427ccc3019bcf0d5d734189cdfe3fff3d490552de8dddf638cbd5054d6c8f8d3","_storageToken":"0x1042466740803aefbc85963d7f62590eb39d325d5a24238fa96ddefae2e055a8de55237f95fc2a53f297606974da91135050b4f7fe1462e2a04c61d5a3b28e74d17887f5e2a1d15f15b7923b921623a079f4041a38373485f057a83938b457b7c5c896ddfab3931b10bf2af94e19460ae06d7cac2938eb74fda09f379f8fab84f8a66b387338c8500e00217d1c587af24e88c965a9612e57ec5ea4d940108da000d76bf876194e163f3bee56a24c91331bf4c286a412c6e860cb5989ad252f74eb45f60869d1904c5f762fdba2ae8b71a3ce525564ba85512e6133772f7afa3e064d39108ad6d6430cf2bec705a6ed2bd1bf36664dcd5c980a91c13911f45759"}' -l 10000000 --endpoint api.testnet.iotex.one:443
...
Wait for several seconds and query this action by hash: testnet.iotexscan.io/action/f7626ce6784cbbcb80cef065d3bb2a0ba9870d4e735dbe3e202e7a75b19531b5
```

**getDeviceOrderByID()**
```
ioctl contract test function io199q0c2l48lett4psh5g4kp3tcqrq5383szwfgr a.abi getDeviceOrderByID --with-arguments '{"_deviceId":"0x0000000000000000000000000000000000333532363536313030373934363132"}' --endpoint api.testnet.iotex.one:443
return: 00000000000000000000000000000000000000000000000000000000005f77f80000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000013747279706562626c652e696f2f3132333435360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066162636465660000000000000000000000000000000000000000000000000000 
```

## Mainnet

### Deploy
```ioctl contract compile Prophecy --abi-out a.abi --bin-out a.bin```
``` ioctl contract deploy bin a.bin --endpoint api.iotex.one:443```

Contract `io1qhg383xf0sx4aen5zydn820qm66sfwyc9mma8z` has been deployed on mainnet (via this [action](https://iotexscan.io/action/b394aa9d8f742dcc2fb7cf8e3d276728291fbcc5420428b0b79bb09f6ef5b584
))
