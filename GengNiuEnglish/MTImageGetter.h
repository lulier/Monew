//
//  MTImageGetter.h
//  WeShare
//
//  Created by 俊健 on 15/9/16.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+MTTag.h"
#import <SDWebImage/UIImageView+WebCache.h>

//typedef void(^MTImageGetterCompletionBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL);


@interface MTImageGetter : NSObject

-(instancetype)initWithImageView:(UIImageView*)imageView  imageName:(NSString *)imageName downloadURL:(NSURL*)downloadURL;
-(void)getImage;
-(void)getImageComplete:(void (^)(UIImage* image))block;
@end
