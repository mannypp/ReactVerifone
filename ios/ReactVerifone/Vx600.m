//
//  Vx600.m
//  ReactVerifone
//
//  Created by Manny Parasirakis on 4/29/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "Vx600.h"

static BOOL bcEnabled = NO;

@implementation Vx600

+ (VFIPinpad *) pinPad{
  static VFIPinpad *_pinPad = nil;
  if (_pinPad == nil) {
    _pinPad = [[VFIPinpad alloc] init];
  }
  return _pinPad;
}
+ (VFIBarcode *) barcode{
  static VFIBarcode *_barcode = nil;
  if (_barcode == nil) {
    _barcode = [[VFIBarcode alloc] init];
  }
  return _barcode;
}
+ (VFIControl *) control{
  static VFIControl *_control = nil;
  if (_control == nil) {
    _control = [[VFIControl alloc] init];
  }
  return _control;
}

+ (void) bcScanOn {
  VFIBarcode *barcode = [self barcode];
  [barcode startScan];
  bcEnabled = TRUE;
}

+ (void) bcScanOff {
  VFIBarcode *barcode = [self barcode];
  [barcode abortScan];
  bcEnabled = FALSE;
}

+ (void) targetMethod :(NSTimer *) mytimer  {
  VFIBarcode *barcode = [Vx600 barcode];
  @synchronized(self) {
    NSLog(@"ScanOnAfterSleep-%d/%d", (barcode.connected)?1:0, (barcode.initialized)?1:0);
    if ((barcode.initialized)) {
      [barcode startScan];
    }
  }
}

+ (void) bcScanOnAfterSleeping {
  [NSTimer scheduledTimerWithTimeInterval:0.250 target:self selector:@selector(targetMethod:)
                                 userInfo:nil repeats:NO];
}

+ (void) bcScanOffWhileSleeping {
  VFIBarcode *barcode = [self barcode];
  if (bcEnabled == TRUE) {
    [barcode abortScan];
  }
}

@end
