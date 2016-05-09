#import <Foundation/Foundation.h>

@interface NSData (Base64Additions)

+(id)decodeBase64ForString:(NSString *)decodeString;
+(id)decodeWebSafeBase64ForString:(NSString *)decodeString;

-(NSString *)encodeBase64ForData;
-(NSString *)encodeWebSafeBase64ForData;
-(NSString *)encodeWrappedBase64ForData;

@end
