//
//  ViewController.m
//  ykiosndefreader
//
// Copyright (c) 2017 Yubico AB
// All rights reserved.
//
//   Redistribution and use in source and binary forms, with or
//   without modification, are permitted provided that the following
//   conditions are met:
//
//    1. Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//    2. Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.


#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setVisibleUIObjects:false];
    
    if ([NFCNDEFReaderSession readingAvailable]) {
        reader = [[NFCReader alloc] init];
        reader.delegate = self;
        [reader startNFCSession];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (![NFCNDEFReaderSession readingAvailable]) {
        // iOS Device does not support NFC Reader
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"OTP Reader"
                                                                      message:@"This iOS Device does not support NFC Reader."
                                                               preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        exit(0);
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [labelStatus release];
    [super dealloc];
}

#pragma UI Functionalities
- (void)setVisibleUIObjects:(bool)isVisible {
    dispatch_async(dispatch_get_main_queue(), ^{
        [labelStatus setText:@""];
        [labelStatus setHidden:!isVisible];
        [buttonCopyOTP setHidden:!isVisible];
        [buttonValidateOTP setHidden:!isVisible];
        [buttonReread setHidden:!isVisible];
    });
}

-(IBAction) onClickButtonCopyOTP: (id) sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Copy the OTP into clipboard
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        NSString* prefix = @"OTP: ";
        NSString* otp = [labelStatus.text substringFromIndex:prefix.length];
        [pb setString:otp];
        
        NSLog(@"OTP copied to clipboard");
    });
}

-(IBAction) onClickButtonValidateOTP: (id) sender {
    //Go to my.yubico.com/neo/ to validate the OTP
    UIApplication *application = [UIApplication sharedApplication];
    NSString* prefix = [[NSString alloc] initWithString:@"OTP: "];
    NSString* otp = [[NSString alloc] initWithString:[labelStatus.text substringFromIndex:prefix.length]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [application openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://my.yubico.com/neo/%@",otp]] options:@{} completionHandler:nil];
    });
    [prefix release];
    [otp release];
    
}

-(IBAction) onClickButtonReread: (id) sender {
    if (reader)
    {
        [reader dealloc];
    }
    
    reader = [[NFCReader alloc] init];
    reader.delegate = self;
    [reader startNFCSession];
    [self setVisibleUIObjects:false];
}

#pragma NFC Reader Functionalities
-(void) didReadNFCPayload:(NSString*)payload withError:(NSError*)error
{
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [labelStatus setText:@""];
            [labelStatus setHidden:true];
            [buttonCopyOTP setHidden:true];
            [buttonValidateOTP setHidden:true];
            [buttonReread setHidden:false];
            
            reader = [[NFCReader alloc] init];
            reader.delegate = self;
        });
        return;
    }
    
    if ([payload isEqualToString:@""])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [labelStatus setText:@"Invalid OTP format"];
            labelStatus.textAlignment = NSTextAlignmentCenter;
            [labelStatus setHidden:false];
            [buttonCopyOTP setHidden:true];
            [buttonValidateOTP setHidden:true];
            [buttonReread setHidden:false];
        });
        
    }else {
        [self setVisibleUIObjects:true];
        
        // Set the labelStatus
        // Prefix for URI: https://my.yubico.com/neo/
        NSString* uri = [[NSString alloc] initWithString:@"my.yubico.com/neo/"];
        NSString* otp = [[NSString alloc] initWithString:[payload substringFromIndex:uri.length]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            labelStatus.textAlignment = NSTextAlignmentLeft;
            [labelStatus setText:[NSString stringWithFormat:@"OTP: %@",otp]];
        });
        [uri release];
        [otp release];
    }
    
}

@end
