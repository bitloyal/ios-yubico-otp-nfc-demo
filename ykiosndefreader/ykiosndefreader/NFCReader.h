//
//  NFCReader.h
//  ykiosndefreader
//
//  Created by Deniz Akkaya on 2017-10-18.
//  Copyright © 2017 Deniz Akkaya. All rights reserved.
//

#ifndef NFCReader_h
#define NFCReader_h

#import <UIKit/UIKit.h>
#import <CoreNFC/CoreNFC.h>

@protocol NFCReaderDelegate
@optional
@required
-(void) didReadNFCPayload:(NSString*)payload withError:(NSError*)error;
@end

@interface NFCReader : NSObject <NFCNDEFReaderSessionDelegate>
{
    
}
@property (nonatomic,assign) id <NFCReaderDelegate> delegate;
@property (nonatomic, retain) NFCNDEFReaderSession *session;

- (void)startNFCSession;

@end

#endif /* NFCReader_h */
