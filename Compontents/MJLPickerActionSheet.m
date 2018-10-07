//
//  MJLPickerActionSheet.m
//  MJLMerchantsChatServerPush
//
//  Created by WangDong on 14/11/7.
//  Copyright (c) 2014年 WangDong. All rights reserved.
//

#import "MJLPickerActionSheet.h"

@interface MJLPickerActionSheet ()
{
    NSArray *_array;
    NSMutableArray *_selectIndexes;
    UIView *_pickerView;
    MJLPickerActionSheetType _pickerActionSheetType;
    NSString *_key;
}
@end

@implementation MJLPickerActionSheet
- (id)initWithTitle:(NSString *)title object:(id)object key:(NSString *)key {
    return [self initWithTitle:title object:object key:key type:MJLPickerActionSheetTypeDefault];
}

- (id)initWithTitle:(NSString *)title object:(id)object key:(NSString *)key type:(MJLPickerActionSheetType)type {
    self = [super initWithFrame:CGRectMake(0, kMainScreenHeight, kMainScreenWidth, kMainScreenHeight)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _array =  (NSArray *)object;
        _numberOfComponents = [_array count];
        _pickerActionSheetType = type;
        
        _key = key;
        
        _selectedStrings = [self setStrings];

        UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 200, kMainScreenWidth, 44)];
        toolbar.backgroundColor = kNavigationColor_MB;
        toolbar.bottom = kMainScreenHeight - 216;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.shadowColor = [UIColor grayColor];
        titleLabel.shadowOffset = CGSizeMake(0, 1);
        if (title) {
            titleLabel.text = title;
        }
        [titleLabel sizeToFit];
        
        titleLabel.frame = (CGRect){{(toolbar.width - titleLabel.width) / 2.0f, 0.0f}, {titleLabel.width, toolbar.height}};
        [toolbar addSubview:titleLabel];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(10.0f, 0.0f, 50.0f, toolbar.height);
        [cancelButton setTitle:NSLocalizedString(@"取消",nil) forState:UIControlStateNormal];
        cancelButton.titleLabel.textColor = [UIColor whiteColor];
        [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:cancelButton];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(toolbar.width - 10.0 - 50.0f, 0.0f, 50.0f, toolbar.height);
        [doneButton setTitle:NSLocalizedString(@"完成",nil) forState:UIControlStateNormal];
        doneButton.titleLabel.textColor = [UIColor whiteColor];
        [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:doneButton];

        [self addSubview:toolbar];
        
        if (_pickerActionSheetType == MJLPickerActionSheetTypeDefault || _pickerActionSheetType == MJLPickerActionSheetTypeArea || _pickerActionSheetType == MJLPickerActionSheetTypeCoin) {
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 216)];
            pickerView.bottom = kMainScreenHeight;
            pickerView.backgroundColor = [UIColor whiteColor];
            pickerView.showsSelectionIndicator = YES;
            pickerView.delegate = self;
            [self addSubview:pickerView];
            _pickerView = pickerView;
        } else if (_pickerActionSheetType == MJLPickerActionSheetTypeDate) {
            UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 216)];
            pickerView.bottom = kMainScreenHeight;
            pickerView.backgroundColor = [UIColor whiteColor];
            // 设置时区
            [pickerView setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            // 设置当前显示时间
            [pickerView setDate:[NSDate date] animated:YES];
            // 设置显示最大时间（此处为当前时间）
//            [pickerView setMaximumDate:[NSDate date]];
            [pickerView setMinimumDate:[NSDate date]];
            // 设置UIpickerView的显示模式
            [pickerView setDatePickerMode:UIDatePickerModeDate];
            // 当值发生改变的时候调用的方法
            [pickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:pickerView];
            _pickerView = pickerView;
        } else {
        
        }
        
    }
    return self;
}

- (id)initWithTitle:(NSString *)title object:(id)object numberOfComponents:(NSInteger)numberOfComponents key:(NSString *)key type:(MJLPickerActionSheetType)type {
    self = [super initWithFrame:CGRectMake(0, kMainScreenHeight, kMainScreenWidth, kMainScreenHeight)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        
        if ([object isKindOfClass:[NSArray class]]) {
            _array =  (NSArray *)object;
        } else {
        
        }

        _numberOfComponents = numberOfComponents;
        _pickerActionSheetType = type;
        
        _key = key;
        
        _selectIndexes = [NSMutableArray arrayWithCapacity:_numberOfComponents];
        [_selectIndexes addObject:[NSNumber numberWithInteger:0]];
        [_selectIndexes addObject:[NSNumber numberWithInteger:0]];
        
        _selectedStrings = [self setStrings];
        
        UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 200, kMainScreenWidth, 44)];
        toolbar.backgroundColor = kAppMainColor;
        toolbar.bottom = kMainScreenHeight - 216;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.shadowColor = [UIColor grayColor];
        titleLabel.shadowOffset = CGSizeMake(0, 1);
        if (title) {
            titleLabel.text = title;
        }
        [titleLabel sizeToFit];
        
        titleLabel.frame = (CGRect){{(toolbar.width - titleLabel.width) / 2.0f, 0.0f}, {titleLabel.width, toolbar.height}};
        [toolbar addSubview:titleLabel];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(10.0f, 0.0f, 50.0f, toolbar.height);
        [cancelButton setTitle:NSLocalizedString(@"取消",nil) forState:UIControlStateNormal];
        cancelButton.titleLabel.textColor = [UIColor whiteColor];
        [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:cancelButton];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(toolbar.width - 10.0 - 50.0f, 0.0f, 50.0f, toolbar.height);
        [doneButton setTitle:NSLocalizedString(@"完成",nil) forState:UIControlStateNormal];
        doneButton.titleLabel.textColor = [UIColor whiteColor];
        [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:doneButton];
        
        [self addSubview:toolbar];
        
        if (_pickerActionSheetType == MJLPickerActionSheetTypeDefault || _pickerActionSheetType == MJLPickerActionSheetTypeArea || _pickerActionSheetType == MJLPickerActionSheetTypeCoin) {
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 216)];
            pickerView.bottom = kMainScreenHeight;
            pickerView.backgroundColor = [UIColor whiteColor];
            pickerView.showsSelectionIndicator = YES;
            pickerView.delegate = self;
            [self addSubview:pickerView];
            _pickerView = pickerView;
        } else if (_pickerActionSheetType == MJLPickerActionSheetTypeDate) {
            UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 216)];
            pickerView.bottom = kMainScreenHeight;
            pickerView.backgroundColor = [UIColor whiteColor];
            // 设置时区
            [pickerView setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            // 设置当前显示时间
            [pickerView setDate:[NSDate date] animated:YES];
            // 设置显示最大时间（此处为当前时间）
            //            [pickerView setMaximumDate:[NSDate date]];
            [pickerView setMinimumDate:[NSDate date]];
            // 设置UIpickerView的显示模式
            [pickerView setDatePickerMode:UIDatePickerModeDate];
            // 当值发生改变的时候调用的方法
            [pickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:pickerView];
            _pickerView = pickerView;
        } else {
        
        }
        
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}


