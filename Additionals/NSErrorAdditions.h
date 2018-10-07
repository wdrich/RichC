//
//  NSErrorAdditions.h
//  LaShouGroup
//
//  Created by massifor on 12-9-24.
//
//

#define kErrorCodeParseXML				0x20091200
#define kErrorCodeResponseIsEmpty		0x20091201
#define kErrorCodeNetworkInterruption	0x20091202
#define kErrorCodeParamatersIsNull		0x20091203

#import <Foundation/Foundation.h>
#import "RCHStatus.h"

@interface NSError (MJLAdditional)

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message;
+ (NSString *)descriptionForCode:(NSInteger)errorCode;
+ (NSString *)descriptionForStatus:(RCHStatus *)status;

@end
