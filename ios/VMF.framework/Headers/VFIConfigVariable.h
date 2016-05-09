//
//  VFIConfigVariable.h
//  VMF
//
//  Created by James Gnann on 2/18/15.
//  Copyright (c) 2015 VeriFone, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@class VFIConfigVariable;

/**
 * Encapsulating data class utilized by VFIPinpad
 */
@interface VFIConfigVariable : NSObject {
    int responseCode;           //!< Status for this particular parameter. Check this status to determine the success of setting the configuration variable
    NSString*   parameter;      //!< Config Parameter
    NSString*   value;          //!< Config Value returned from an M44:() or setConfigurationVariable:() command
}
/**
 * clears all VFIConfigVariable properties
 */
-(void)clear;


@property int responseCode;
#if !__has_feature(objc_arc)
    @property (nonatomic, retain) NSString *parameter;
    @property (nonatomic, retain) NSString *value;
#else
    @property (nonatomic, strong) NSString *parameter;
    @property (nonatomic, strong) NSString *value;
#endif

@end
