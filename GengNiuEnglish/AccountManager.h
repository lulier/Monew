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
    LTEmail,
    LTWeiBo,
    LTWeiXin,
    LTQQ
};
typedef NS_ENUM(NSInteger,UserGender)
{
    UGBoy,
    UGGirl
};

@interface AccountManager : NSObject
@property(nonatomic,strong)NSString *userID;
@property(nonatomic,strong)NSString *account;
@property(nonatomic,strong)NSString *password;
@property(nonatomic,strong)NSString *openID;
@property(nonatomic)LoginType type;
@property(nonatomic)BOOL isActive;
@property(nonatomic,strong)NSString *loginTime;
@property(nonatomic)NSInteger channel;
@property(nonatomic)BOOL completeInfo;

//user info
@property(nonatomic)UserGender gender;
@property(strong,nonatomic)NSString *nickName;
@property(strong,nonatomic)NSString *portraitKey;
@property(strong,nonatomic)NSString *thirdPartyImage;

+ (AccountManager *)singleInstance;
- (void)saveAccount;
- (void)deleteAccount;
+ (BOOL)isExist;
+ (void)login:(LoginType)type parameters:(NSDictionary *)parameters success:(void (^)( NSURLSessionTask * task, id responseObject))success failure:( void (^)(NSURLSessionTask *  task, NSError *  error))failure;
+ (void)registAccount:(RegistType)type parameters:( NSDictionary *)parameters success:( void (^)( NSURLSessionTask *  task, id  responseObject))success failure:( void (^)(NSURLSessionTask *  task, NSError *  error))failure;
+ (void)checkPhoneInUse:(NSString *)phoneNumber success:(void (^)(BOOL isInused))success failure:(void (^)(NSString * message))failure;
+ (void)thirdPartyLogin:(nonnull NSDictionary *)parameters success:(nullable void (^)( NSURLSessionTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionTask * _Nullable task, NSError * _Nullable error))failure;
- (void)bindPhone:(NSString*)phone bind:(BOOL)bind password:(NSString*)passWord success:(void (^)(BOOL bindSuccess))success failure:(void (^)(NSString * message))failure;
- (void)getUserInfo;
- (void)uploadUserInfo;
- (void)resetPassword:(NSDictionary *)parameters success:(void (^)(BOOL resetSuccess))success failure:(void (^)(NSString * message))failure;
- (void)checkWeixinBind:(void (^)(BOOL bind))success failure:(void (^)(NSString * message))failure;
- (void)checkPhoneBind:(void (^)(BOOL bind))success failure:(void (^)(NSString * message))failure;
-(void)uploadVoice:(NSString*)textID voiceKey:(NSString*)voiceKey score:(NSInteger)score sentence:(NSString*)sentence;
@end
