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
@property(nonatomic)NSInteger channel;
@property(nonatomic)BOOL completeInfo;

+ (AccountManager *)singleInstance;
- (void)saveAccount;
- (void)deleteAccount;
+ (BOOL)isExist;
+ (void)login:(LoginType)type parameters:(NSDictionary *)parameters success:(void (^)( NSURLSessionTask * task, id responseObject))success failure:( void (^)(NSURLSessionTask *  task, NSError *  error))failure;
+ (void)registAccount:(RegistType)type parameters:( NSDictionary *)parameters success:( void (^)( NSURLSessionTask *  task, id  responseObject))success failure:( void (^)(NSURLSessionTask *  task, NSError *  error))failure;
+ (void)checkPhoneInUse:(NSString *)phoneNumber success:(void (^)(BOOL isInused))success failure:(void (^)(NSString * message))failure;
- (void)bindPhone:(NSString*)phone bind:(BOOL)bind password:(NSString*)password success:(void (^)(BOOL bindSuccess))success failure:(void (^)(NSString * message))failure;
@end
