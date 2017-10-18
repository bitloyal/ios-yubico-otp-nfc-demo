//
//  NFCReader.m
//  ykiosndefreader
//
//  Created by Deniz Akkaya on 2017-10-18.
//  Copyright © 2017 Deniz Akkaya. All rights reserved.
//

#import "NFCReader.h"
#import <CoreNFC/CoreNFC.h>

@interface NFCReader ()

@end

@implementation NFCReader
@synthesize delegate;
@synthesize session;

// NDEF data configuration constants
#define URI      0x04
#define TEXT     0x05

-(id)init {
    [self initNFCSession]; // Trigger NFC Session
    return self;
}

- (void)dealloc {
    [session release];
    [super dealloc];
}

#pragma mark NFC Methods
- (void)initNFCSession;
{
    self.session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:NULL invalidateAfterFirstRead:true];
    self.session.alertMessage = @"Hold your iPhone near the YubiKey NEO";
}

- (void)startNFCSession;
{
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
                [[self delegate] didReadNFCPayload:NDEF withError:NULL];
                [NDEF release];
                
            }
        }
    }
}

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error {
    NSLog(@"didInvalidateWithError: %@ for session: %@",error,session);
    if (error.code >= NFCReaderSessionInvalidationErrorUserCanceled && error.code < NFCReaderSessionInvalidationErrorFirstNDEFTagRead) {
        [[self delegate] didReadNFCPayload:NULL withError:error];
    }
}

@end

