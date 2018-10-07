//
//  NSErrorAdditions.m
//  LaShouGroup
//
//  Created by massifor on 12-9-24.
//
//

#import "NSErrorAdditions.h"

@implementation NSError (MJLAdditional)

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message
                                                         forKey:NSLocalizedDescriptionKey];
    
    return [NSError errorWithDomain:@"com.richcore.message" code:code userInfo:userInfo];
}

+ (NSString *)descriptionForStatus:(RCHStatus *)status
{
    NSString *errorString = [NSError descriptionForCode:status.code];
    if (errorString) {
        return errorString;
    } else {
        return status.message;
    }
}


+ (NSString *)descriptionForCode:(NSInteger)errorCode {
    NSString *desc = nil;
	
	switch (errorCode) {
		case 1:
			desc = NSLocalizedString(@"用户未登陆",nil);
			break;
   		default:
            desc = nil;
			break;
	}
	
	return desc;
}


@end
