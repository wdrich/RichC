#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (WD)

/*
 * Creates an image from the orientation
 */
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

@end
