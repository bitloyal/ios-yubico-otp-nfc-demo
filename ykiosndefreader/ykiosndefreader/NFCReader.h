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

@interface NFCReader : NSObject <NFCNDEFReaderSessionDelegate>
{
    
}

@property (nonatomic, retain) NFCNDEFReaderSession *session;

@end

#endif /* NFCReader_h */
