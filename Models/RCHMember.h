//
//  RCHMember.h
//  richcore
//
//  Created by WangDong on 2018/5/16.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHMember : NSObject

@property (nonatomic, assign) NSInteger member_id;
@property (nonatomic, assign) NSInteger grade;
@property (nonatomic, assign) BOOL google_auth;
@property (nonatomic, assign) BOOL second_security_tip;
@property (nonatomic, assign) BOOL is_kyc_authed;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *mobile_raw;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *short_email;
@property (nonatomic, copy) NSString *email_raw;
@property (nonatomic, copy) NSString *security_level;

@property (nonatomic, strong) NSArray *roles;
@property (nonatomic, strong) NSDictionary *country;
@property (nonatomic, strong) NSDictionary *mobile_country;
@property (nonatomic, strong) NSDictionary *referral;

@end
