//
//  ViewController.m
//  ykiosndefreader
//
//  Created by Deniz Akkaya on 2017-10-17.
//  Copyright © 2017 Deniz Akkaya. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setVisibleUIObjects:false];
    
    reader = [[NFCReader alloc] init];
    reader.delegate = self;
    
    [reader startNFCSession];
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
        
        NSLog(@"Password copied to clipboard");
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
    [reader startNFCSession];
    [self setVisibleUIObjects:false];
}

#pragma NFC Reader Functionalities
-(void) didReadNFCPayload:(NSString*)payload withError:(NSError*)error
{
    [self setVisibleUIObjects:true];
    
    // Set the labelStatus
    // Prefix for URI: https://my.yubico.com/neo/
    NSString* uri = [[NSString alloc] initWithString:@"my.yubico.com/neo/"];
    NSString* otp = [[NSString alloc] initWithString:[payload substringFromIndex:uri.length]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [labelStatus setText:[NSString stringWithFormat:@"OTP: %@",otp]];
    });
    [uri release];
    [otp release];
}

@end
