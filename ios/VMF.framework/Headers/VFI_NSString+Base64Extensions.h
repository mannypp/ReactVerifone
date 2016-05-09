//
//  NSString+Base64Extensions.h
//  VMF
//
//  Created by James on 5/22/15.
//  Copyright (c) 2015 VeriFone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64Extensions)

+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;

@end
