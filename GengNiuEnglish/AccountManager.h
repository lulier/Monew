//
//  AccountManager.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/8.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkingManager.h"
#import "CommonMethod.h"

typedef NS_ENUM(NSInteger,RegistType)
{
    REGPhone,
    REGEmail
};
typedef NS_ENUM(NSInteger,LoginType)
{
    LTPhone,
    LTEmail
};

@interface AccountManager : NSObject
+(void)login:(LoginType)type parameters:(nonnull NSDictionary *)parameters success:(nullable void (^)( NSURLSessionTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionTask * _Nullable task, NSError * _Nullable error))failure;
+(void)registAccount:(RegistType)type parameters:(nonnull NSDictionary *)parameters success:(nullable void (^)( NSURLSessionTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionTask * _Nullable task, NSError * _Nullable error))failure;

@end
