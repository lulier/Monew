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
@property(nonatomic,strong)NSString *userID;
@property(nonatomic,strong)NSString *account;
@property(nonatomic,strong)NSString *password;
@property(nonatomic,strong)NSString *openID;
@property(nonatomic,)LoginType type;
@property(nonatomic)BOOL isActive;
@property(nonatomic,strong)NSString *loginTime;
@property(nonatomic)BOOL completeInfo;

+ (AccountManager *)singleInstance;
-(void)saveAccount;
- (void)deleteAccount;
+ (BOOL)isExist;
+(void)login:(LoginType)type parameters:(nonnull NSDictionary *)parameters success:(nullable void (^)( NSURLSessionTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionTask * _Nullable task, NSError * _Nullable error))failure;
+(void)registAccount:(RegistType)type parameters:(nonnull NSDictionary *)parameters success:(nullable void (^)( NSURLSessionTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionTask * _Nullable task, NSError * _Nullable error))failure;
+ (void)checkPhoneInUse:(nonnull NSString *)phoneNumber success:(nullable void (^)(BOOL isInused))success failure:(nullable void (^)(NSString * _Nullable message))failure;
@end
