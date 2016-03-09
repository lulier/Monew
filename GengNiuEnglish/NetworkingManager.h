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
    RUCustom
};

static const NSString *URLForGradeList=@"http://120.25.103.72:8002/courseware/grade_list_query/";
static const NSString *URLForTextList=@"http://120.25.103.72:8002/courseware/text_list_query/";
static const NSString *URLForTextDetai=@"http://120.25.103.72:8002/courseware/text_detail_query/";
static const NSString *URLForRegist=@"http://120.25.103.72:8002/student/register/";
static const NSString *URLForLogin=@"http://120.25.103.72:8002/student/login/";
static const NSString *URLForGetSalt=@"http://120.25.103.72:8002/student/get_salt/";


@interface NetworkingManager : NSObject


+(NSURLSessionTask*)httpRequest:(RequestType)type url:(RequestURL)url parameters:(NSDictionary*)parameters progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock success:(nullable void (^)( NSURLSessionTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionTask * _Nullable task, NSError * _Nullable error))failure completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;
+(nonnull NSString*)requestURL:(RequestURL)url;
+(void)downloadImage:(NSURL*)downloadURL block:(void (^)(UIImage* image))block;
@end
