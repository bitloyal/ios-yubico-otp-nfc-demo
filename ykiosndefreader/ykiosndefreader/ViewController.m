//
//  ViewController.m
//  ykiosndefreader
//
//  Created by Deniz Akkaya on 2017-10-17.
//  Copyright © 2017 Deniz Akkaya. All rights reserved.
//

#import "ViewController.h"
#import <CoreNFC/CoreNFC.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize session;

// NDEF data configuration constants
#define URI      0x04
#define TEXT     0x05

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startNFCSession]; // Trigger NFC Session
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark NFC Methods
- (void)startNFCSession;
{
    self.session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:NULL invalidateAfterFirstRead:true];
    self.session.alertMessage = @"Hold your iPhone near the YubiKey Neo";
    [self.session beginSession];
    NSLog(@"NFC Session is begin");
}

- (void)readerSessionDidBecomeActive:(NFCReaderSession *)session
{
    NSLog(@"readerSessionDidBecomeActive");
}

- (void) readerSession:(nonnull NFCNDEFReaderSession *)session didDetectNDEFs:(nonnull NSArray<NFCNDEFMessage *> *)messages {
    NSLog(@"didDetectNDEFs");
    for (NFCNDEFMessage *message in messages) {
        for (NFCNDEFPayload *payload in message.records) {
            NSLog(@"Payload: %@",payload);
            NSLog(@"Payload data:%@",payload.payload);
            
            //const unsigned char bytes[] = {TEXT,'e','n','-','U','S'};  // 0x05, 'e', 'n', '-', 'U', 'S' // if NDEF data is configured as text
            const unsigned char bytes[] = {URI};  // 0x04 // if NDEF data is configured as URI
            NSData *prefixPayload = [NSData dataWithBytes:bytes length:sizeof(bytes)];
            
            if ([[payload.payload subdataWithRange:NSMakeRange(0, sizeof(bytes))] isEqualToData:prefixPayload]) {
                
                NSUInteger loc = (NSUInteger) sizeof(unsigned char)*sizeof(bytes);
                NSUInteger len = (NSUInteger)payload.payload.length - (NSUInteger)loc;
                NSString* NDEF = [[NSString alloc] initWithString:
                                  [NSString stringWithUTF8String:[[payload.payload subdataWithRange:NSMakeRange(loc, len)] bytes]] ];
                
                NSLog(@"NDEF: %@", NDEF);
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#if 0
                        // Copy the OTP into clipboard
                        UIPasteboard *pb = [UIPasteboard generalPasteboard];
                        [pb setString:NDEF];
                        NSLog(@"Password copied to clipboard");
#endif
#if 1
                        //Go to my.yubico.com/neo/ to validate the OTP
                        UIApplication *application = [UIApplication sharedApplication];
                    [application openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@",NDEF]] options:@{} completionHandler:nil];
#endif
                    
                });
                
                [NDEF release];
                
            }
        }
    }
}

- (void) readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error {
    [self.session release];
    self.session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:NULL invalidateAfterFirstRead:true];
}

@end
