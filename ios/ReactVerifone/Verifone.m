//
//  Verifone.m
//  ReactVerifone
//
//  Created by Manny Parasirakis on 4/28/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Verifone.h"
#import "RCTLog.h"
#import "RCTConvert.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"

#import "Vx600.h"

static BOOL ppadInit = NO;
static BOOL ctrlInit = NO;
static BOOL bcodInit = NO;

static BOOL sendCancellationEvent = YES;


@implementation Verifone

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (void) accessoryDataReceived: (AccMessage)message data: (VFI_swipeData*)card
{
  if (message == AccMessage_SledDisconnected) {
    NSLog(@"Sled disconnected, cleaning up device connections");
    //VFIAccessoryMgr* accessoryMgr = [VFIAccessoryMgr sharedController];
    //[accessoryMgr closeDevices];
    [[Vx600 barcode] closeDevice];
    [[Vx600 pinPad] closeDevice];
    [[Vx600 control] closeDevice];
    ppadInit = NO;
    ctrlInit = NO;
    bcodInit = NO;
  }
  else if (message == AccMessage_SledConnected) {
    NSLog(@"Sled connected, calling setup()");
    [self setup:nil];
#ifdef DEBUG
    [[Vx600 pinPad] displayMessages:@"Payment Device" Line2:@"Reconnected" Line3:@"" Line4:@""];
#endif
  }
}

RCT_EXPORT_METHOD(setup:(id)args)
{
  NSLog(@"setup() called");
  
  [self controlInit];
  [self barcodeInit];
  [self pinpadInit];
}

-(void) controlInit {
  //    if (!ctrlInit) {
  VFIControl* control = [Vx600 control];
  [control setDelegate:self];
  [control initDevice];
  //    }
}

-(void) barcodeInit {
  //    if (!bcodInit) {
  VFIBarcode* barcode = [Vx600 barcode];
  [barcode setDelegate:self];
  [barcode initDevice];
  //    }
}

-(void) pinpadInit {
  //    if (!ppadInit) {
  VFIPinpad* pinpad = [Vx600 pinPad];
  [pinpad setDelegate:self];
  [pinpad initDevice];
  //    }
}

-(void) pinPadInitialized:(BOOL)isInitialized{
  NSLog(@"pinPadInitialized");
  VFIPinpad* pinpad = [Vx600 pinPad];
  
  if (isInitialized) {
    [pinpad disableMSR];
    [pinpad selectEncryptionMode:EncryptionMode_VSP];
    
    [pinpad setFrameworkTimeout:120]; // ENTER PIN timeout old way.
    [pinpad setPINTimeout:70]; // ENTER PIN timeout
    [pinpad setAccountEntryTimeout:120];
    [pinpad setPromptTimeout:70];
    [pinpad setACKTimeout:3.0];
    [pinpad setKSN20Char:FALSE];
    [pinpad logEnabled: YES];
    // Use a custom prompt for the C30 command...
    //[pinpad waitForResponse:YES];
    //[pinpad sendStringCommand:[NSString stringWithFormat:@"D30%c1%c0%c0Tap or Swipe%c0Card%c0", 0x1C, 0x1c, 0x1c,0x1c, 0x1c] calcLRC:YES];
    
    [pinpad enableBlocking];
    
    ppadInit = YES;
    [self fireEvent:@"pinPadReady" body:nil];
    
#ifdef DEBUG
    [pinpad displayMessages:ppadInit ? @"Pinpad Inited" : @"" Line2:ctrlInit ? @"Control Inited" : @""
                      Line3:bcodInit ? @"Barcode Inited" : @"" Line4:@""];
#endif
  }
  else {
#ifdef DEBUG
    [pinpad displayMessages:@"Pinpad Not" Line2:@"Initialized" Line3:@"" Line4:@""];
#endif
  }
}

