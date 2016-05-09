//
//  Verifone.h
//  ReactVerifone
//
//  Created by Manny Parasirakis on 4/28/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "RCTBridgeModule.h"
#import <VMF/VMFramework.h>
#import <VMF/VFIConnect.h>
#import <ExternalAccessory/ExternalAccessory.h>

@interface Verifone : NSObject <RCTBridgeModule,VFIConnectDelegate, VFIBarcodeDelegate, VFIControlDelegate, VFIPinpadDelegate>
@end
