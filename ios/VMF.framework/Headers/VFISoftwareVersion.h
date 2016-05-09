

#import <Foundation/Foundation.h>

/**
 * Encapsulating data class utilized by VFIControl
 */
@interface VFISoftwareVersion : NSObject {
	NSString *AppMajor;                 //!< Software Version - Major
	NSString *AppMinor;                 //!< Software Version - Minor
	NSString *AppBuild;                 //!< Software Version - Build
	NSString *OSPlatform;               //!< Software OS Platform
	NSString *OSID;                     //!< Software Identification
	NSString *OSVersion;                //!< Software Version - Main
	NSString *OSSubVersion;             //!< Software Version - Sub
    NSString *OSBuildYear;              //!< Software Version - Build Year
    NSString *OSBuildMonth;             //!< Software Version - Build Month
    NSString *OSBuildDay;               //!< Software Version - Build Day
	
	
}
/**
 * clears all VFISoftwareVersion properties
 */
-(void)clear;


#if !__has_feature(objc_arc)
    @property (nonatomic, retain) NSString *AppMajor;
    @property (nonatomic, retain) NSString *AppMinor;
    @property (nonatomic, retain) NSString *AppBuild;
    @property (nonatomic, retain) NSString *OSPlatform;
    @property (nonatomic, retain) NSString *OSID;
    @property (nonatomic, retain) NSString *OSVersion;
    @property (nonatomic, retain) NSString *OSSubVersion;
    @property (nonatomic, retain) NSString *OSBuildYear;
    @property (nonatomic, retain) NSString *OSBuildMonth;
    @property (nonatomic, retain) NSString *OSBuildDay;
#else
    @property (nonatomic, strong) NSString *AppMajor;
    @property (nonatomic, strong) NSString *AppMinor;
    @property (nonatomic, strong) NSString *AppBuild;
    @property (nonatomic, strong) NSString *OSPlatform;
    @property (nonatomic, strong) NSString *OSID;
    @property (nonatomic, strong) NSString *OSVersion;
    @property (nonatomic, strong) NSString *OSSubVersion;
    @property (nonatomic, strong) NSString *OSBuildYear;
    @property (nonatomic, strong) NSString *OSBuildMonth;
    @property (nonatomic, strong) NSString *OSBuildDay;
#endif


@end