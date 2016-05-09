//
//  Vx600.h
//  ReactVerifone
//
//  Created by Manny Parasirakis on 4/29/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import	<Foundation/Foundation.h>
#import	<VMF/VMFramework.h>
#import <VMF/VFIConnect.h>
#import	<ExternalAccessory/ExternalAccessory.h>

@interface Vx600 : NSObject

+ (VFIPinpad *) pinPad;
+ (VFIBarcode *) barcode;
+ (VFIControl *) control;

+ (void) bcScanOn;
+ (void) bcScanOff;
+ (void) bcScanOffWhileSleeping;
+ (void) bcScanOnAfterSleeping;

@end


