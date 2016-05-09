//
//  InitialBlock.h
//  VMF
//
//  Created by Randy Palermo on 11/17/11.
//  Copyright 2011 VeriFone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface VFI_InitialBlock : NSObject {

	NSString *Owner;
	NSString *Platform;
	NSString *Unknown1;
	NSString *DLType;
	NSString *CurrentZA;
	NSString *CurrentZT;
	NSString *Eprom;
	int BlockSize;
	NSString *Unknown2;
	NSString *Unknown3;
}

#if !__has_feature(objc_arc)
    @property (nonatomic,retain) NSString *Owner;
    @property (nonatomic,retain) NSString *Platform;
    @property (nonatomic,retain) NSString *Unknown1;
    @property (nonatomic,retain) NSString *DLType;
    @property (nonatomic,retain) NSString *CurrentZA;
    @property (nonatomic,retain) NSString *CurrentZT;
    @property (nonatomic,retain) NSString *Eprom;
    @property int BlockSize;
    @property (nonatomic,retain) NSString *Unknown2;
    @property (nonatomic,retain) NSString *Unknown3;
#else
    @property (nonatomic,strong) NSString *Owner;
    @property (nonatomic,strong) NSString *Platform;
    @property (nonatomic,strong) NSString *Unknown1;
    @property (nonatomic,strong) NSString *DLType;
    @property (nonatomic,strong) NSString *CurrentZA;
    @property (nonatomic,strong) NSString *CurrentZT;
    @property (nonatomic,strong) NSString *Eprom;
    @property int BlockSize;
    @property (nonatomic,strong) NSString *Unknown2;
    @property (nonatomic,strong) NSString *Unknown3;
#endif
@end
