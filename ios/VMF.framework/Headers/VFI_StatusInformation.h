//
//  StatusInformation.h
//  VMF
//
//  Created by Randy Palermo on 11/17/11.
//  Copyright 2011 VeriFone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
	LineTypes_Unknown = 0,
	LineTypes_TextFile = 1,
	LineTypes_BinaryFile = 2,
	LineTypes_Parameter = 3,
	LineTypes_Blank = 4,
	LineTypes_BinaryFileEmpty = 5
	
} LineTypes;

@interface VFI_StatusInformation : NSObject {

	LineTypes LineType;
	NSString *Filename;
	NSString *Description;
	long TotalPackets;
	long PacketCount;
}

@property LineTypes LineType;
#if !__has_feature(objc_arc)
    @property (nonatomic, retain) NSString *Filename;
    @property (nonatomic, retain) NSString *Description;
#else
    @property (nonatomic, strong) NSString *Filename;
    @property (nonatomic, strong) NSString *Description;
#endif
@property long TotalPackets;
@property long PacketCount;

@end
