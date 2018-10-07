//
//  RCHNumberTextField.h
//  MeiBe
//
//  Created by WangDong on 2018/3/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef struct Numeric{
    NSInteger length;
    NSInteger decimalDigits;
} Numeric;

CG_INLINE Numeric
CGNumeric(NSInteger length, NSInteger decimalDigits)
{
    Numeric num; num.length = length; num.decimalDigits = decimalDigits; return num;
}


@interface RCHNumberTextField : UITextField

@property (assign,nonatomic) Numeric numeric;
@property (nonatomic, copy) void (^onChanged)(NSString *text);
@property (nonatomic, copy) void (^finishEdit)(NSString *text);

-(NSString*)trimText;

@end
