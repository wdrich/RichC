//
//  MJLPickerActionSheet.h
//  MJLMerchantsChatServerPush
//
//  Created by WangDong on 14/11/7.
//  Copyright (c) 2014年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPickerViewBeginSelectedNotification                @"kPickerViewBeginSelectedNotification" //
#define kPickerViewDidSelectedNotification                  @"kPickerViewDidSelectedNotification" //

typedef enum {
    MJLPickerActionSheetTypeDefault     = 1, //默认普通Picker
    MJLPickerActionSheetTypeDate        = 2,  //日期Picker
    MJLPickerActionSheetTypeArea        = 3,  //地区类型多选Picker
    MJLPickerActionSheetTypeCoin        = 4  //交易市场
} MJLPickerActionSheetType;

@protocol MJLPickerActionSheetDelegate;

@interface MJLPickerActionSheet : UIView <UIPickerViewDelegate> {

}

@property (nonatomic, assign) id<MJLPickerActionSheetDelegate> delegate;
@property (nonatomic, strong) NSString *selectedString;
@property (nonatomic, strong) NSArray *selectedStrings;
@property (nonatomic, assign) NSInteger numberOfComponents;

- (id)initWithTitle:(NSString *)title object:(id)object key:(NSString *)key;
- (id)initWithTitle:(NSString *)title object:(id)object key:(NSString *)key type:(MJLPickerActionSheetType)type;
- (id)initWithTitle:(NSString *)title object:(id)object numberOfComponents:(NSInteger)numberOfComponents key:(NSString *)key type:(MJLPickerActionSheetType)type;
- (void)show;

@end

@protocol MJLPickerActionSheetDelegate

@optional
- (void)pickerActionSheet:(MJLPickerActionSheet *)sheet didPickerString:(NSString *)pickedString key:(NSString *)key;

@required
- (void)pickerActionSheet:(MJLPickerActionSheet *)sheet didPickerStrings:(NSArray *)pickedStrings key:(NSString *)key;

@end