#pragma mark -
#pragma mark - CustomFuction

- (void)show {
    self.alpha = 0;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView beginAnimations:nil context:nil];
    self.top = 0;
    self.alpha = 1;
    [UIView commitAnimations];
}

- (NSArray *)setStrings {
    
    if (_pickerActionSheetType == MJLPickerActionSheetTypeDefault) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger i = 0; i < _numberOfComponents; i ++) {
            
            NSInteger index = [(UIPickerView *)_pickerView selectedRowInComponent:i];
            NSString *text = [NSString stringWithFormat:@"%@", [[_array objectAtIndex:i] objectAtIndex:index]];
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInteger:index], text ?: @""] forKeys:@[@"index", @"text"]];
            [array addObject:dic];

        }
        return array;
    } else if (_pickerActionSheetType == MJLPickerActionSheetTypeDate) {
        NSDate *selectedDate = [(UIDatePicker *)_pickerView date];
        NSTimeInterval stemp = [selectedDate timeIntervalSince1970];
        if (stemp == 0) {
            stemp = [[NSDate date] timeIntervalSince1970];
        }
        NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithDouble:stemp]];
        return array;

    } else if (_pickerActionSheetType == MJLPickerActionSheetTypeCoin) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger i = 0; i < _numberOfComponents; i ++) {
            
            NSInteger index = [(UIPickerView *)_pickerView selectedRowInComponent:i];
            NSDictionary *info = [[_array objectAtIndex:i] objectAtIndex:index];
            NSString *text = [info objectForKey:@"code"];
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInteger:index], text ?: @""] forKeys:@[@"index", @"text"]];
            [array addObject:dic];
        }
        return array;
    } else {
        return nil;
    }
}

- (void)datePickerValueChanged:(id)sender {
    _selectedStrings = [self setStrings];
}

- (void)cancelButtonClicked:(id)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    self.top = kMainScreenHeight;
    [UIView commitAnimations];
}

- (void)doneButtonClicked:(id)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    self.top = kMainScreenHeight;
    [UIView commitAnimations];

    if(_delegate && [(NSObject *)_delegate respondsToSelector:@selector(pickerActionSheet:didPickerStrings:key:)]) {
        [_delegate pickerActionSheet:self didPickerStrings:_selectedStrings key:_key];
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self removeFromSuperview];
}

#pragma mark -
#pragma mark pickerView datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return _numberOfComponents;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    if ([_array count] > component) {
        NSArray *result = [_array objectAtIndex:component];
        return [result count];
    }
    return 0;
}

#pragma mark -
#pragma mark pickerview delegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view

{
    
    UILabel *myView = nil;
    
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.width, 30)];
    
    myView.textAlignment = NSTextAlignmentCenter;
    
//    myView.text = [pickerNameArray objectAtIndex:row];
    
    myView.font = [UIFont systemFontOfSize:20];         //用label来设置字体大小
    
    myView.backgroundColor = [UIColor clearColor];
    
    if ([_array count] > component) {
        NSArray *result = [_array objectAtIndex:component];
        if ([result count] > row) {
            if ([_key isEqualToString:@"price"]) {
                myView.text = [NSString stringWithFormat:NSLocalizedString(@"%@元",nil), [result objectAtIndex:row]];
            } else if ([_key isEqualToString:@"coin"]) {
                myView.text = [[result objectAtIndex:row] objectForKey:@"code"];
            } else {
                myView.text = [NSString stringWithFormat:@"%@", [result objectAtIndex:row]];
            }
        }
    }
    
    return myView;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    [_selectIndexes setObject:[NSNumber numberWithInteger:row] atIndexedSubscript:component];
    if ([_key isEqualToString:@"city"] || (_pickerActionSheetType == MJLPickerActionSheetTypeArea)) {
    
        //滚动复位其他滚轮
        for (NSInteger i = component + 1; i < _numberOfComponents; i++) {
            [pickerView reloadComponent:i];
            [pickerView selectRow:0 inComponent:i animated:YES];
        }
    }
    _selectedStrings = [self setStrings];
}

@end