-(void) controlInitialized:(BOOL)isInitialized{
  NSLog(@"controlInitialized");
  if (isInitialized) {
    VFIControl* control = [Vx600 control];
    
    [control keypadBeepEnabled:YES] ;
    [control keypadEnabled:NO];
    [control hostPowerEnabled:YES];
    
    [control enableBlocking];
    [control logEnabled:YES];
    
    ctrlInit = YES;
    [self fireEvent:@"controlReady" body:nil];
    
#ifdef DEBUG
    [[Vx600 pinPad] displayMessages:ppadInit ? @"Pinpad Inited" : @"" Line2:ctrlInit ? @"Control Inited" : @""
                              Line3:bcodInit ? @"Barcode Inited" : @"" Line4:@""];
#endif
  }
  else {
#ifdef DEBUG
    VFIPinpad* pinpad = [Vx600 pinPad];
    [pinpad displayMessages:@"Control Not" Line2:@"Initialized" Line3:@"" Line4:@""];
#endif
  }
}

-(void) barcodeInitialized:(BOOL)isInitialized{
  NSLog(@"barcodeInitialized");
  if (isInitialized) {
    VFIBarcode* barcode = [Vx600 barcode];
    
    NSLog(@"setting up barcode stuff");
    [barcode setScanner2D];
    [barcode setScanTimeout:5000];
    [barcode includeAllBarcodeTypes];
    [barcode barcodeTypeEnabled:TRUE];
    
    [barcode enableBlocking];
    [barcode logEnabled:YES];
    
    bcodInit = YES;
    [self fireEvent:@"barcodeReady" body:nil];
    
#ifdef DEBUG
    [[Vx600 pinPad] displayMessages:ppadInit ? @"Pinpad Inited" : @"" Line2:ctrlInit ? @"Control Inited" : @""
                              Line3:bcodInit ? @"Barcode Inited" : @"" Line4:@""];
#endif
  }
  else {
#ifdef DEBUG
    VFIPinpad* pinpad = [Vx600 pinPad];
    [pinpad displayMessages:@"Barcode Not" Line2:@"Initialized" Line3:@"" Line4:@""];
#endif
  }
}

-(void) sendBarcodeScanEvent:(NSData*)data type:(int)thetype
{
  NSString* barcode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
  NSLog([NSString stringWithFormat:@"Barcode Scanned: %@",barcode]);
  
  NSMutableDictionary* md = [NSMutableDictionary dictionary];
  [md setValue:barcode forKey:@"barcode"];
  [md setValue:[NSNumber numberWithInt:thetype] forKey:@"type"];
    
  [self fireEvent:@"barcodeDataWithType" body:md];
}

- (void) barcodeScanData:(NSData*)data code:(int)code symbol:(int)symbol aim:(int)aim
{
  NSLog(@"barcodeScanData:code: %d symbol: %d aim: %d", code, symbol, aim);
  [self sendBarcodeScanEvent:data type:code];
}

- (void) barcodeScanData: (NSData *)data barcodeType:(int)thetype {
  if ([[Vx600 control] isGen3]) {
    return; // the newer gen3 delegate above will handle the call
  }
  
  NSLog(@"barcodeScanData:barcodeType: %d", thetype);
  [self sendBarcodeScanEvent:data type:thetype];
}

RCT_EXPORT_METHOD(scannerOn:(id)args)
{
  NSLog(@"scannerOn");
  BOOL vmfGen3Flag = [Vx600 barcode].isGen3;
  
  if (vmfGen3Flag == true) {
    VFIBarcode* barcode = [Vx600 barcode];
    [barcode mTriggerMode:1];
    [barcode mStartScan];
    [barcode setBeepOn];
  } else {
    [Vx600 bcScanOnAfterSleeping];
  }
}

-(T_BEEP_DEF) getBeepDef
{
  T_BEEP_DEF b;
  T_BEEP b1;
  T_BEEP b2;
  
  b1.freq = 0x40;
  b1.dur = 0x30;
  
  b2.freq = 0x45;
  b2.dur = 0x30;
  
  b.b1 = b1;
  b.b2 = b2;
  b.bPause = 0x50;
  
  return b;
}

