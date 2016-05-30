//
//  NetworkingManager.h
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/22.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/UIImageView+WebCache.h>

//#define MONEWDOMAIN @"http://120.25.103.72:8002"
//#define MONEWFOLDER @"monew_debug_folder"

//#define MONEWDOMAIN @"http://120.25.103.72:8004"
//#define MONEWFOLDER @"monew_debug_folder"

#define MONEWDOMAIN @"http:test.mo-new.com"
#define MONEWFOLDER @"monew_debug_folder"


//#define MONEWDOMAIN @"http://english.mo-new.com"
//#define MONEWFOLDER @"monew_official_folder"


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
    RUActionCode,
    RUBindPhone,
    RUUserInfo,
    RUSetUserInfo,
    RUGetCloudURL,
    RUCheckNetwork,
    RUResetPassword,
    RUUpdateState,
    RUWeixinBind,
    RUUploadVoice,
    RUThirdPartyLogin,
    RUCheckBindPhone,
    RUCustom
};
enum Return_Code
{
    NORMAL_RESPONSE=0,
    INVALID_ACCOUNT_FORMAT=99,
    USER_EXISTS=98,
    USER_NOT_ACTIVE=97,
    USER_NOT_EXISTS=96,
    PASSWD_INCORRECT=95,
    EMAIL_ERROR=94,
    PARAM_ERROR_NULL_THIRD_PARTY=93,
    PARAM_ERROR_PASSWORD_EXISTS=92,
    PARAM_ERROR_NULL_SALT=91,
    PARAM_ERROR_NULL_PHONE=90,
    PARAM_ERROR_NULL_USERID=89,
    PARAM_ERROR_NULL_USERID_GRADEID=88,
    PARAM_ERROR_UPLOAD_AUTH_FAIL=87,
    PARAM_ERROR_INVALID_UPLOAD_INFO=86,
    PASSWD_UNSET=85,
    BIND_PHONE_ERROR1=84,
    BIND_PHONE_ERROR2=83,
    BIND_PHONE_ERROR3=82,
    BIND_PHONE_ERROR4=81,
    UNBIND_PHONE_ERROR1=80,
    UNBIND_PHONE_ERROR2=79,
    PARAM_ERROR_NULL_PASSWORD=78
};

@interface NetworkingManager : NSObject

+(nonnull NSURLSessionTask*)httpRequest:(RequestType)type url:(RequestURL)url parameters:(nullable NSDictionary*)parameters progress:(nullable void (^)(NSProgress * _Nullable progress))progressBlock success:(nullable void (^)( NSURLSessionTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionTask * _Nullable task, NSError * _Nullable error))failure completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;
+(nonnull NSString*)requestURL:(RequestURL)url;
@end
