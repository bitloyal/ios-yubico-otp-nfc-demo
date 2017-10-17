# YubiKey NDEF Reader for iOS

This app reads NFC NDEF payload from [YubiKey NEO](https://www.yubico.com/products/yubikey-hardware/yubikey-neo/). 

### Introduction

Apple opens NFC Framework for developers since iOS11 for iPhone 7, 7 Plus, and 8. This small iOS application can read pre-programmed NDEF payload via NFC reader on iPhone.

To program the NDEF functionality on YubiKey NEO you can follow these steps:

1. Make sure that you configured Configuration Slot 1 or 2 with OTP, Static Password, or OATH-HOTP via [YubiKey Personalization Tool](https://www.yubico.com/support/knowledge-base/categories/articles/yubikey-personalization-tools/). 
2. On YubiKey Personalization Tool, select Tools and then NDEF Programming.
3. Select the configuration slot you want to program for NDEF.
4. Select NDEF type either URI for NDEF payload followed after a URL, or Text for NDEF payload followed after the text you typed into the text box
5. Program and unplug your YubiKey from USB port.
6. Start the application.
7. Hold your YubiKey NEO near to NFC antenna. It is most likely on top of your iPhone at the back side.
8. The application reads the NDEF payload.

### Issues
Please report any issues/feature-suggestions in [the issue tracker on GitHub](https://github.com/Yubico/ykiosndefreader)