-(void)fireEvent:(NSString*)name body:(id)object
{
  [self.bridge.eventDispatcher sendAppEventWithName:@"logEvent" body:object];
  //[self.bridge.eventDispatcher sendAppEventWithName:name body:object];
}

RCT_EXPORT_METHOD(cancelPayment:(NSDictionary*)args)
{
  NSNumber *sendEvent = nil;
  if (args != nil) {
    sendEvent = [args objectForKey:@"sendEvent"];
  }
  
  if( !ppadInit ) return;
  
  NSLog(@"cancelPayment: %@", args);
  sendCancellationEvent = (sendEvent == nil ? YES : [sendEvent boolValue]);
  [[Vx600 pinPad] cancelCommand]; // Will cancel payment
}

RCT_EXPORT_METHOD(_acceptPayment:(id)args)
{
  NSDictionary *options = [args objectForKey:@"options"];
  
  VFIPinpad* pinpad = [Vx600 pinPad];
  if (![pinpad initialized] && ![pinpad pinpadConnected]) {
    NSLog(@"_acceptPayment: The connection to the payment terminal could not be established. Aborting payment transaction.");
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    [md setObject:@"The connection to the payment terminal could not be established." forKey:@"device_error"];
    [self fireEvent:@"payment:error" body:md];
    return;
  }
  
  if( options && [options objectForKey:@"manual"] ) {
    NSLog(@"obtainCardData: %@", args);
    if( !ppadInit || !ctrlInit ) return;
    [self obtainCardData:args];
    //[self performSelectorOnMainThread:@selector(obtainCardData:) withObject:args waitUntilDone:NO];
    
  } else if( options && [options objectForKey:@"solicited"] && [options objectForKey:@"use_alternate_card_entry"]) {
    NSLog(@"obtainTrack2Data: %@", args);
    if( !ppadInit ) return;
    [self obtainTrack2Data:args];
    //[self performSelectorOnMainThread:@selector(obtainTrack2Data:) withObject:args waitUntilDone:NO];
    
  } else if( options && [options objectForKey:@"solicited"] ) {
    NSLog(@"getCardData: %@", args);
    if( !ppadInit ) return;
    [self getCardData:args];
    //[self performSelectorOnMainThread:@selector(getCardData:) withObject:args waitUntilDone:NO];
  }
  // all other cases ... we use unsolicited swipe for verifone
}

