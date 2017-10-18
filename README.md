# YubiKey NDEF Reader for iOS

This demo app reads a Yubico OTP from a [YubiKey NEO](https://www.yubico.com/products/yubikey-hardware/yubikey-neo/) over NFC.

### Introduction

The CoreNFC API can be used to read a Yubico OTP over NFC starting with iOS 11 for iPhone 7, 7 Plus, and 8.
This proof of concept demo app reads an OTP from a YubiKey NEO and displays it to the user.
It then allows the user to copy the OTP to the clipboard, or to validate it against the YubiCloud service.

### Requirements

You will need this app installed on a supported iPhone, as well as a YubiKey NEO with the default Yubico OTP and NDEF configurations set.

### Instructions

1. Install the app, and launch it
2. When prompted to do so, hold your YubiKey NEO against the back of your iPhone, near the top edge.
3. Once the prompt disappears, you can remove the YubiKey.

### Issues
Please report any issues/feature-suggestions in [the issue tracker on GitHub](https://github.com/Yubico/ios-yubico-otp-nfc-demo)
