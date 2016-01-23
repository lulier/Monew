//
//  CommonMethod.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol dismissDelegate <NSObject>

-(void)dismissView;

@end

@interface CommonMethod : NSObject
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+(UIViewController*)getCurrentVC;
+(NSString*)getPath:(NSString*)fileName;
@end