-(void) getCardData:(id)args
{
  VFIPinpad* pinpad = [Vx600 pinPad];
  VFIControl* control = [Vx600 control];
  NSNumber *amount = [args objectForKey:@"amount"];
  NSNumber *language = [args objectForKey:@"language"];
  NSNumber *timeout = [args objectForKey:@"timeout"];
  float	amt  = amount ? [amount floatValue] : 1.0f;
  int     lng  = language ? [language intValue] : 0;
  int		time = timeout ? [timeout intValue] : 120;
  NSMutableDictionary* md = nil;
  
  NSLog(@"amount: %f, language: %d, timeout: %d", amt, lng, time);
  
  [pinpad setC30CustomPrompts:@"Swipe Card," line2:@"Insert Card, or" line3:@"Tap Device" line4:@"" amt1:NO amt2:NO amt3:NO amt4:YES];
  
  NSLog(@"Enabling key pad");
  [control keypadBeepEnabled:YES];
  [control keypadEnabled:YES];
  
  int rc = [pinpad getCardData:time language:lng amount:amt otherAmount:0.0f];
#ifdef DEBUG
  [[Vx600 pinPad] displayMessages:@"" Line2:@"Returned to" Line3:@"DSS library" Line4:[NSString stringWithFormat:@"%d", rc]];
#endif
  NSLog(@"return code: %d", rc);
  
  NSLog(@"Disabling key pad");
  [control keypadEnabled:NO];
  [control keypadBeepEnabled:NO];
  
  VFICardData* vfiCardData = pinpad.vfiCardData;
  NSString* track1 = [[NSString alloc] initWithData: vfiCardData.track1 encoding:NSUTF8StringEncoding];
  NSString* track2 = [[NSString alloc] initWithData: vfiCardData.track2 encoding:NSUTF8StringEncoding];
  NSString *accountNumber = vfiCardData.accountNumber;
  NSString *expiry = vfiCardData.expiryDate;
  NSString *contactless = vfiCardData.entryType == 7 ? @"true" : @"false";
  
  NSLog(@"PAN: %@\nExpiryDate: %@\nTrack1: %@\nTrack2: %@\nContactless: %@",accountNumber,expiry,track1,track2,contactless);
  
  if (vfiCardData.entryType == 0 && rc != 6 && rc != 8) { // in case this didn't get cancelled until after we captured manual entry and we did not time out
    return;
  }
  
  if( rc==0 || rc==21 ) {
    if (vfiCardData.entryType == 0) {
      [pinpad displayMessages:@"Manual Card" Line2:@"Entry" Line3:@"Successful" Line4:@""];
    }
    else if (vfiCardData.entryType == 2) {
      [pinpad displayMessages:@"Card" Line2:@"Successfully" Line3:@"Read" Line4:@""];
      [[Vx600 barcode] sendBeep:[self getBeepDef]];
    }
    else if (vfiCardData.entryType == 7) {
      [pinpad displayMessages:@"Read data from" Line2:@"Device" Line3:@"Successfully" Line4:@""];
    }
  } else {
    NSString* message = nil;
    switch (rc) {
      case -1:
        // command was cancelled
        return;
      case 1:
        message = @"Invalid Command Code";
        [pinpad displayMessages:@"" Line2:@"Invalid" Line3:@"Command Code" Line4:@""];
        break;
      case 2:
        message = @"Invalid Data Format";
        [pinpad displayMessages:@"" Line2:@"Invalid" Line3:@"Data Format" Line4:@""];
        break;
      case 3:
        message = @"Response has More Packs";
        [pinpad displayMessages:@"" Line2:@"Response has" Line3:@"More Packs" Line4:@""];
        break;
      case 4:
        message = @"Previous Step Missing";
        [pinpad displayMessages:@"" Line2:@"Previous Step" Line3:@"Missing" Line4:@""];
        break;
      case 5:
        message = @"Invalid Configuration";
        [pinpad displayMessages:@"" Line2:@"Invalid" Line3:@"Configuration" Line4:@""];
        break;
      case 6:
        md = [NSMutableDictionary dictionary];
        [md setObject:[NSNumber numberWithInt:rc] forKey:@"errorCode"];
        [self fireEvent:@"magneticCardTimeout" body:md];
        //message = @"Timed Out";
        //[pinpad displayMessages:@"" Line2:@"Timed Out" Line3:@"" Line4:@""];
        return;
      case 7:
        message = @"Timer Error";
        [pinpad displayMessages:@"" Line2:@"Timer Error" Line3:@"" Line4:@""];
        break;
      case 8:
        md = [NSMutableDictionary dictionary];
        [md setObject:[NSNumber numberWithInt:rc] forKey:@"errorCode"];
        if (sendCancellationEvent) {
          [self fireEvent:@"magneticCardCancelled" body:md];
        }
        else {
          sendCancellationEvent = YES;
        }
        //message = @"Operation Cancelled";
        //[pinpad displayMessages:@"" Line2:@"Operation" Line3:@"Cancelled" Line4:@""];
        return;
      case 9:
        message = @"Communication Error";
        [pinpad displayMessages:@"" Line2:@"Communication" Line3:@"Error" Line4:@""];
        break;
      case 10:
        message = @"Chip Reader Failure";
        [pinpad displayMessages:@"" Line2:@"Chip Reader" Line3:@"Failure" Line4:@""];
        break;
      case 22:
        message = @"Chip Error";
        [pinpad displayMessages:@"" Line2:@"Chip Error" Line3:@"" Line4:@""];
        break;
      case 23:
        message = @"Card Removed";
        [pinpad displayMessages:@"" Line2:@"Card Removed" Line3:@"" Line4:@""];
        break;
      case 24:
        message = @"Card Blocked";
        [pinpad displayMessages:@"" Line2:@"Card Blocked" Line3:@"" Line4:@""];
        break;
      case 25:
        message = @"Card Not Supported";
        [pinpad displayMessages:@"" Line2:@"Card Not" Line3:@"Supported" Line4:@""];
        break;
      case 42:
        message = @"Candidate List Empty";
        [pinpad displayMessages:@"" Line2:@"Candidate" Line3:@"List Empty" Line4:@""];
        break;
      case 88:
        message = @"No Encryption Module Activated";
        [pinpad displayMessages:@"" Line2:@"No Encryption" Line3:@"Module Activated" Line4:@""];
        break;
      default:
        message = [NSString stringWithFormat:@"Unknown Error Code: %d", rc];
        [pinpad displayMessages:@"" Line2:@"Unknown Error" Line3:@"Code:" Line4:[NSString stringWithFormat:@"%d", rc]];
        break;
    }
    
    NSLog(@"Error %d while getting card data.", rc);
    
    md = [NSMutableDictionary dictionary];
    if (message) {
      [md setObject:message forKey:@"message"];
    }
    [md setObject:[NSNumber numberWithInt:rc] forKey:@"errorCode"];
    
    [self fireEvent:@"magneticCardError" body:md];
    
    return;
  }
  
  if ([track1 isEqualToString:@""] && [track2 isEqualToString:@""]) {
    NSMutableDictionary* md = [NSMutableDictionary dictionary];
    
    if ([contactless isEqualToString:@"true"]) {
      NSLog(@"Could not get contactless (NFC) payment data.");
      [md setObject:@"Error getting NFC payment data" forKey:@"message"];
    }
    else {
      NSLog(@"Could not get barcode/chip (MSR/EMV) payment data.");
      [md setObject:@"Error getting barcode/chip payment data" forKey:@"message"];
    }
    
    [self fireEvent:@"magneticCardError" body:md];
    
    return;
  }
  
  md = [NSMutableDictionary dictionary];
  NSString *month = [expiry substringFromIndex:2];
  NSString *year = [expiry substringToIndex:2];
  if( [pinpad getEncryptionMode]==EncryptionMode_VSP ) {
    [md setValue:accountNumber forKey:@"pan"];
    [md setValue:track1 forKey:@"track1"];
    [md setValue:track2 forKey:@"track2"];
  } else {
    [md setValue:@"TURN_ON_VSP" forKey:@"pan"];
    [md setValue:@"TURN_ON_VSP" forKey:@"track1"];
    [md setValue:@"TURN_ON_VSP" forKey:@"track2"];
  }
  [md setValue:month forKey:@"month"];
  [md setValue:year forKey:@"year"];
  [md setValue:contactless forKey:@"contactless"];
  [md setValue:pinpad.pinpadSerialNumber forKey:@"terminal_id"];
    
#ifdef DEBUG
  [pinpad displayMessages:@"Before fire" Line2:@"event in" Line3:@"getCardData:" Line4:[NSString stringWithFormat:@"%d", rc]];
#endif
  [self fireEvent:@"magneticCardData" body:md];
  
#ifdef DEBUG
  [pinpad displayMessages:@"" Line2:@"Finished" Line3:@"getCardData:" Line4:[NSString stringWithFormat:@"%d", rc]];
#endif
}

