//
//  ViewController.h
//  ykiosndefreader
//
//  Created by Deniz Akkaya on 2017-10-17.
//  Copyright © 2017 Deniz Akkaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "NFCReader.h"

@interface ViewController : UIViewController <NFCReaderDelegate>
{
    // NFC Reader Class
    NFCReader* reader;
    
    // ViewController UI Objects
    IBOutlet UILabel *labelStatus;
    IBOutlet UIButton* buttonCopyOTP;
    IBOutlet UIButton* buttonValidateOTP;
    IBOutlet UIButton* buttonReread;
    
}

@end

