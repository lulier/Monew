//
//  NetworkingManager.h
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/22.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/UIImageView+WebCache.h>

typedef NS_ENUM(NSInteger,RequestType)
{
    RTGet=0,
    RTPost,
    RTDownload,
    RTUpload
};

typedef NS_ENUM(NSInteger,RequestURL)
{
    RUText_list=0,
    RUText_detail,
    RUGrade_list,
    RURegist,
    RULogin,
    RUGetSalt,
    RUCheckAvail,
    RUCustom
};
enum Return_Code
{
    NORMAL_RESPONSE=0,
    TEXT_VERSION_ERR=91,
    PASSWD_UNSET=92,
    BIND_PHONE_ERROR=93,
    PASSWD_INCORRECT=94,
    USER_NOT_ACTIVE=95,
    USER_EXIST=96,
    PARAM_ERROR=97,
    TEXT_NOT_EXIST=98,
    USER_NOT_EXIST=99
};

@interface NetworkingManager : NSObject

+(nonnull NSURLSessionTask*)httpRequest:(RequestType)type url:(RequestURL)url parameters:(nullable NSDictionary*)parameters progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgressBlock success:(nullable void (^)( NSURLSessionTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionTask * _Nullable task, NSError * _Nullable error))failure completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;
+(nonnull NSString*)requestURL:(RequestURL)url;
+(void)downloadImage:(NSURL*_Nullable)downloadURL block:(nonnull void (^)(UIImage* _Nullable image))block;
@end