-(void) obtainTrack2Data:(id)args
{
  VFIPinpad* pinpad = [Vx600 pinPad];
  //VFIControl* control = [Vx600 control];
  NSNumber *amount = [args objectForKey:@"amount"];
  NSNumber *timeout = [args objectForKey:@"timeout"];
  float	amt  = amount ? [amount floatValue] : 1.0f;
  int		time = timeout ? [timeout intValue] : 120;
  NSMutableDictionary* md = nil;
  
  NSLog(@"amount: %f, timeout: %d", amt, time);
  
  NSLog(@"Enabling key pad");
  //[control keypadBeepEnabled:YES];
  //[control keypadEnabled:YES];
  
  int rc = [pinpad obtainTrack2Data:time optionalAmount:amt];
#ifdef DEBUG
  [[Vx600 pinPad] displayMessages:@"" Line2:@"Returned to" Line3:@"DSS library" Line4:[NSString stringWithFormat:@"%d", rc]];
#endif
  NSLog(@"return code: %d", rc);
  
  NSLog(@"Disabling key pad");
  //[control keypadEnabled:NO];
  //[control keypadBeepEnabled:NO];
  
  VFICardData* vfiCardData = pinpad.vfiCardData;
  
  if (rc == 0 && vfiCardData.entryType == 0
      && vfiCardData.track1 == nil && vfiCardData.track2 == nil) // operation was cancelled
  {
    return;
  }
  
  NSString* track1 = [[NSString alloc] initWithData: vfiCardData.track1 encoding:NSUTF8StringEncoding];
  NSString* track2 = [[NSString alloc] initWithData: vfiCardData.track2 encoding:NSUTF8StringEncoding];
  NSString *accountNumber = vfiCardData.accountNumber;
  NSString *expiry = vfiCardData.expiryDate;
  NSString *contactless = vfiCardData.entryType == 7 ? @"true" : @"false";
  
  NSLog(@"PAN: %@\nExpiryDate: %@\nTrack1: %@\nTrack2: %@\nContactless: %@",accountNumber,expiry,track1,track2,contactless);
  
  if( rc==0 ) {
    if (vfiCardData.entryType == 0) {
      if (vfiCardData.isCTLS) {
        [pinpad displayMessages:@"Read data from" Line2:@"Device" Line3:@"Successfully" Line4:@""];
      }
      else {
        [pinpad displayMessages:@"Card" Line2:@"Successfully" Line3:@"Read" Line4:@""];
        [[Vx600 barcode] sendBeep:[self getBeepDef]];
      }
    }
  } else {
    NSString* message = nil;
    switch (rc) {
      case 1:
        message = @"Command Was Unsuccessful";
        [pinpad displayMessages:@"" Line2:@"Command Was" Line3:@"Unsuccessful" Line4:@""];
        break;
      case 2:
        md = [NSMutableDictionary dictionary];
        [md setObject:[NSNumber numberWithInt:rc] forKey:@"errorCode"];
        [self fireEvent:@"magneticCardTimeout" body:md];
        //message = @"Timed Out";
        //[pinpad displayMessages:@"" Line2:@"Timed Out" Line3:@"" Line4:@""];
        return;
      case 3:
        md = [NSMutableDictionary dictionary];
        [md setObject:[NSNumber numberWithInt:rc] forKey:@"errorCode"];
        if (sendCancellationEvent) {
          [self fireEvent:@"magneticCardCancelled" body:md];
        }
        else {
          sendCancellationEvent = YES;
        }
        //message = @"Operation Cancelled";
        //[pinpad displayMessages:@"" Line2:@"Operation" Line3:@"Cancelled" Line4:@""];
        return;
      case 88:
        message = @"No Encryption Module Activated";
        [pinpad displayMessages:@"" Line2:@"No Encryption" Line3:@"Module Activated" Line4:@""];
        break;
      default:
        message = [NSString stringWithFormat:@"Unknown Error Code: %d", rc];
        [pinpad displayMessages:@"" Line2:@"Unknown Error" Line3:@"Code:" Line4:[NSString stringWithFormat:@"%d", rc]];
        break;
    }
    
    NSLog(@"Error %d while obtaining track 2 data.", rc);
    
    md = [NSMutableDictionary dictionary];
    if (message) {
      [md setObject:message forKey:@"message"];
    }
    [md setObject:[NSNumber numberWithInt:rc] forKey:@"errorCode"];
    
    [self fireEvent:@"magneticCardError" body:md];
    
    return;
  }
  
  if (vfiCardData.track1 == nil && vfiCardData.track2 == nil) {
#ifdef DEBUG
    [pinpad displayMessages:@"Track1 and" Line2:@"track2 are nil" Line3:@"Return code:" Line4:[NSString stringWithFormat:@"%d", rc]];
#endif
    NSMutableDictionary* md = [NSMutableDictionary dictionary];
    
    if ([contactless isEqualToString:@"true"]) {
      NSLog(@"Could not get contactless (NFC) payment data.");
      [md setObject:@"Error getting NFC payment data" forKey:@"message"];
    }
    else {
      NSLog(@"Could not get barcode/chip (MSR/EMV) payment data.");
      [md setObject:@"Error getting barcode/chip payment data" forKey:@"message"];
    }
    
    [self fireEvent:@"magneticCardError" body:md];
    
    return;
  }
  
  md = [NSMutableDictionary dictionary];
  NSString *month = [expiry substringFromIndex:2];
  NSString *year = [expiry substringToIndex:2];
  if( [pinpad getEncryptionMode]==EncryptionMode_VSP ) {
    [md setValue:accountNumber forKey:@"pan"];
    [md setValue:track1 forKey:@"track1"];
    [md setValue:track2 forKey:@"track2"];
  } else {
    [md setValue:@"TURN_ON_VSP" forKey:@"pan"];
    [md setValue:@"TURN_ON_VSP" forKey:@"track1"];
    [md setValue:@"TURN_ON_VSP" forKey:@"track2"];
  }
  [md setValue:month forKey:@"month"];
  [md setValue:year forKey:@"year"];
  [md setValue:contactless forKey:@"contactless"];
  [md setValue:pinpad.pinpadSerialNumber forKey:@"terminal_id"];
    
#ifdef DEBUG
  [pinpad displayMessages:@"Before fire" Line2:@"event in" Line3:@"obtainTrack2Data:" Line4:[NSString stringWithFormat:@"%d", rc]];
#endif
  [self fireEvent:@"magneticCardData" body:md];
  
#ifdef DEBUG
  [pinpad displayMessages:@"" Line2:@"Finished" Line3:@"obtainTrack2Data:" Line4:[NSString stringWithFormat:@"%d", rc]];
#endif
}

