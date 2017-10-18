//
//  NFCReader.m
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
    self.session.alertMessage = @"Hold iPhone near your YubiKey NEO";
}

- (void)startNFCSession;
{
    [self.session beginSession];
    NSLog(@"NFC Session has begun");
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
                
            }else {
                [[self delegate] didReadNFCPayload:@"" withError:NULL];
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

