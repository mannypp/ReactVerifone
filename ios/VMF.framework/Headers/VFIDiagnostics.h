

#import <Foundation/Foundation.h>

@class VFIDiagnostics;
/**
 * Encapsulating data class utilized by VFIPinpad
 */
@interface VFIDiagnostics : NSObject {
    NSString *terminalName;                 //!< Terminal Name
	NSString *osversion;                    //!< ROM OS Version
	NSString *xpiVersion;                   //!< Application Version
	NSString *vxciVersion;                  //!< Core Library Version
    NSString *cxpiVersion;                  //!< XCPI Package Version
    NSString *camVersion;                  //!< Core Library Version
	NSString *emvVersion;                   //!< EMV Kernel version
	NSString *ctlsReaderFirmwareVersion;    //!< CTLS Firmware Version.
	NSString *vspVersion;                   //!< VSP Firmware Version.
	NSString *pinpadSerialNumber;           //!< Pinpad Serial Number
	NSString *svcInfoSerialNumber;          //!< Pinpad Serial Number
	NSString *svcInfoPartNumber;            //!< Pinpad Serial Number
    
}
/**
 * clears all VFIDiagnostics properties
 */
-(void)clear;
/**
 * Singleton instance of VFIDiagnostics utilized by VFIPinpad
 */
+ (VFIDiagnostics *)sharedController;

#if !__has_feature(objc_arc)
    @property (nonatomic, retain) NSString *terminalName;
    @property (nonatomic, retain) NSString *osversion;
    @property (nonatomic, retain) NSString *xpiVersion;
    @property (nonatomic, retain) NSString *vxciVersion;
    @property (nonatomic, retain) NSString *cxpiVersion;
    @property (nonatomic, retain) NSString *camVersion;
    @property (nonatomic, retain) NSString *emvVersion;
    @property (nonatomic, retain) NSString *ctlsReaderFirmwareVersion;
    @property (nonatomic, retain) NSString *pinpadSerialNumber;
    @property (nonatomic, retain) NSString *svcInfoSerialNumber;
    @property (nonatomic, retain) NSString *svcInfoPartNumber;
    /**
     * This property will currently return null. Reserved for future use.
     *
     */
    @property (nonatomic, retain) NSString *vspVersion;
#else
    @property (nonatomic, strong) NSString *terminalName;
    @property (nonatomic, strong) NSString *osversion;
    @property (nonatomic, strong) NSString *xpiVersion;
    @property (nonatomic, strong) NSString *vxciVersion;
    @property (nonatomic, strong) NSString *cxpiVersion;
    @property (nonatomic, strong) NSString *camVersion;
    @property (nonatomic, strong) NSString *emvVersion;
    @property (nonatomic, strong) NSString *ctlsReaderFirmwareVersion;
    @property (nonatomic, strong) NSString *pinpadSerialNumber;
    @property (nonatomic, strong) NSString *svcInfoSerialNumber;
    @property (nonatomic, strong) NSString *svcInfoPartNumber;
    /**
     * This property will currently return null. Reserved for future use.
     *
     */
    @property (nonatomic, strong) NSString *vspVersion;
#endif



@end