-(void) obtainCardData:(id)args
{
  VFIControl* control = [Vx600 control];
  VFIPinpad* pinpad = [Vx600 pinPad];
  NSMutableDictionary* md = nil;
  
  NSLog(@"Enabling key pad");
  [control keypadBeepEnabled:YES];
  [control keypadEnabled:YES];
  
  NSLog(@"Displaying Manual PAN prompt");
  
  [self fireEvent:@"manualCardDataOn" body:nil];
  int rc = [pinpad obtainCardData:0];
  NSLog(@"return code: %d", rc);
  
  NSLog(@"Disabling key pad");
  [control keypadEnabled:NO];
  [control keypadBeepEnabled:NO];
  
  VFICardData* vfiCardData = pinpad.vfiCardData;
  NSString* track1 = [[NSString alloc] initWithData:vfiCardData.track1 encoding:NSUTF8StringEncoding];
  NSString* track2 = [[NSString alloc] initWithData:vfiCardData.track2 encoding:NSUTF8StringEncoding];
  NSString* accountNumber = vfiCardData.accountNumber;
  NSString* expiry = vfiCardData.expiryDate;
  NSString* month = [expiry substringFromIndex:2];
  NSString* year = [expiry substringToIndex:2];
  NSString* contactless = vfiCardData.entryType == 7 ? @"true" : @"false";
  
  NSLog([NSString stringWithFormat:@"Expiry: %@\nMonth: %@\nYear: %@\n", expiry, month, year]);
  NSLog([NSString stringWithFormat:@"EntryType: %d", vfiCardData.entryType]);
  
  if ((rc != 3 && (vfiCardData.track1 == nil && accountNumber == nil)) // if the user hit cancel, then track1 and accountNumber will be empty/nil
      || vfiCardData.entryType != 0) { // if not manual entry, then ignore (probably won't ever happen here)
    [self fireEvent:@"manualCardDataOff" body:nil];
    return;
  }
  
  if (rc != 0) {
    NSString* message = nil;
    switch (rc) {
      case -1:
        // command was cancelled
        return;
      case 1:
        message = @"Unsuccessful";
        [pinpad displayMessages:@"" Line2:@"Unsuccessful" Line3:@"" Line4:@""];
        break;
      case 2:
        //message = @"Timed Out";
        //[pinpad displayMessages:@"" Line2:@"Timed Out" Line3:@"" Line4:@""];
        break;
      case 3:
        md = [NSMutableDictionary dictionary];
        [md setObject:[NSNumber numberWithInt:rc] forKey:@"errorCode"];
        if (sendCancellationEvent) {
          [self fireEvent:@"magneticCardCancelled" body:md];
        }
        else {
          sendCancellationEvent = YES;
        }
        //message = @"Cancel Key Was Pressed";
        //[pinpad displayMessages:@"" Line2:@"Cancel Key" Line3:@"Was Pressed" Line4:@""];
        return;
      case 4:
        message = @"Corr Key Was Pressed";
        [pinpad displayMessages:@"" Line2:@"Corr Key" Line3:@"Was Pressed" Line4:@""];
        break;
      case 88:
        message = @"No Encryption Module Activated";
        [pinpad displayMessages:@"" Line2:@"No Encryption" Line3:@"Module" Line4:@"Activated"];
        break;
        
      default:
        message = [NSString stringWithFormat:@"Unknown Error Code: %d", rc];
        [pinpad displayMessages:@"" Line2:@"Unknown Error" Line3:@"Code:" Line4:[NSString stringWithFormat:@"%d", rc]];
        break;
    }
    
    NSLog(@"Error %d while obtaining card data.", rc);
    
    md = [NSMutableDictionary dictionary];
    if (message) {
      [md setObject:message forKey:@"message"];
    }
    [md setObject:[NSNumber numberWithInt:rc] forKey:@"errorCode"];
    
    [self fireEvent:@"magneticCardError" body:md];
    
    return;
  }
  
  if ([track1 isEqualToString:@""] && vfiCardData.entryType != 0) { // 0 is manual entry, 2 is swipe, 7 is NFC
    NSMutableDictionary* md = [NSMutableDictionary dictionary];
    
    if ([contactless isEqualToString:@"true"]) {
      NSLog(@"Could not get contactless (NFC) payment data.");
      [md setObject:@"Error getting NFC payment data" forKey:@"message"];
    }
    else {
      NSLog(@"Could not get barcode/chip (MSR/EMV) payment data.");
      [md setObject:@"Error getting barcode/chip payment data" forKey:@"message"];
    }
    
    [self fireEvent:@"magneticCardError" body:md];
    
    return;
  }
  
  md = [NSMutableDictionary dictionary];
  if( [pinpad getEncryptionMode]==EncryptionMode_VSP ) {
    [md setValue:accountNumber forKey:@"pan"];
    [md setValue:track1 forKey:@"track1"];
    [md setValue:track2 forKey:@"track2"];
    [md setValue:expiry forKey:@"expiry"];
  } else {
    [md setValue:@"TURN_ON_VSP" forKey:@"pan"];
    [md setValue:@"TURN_ON_VSP" forKey:@"track1"];
    [md setValue:@"TURN_ON_VSP" forKey:@"track2"];
    [md setValue:@"TURN_ON_VSP" forKey:@"expiry"];
  }
  [md setValue:month forKey:@"month"];
  [md setValue:year forKey:@"year"];
  [md setValue:contactless forKey:@"contactless"];
  [md setValue:pinpad.pinpadSerialNumber forKey:@"terminal_id"];
   
  [self fireEvent:@"magneticCardData" body:md];
}

@end
