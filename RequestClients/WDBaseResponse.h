//
//  WDBaseResponse.h
//  uber
//
//  Created by Dong Wang on 2018/1/23.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDBaseResponse : NSObject

/** <#digest#> */
@property (nonatomic, strong) NSError *error;

/** <#digest#> */
@property (nonatomic, copy) NSString *errorMsg;

/** <#digest#> */
@property (assign, nonatomic) NSInteger statusCode;

/** <#digest#> */
@property (strong, nonatomic) NSString *urlString;

/** <#digest#> */
@property (nonatomic, copy) NSMutableDictionary *headers;

/** <#digest#> */
@property (nonatomic, strong) id responseObject;


@end
