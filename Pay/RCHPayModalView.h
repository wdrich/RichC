//
//  RCHPayModalView.h
//  richcore
//
//  Created by Apple on 2018/6/11.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHPayReq.h"
#import "RCHPayInfo.h"

@interface RCHPayModalView : UIView

- (void)displayReq:(RCHPayReq *)req
           payInfo:(RCHPayInfo *)payInfo
          onSubmit:(void (^)(NSString *, void (^)(NSString *)))onSubmit
        onComplete:(void (^)(void))onComplete;

@end
