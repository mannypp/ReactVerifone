

#import <Foundation/Foundation.h>

@class VFI_ISCP_HIGH; 
/**
 * Encapsulating data class utilized by VFIBarcode
 */
@interface VFI_ISCP_HIGH : NSObject {
    unsigned char commandType;          //!< Type of command
	unsigned char group;                //!< setup/control/status/event
	unsigned char fid;                  //!< frame ID
	NSData* param;                      //!< data parameter(s)
	
}
/**
 * clears all ISCP_HIGH properties
 */
-(void)clear;

@property unsigned char commandType;
@property unsigned char group;
@property unsigned char fid;
#if !__has_feature(objc_arc)
@property (nonatomic, retain) NSData *param;
#else
@property (nonatomic, strong) NSData *param;
#endif


@end
