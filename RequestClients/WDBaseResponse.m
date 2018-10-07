//
//  WDBaseResponse.m
//  uber
//
//  Created by Dong Wang on 2018/1/23.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import "WDBaseResponse.h"

@implementation WDBaseResponse

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n状态吗: %zd,\n错误: %@,\n响应头: %@,\n响应体: %@, \nURL: %@", self.statusCode, self.error, self.headers, self.responseObject , self.urlString];
}

- (void)setError:(NSError *)error {
    _error = error;
    self.statusCode = error.code;
    self.errorMsg = error.localizedDescription;
}


@end
