//
//  decryptedCredentials
//  VMF
//
//  Created by Randy Palermo on 1/24/13.
//  Copyright (c) 2013 VeriFone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * Encapsulating data class utilized by VFIConnect
 */
@interface VFI_decryptedCredentials : NSObject{
    NSString*	clientID;       //!< Client ID
	NSString*	deviceKey;      //!< Device Key
	NSString*	serialNumber;   //!< Serial Number
	NSString*	deviceType;     //!< Device Type
    
}

/**
 * clears all decryptedCredentials properties
 */
-(void)clear;
#if !__has_feature(objc_arc)
    @property (nonatomic, retain) NSString*	clientID;
    @property (nonatomic, retain) NSString*	deviceKey;
    @property (nonatomic, retain) NSString*	serialNumber;
    @property (nonatomic, retain) NSString*	deviceType;
#else
    @property (nonatomic, strong) NSString*	clientID;
    @property (nonatomic, strong) NSString*	deviceKey;
    @property (nonatomic, strong) NSString*	serialNumber;
    @property (nonatomic, strong) NSString*	deviceType;
#endif
@end
