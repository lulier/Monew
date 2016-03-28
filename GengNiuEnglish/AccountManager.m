//
//  AccountManager.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/8.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "AccountManager.h"
#import "MTDatabaseHelper.h"
#import "FXKeychain.h"
static NSString * const ACCOUNT_KEYCHAIN = @"GNAccount20160311";
@implementation AccountManager
@synthesize userID;
@synthesize password;
@synthesize account;
@synthesize loginTime;
@synthesize type;
@synthesize isActive;
@synthesize completeInfo;
@synthesize openID;
+ (AccountManager *)singleInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}
- (id)init {
    if ((self = [super init])) {
        [self loadAccount];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        userID = [aDecoder decodeObjectForKey:@"userID"];
        account = [aDecoder decodeObjectForKey:@"account"];
        password = [aDecoder decodeObjectForKey:@"password"];
        openID=[aDecoder decodeObjectForKey:@"openID"];
        type = [[aDecoder decodeObjectForKey:@"type"] integerValue];
        completeInfo = [[aDecoder decodeObjectForKey:@"hadCompleteInfo"] boolValue];
        isActive = [[aDecoder decodeObjectForKey:@"isActive"] boolValue];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userID forKey:@"userID"];
    [aCoder encodeObject:self.account forKey:@"account"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.openID forKey:@"openID"];
    [aCoder encodeObject:@(self.type) forKey:@"type"];
    [aCoder encodeObject:@(self.completeInfo) forKey:@"hadCompleteInfo"];
    [aCoder encodeObject:@(self.isActive) forKey:@"isActive"];
}


+ (BOOL)isExist
{
    return ([FXKeychain defaultKeychain][ACCOUNT_KEYCHAIN] != nil);
}

-(void)loadAccount
{
    [FXKeychain defaultKeychain].accessibility = FXKeychainAccessibleAlwaysThisDeviceOnly;
    AccountManager *accountManager = [FXKeychain defaultKeychain][ACCOUNT_KEYCHAIN];
    self.userID = accountManager.userID;
    self.account = accountManager.account;
    self.password = accountManager.password;
    self.openID = accountManager.openID;
    self.type = accountManager.type;
    self.completeInfo = accountManager.completeInfo;
    self.isActive = accountManager.isActive;
}
+(void)login:(LoginType)type parameters:(nonnull NSDictionary *)parameters success:(nullable void (^)( NSURLSessionTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionTask * _Nullable task, NSError * _Nullable error))failure
{
    NSString *accountNum=[parameters objectForKey:@"account"];
    NSString *loginType;
    if (type==LTPhone)
    {
        loginType=@"1";
    }
    if (type==LTEmail)
    {
        loginType=@"2";
    }
    NSString *password=parameters[@"password"];
    NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@",accountNum,loginType]];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:accountNum,@"account",sign,@"sign", nil];
    
    [NetworkingManager httpRequest:RTPost url:RUGetSalt parameters:dict progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        
        long int status=[[responseObject objectForKey:@"status"]integerValue];
        NSString* salt;
        if (status==0)
        {
            salt=[responseObject objectForKey:@"salt"];
            NSMutableString* md5_str = [CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@",password,salt]];
            NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@",accountNum,loginType]];
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:loginType,@"type",accountNum,@"account",md5_str,@"passwd",0,@"channel",sign,@"sign",nil];
            AccountManager *accountManager=[AccountManager singleInstance];
            accountManager.account=accountNum;
            accountManager.password=md5_str;
            accountManager.type=type;
            
            
            [NetworkingManager httpRequest:RTPost url:RULogin parameters:dict progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
                success(task,responseObject);
            } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
                failure(task,error);
            } completionHandler:nil];
        }
        else
        {
            success(task,responseObject);
        }
        
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        failure(task,error);
    } completionHandler:nil];
}
+(void)registAccount:(RegistType)type parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionTask * _Nullable, id _Nullable))success failure:(void (^)(NSURLSessionTask * _Nullable, NSError * _Nullable))failure
{
    NSString *accountNum=[parameters objectForKey:@"account"];
    NSString *password;
    NSString *reType;
    if (type==REGPhone)
    {
        reType=@"1";
    }
    if (type==REGEmail)
    {
        reType=@"2";
    }
    password=parameters[@"password"];
    NSString* salt = [CommonMethod randomStringWithLength:6];
    NSMutableString* md5_str = [CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@",password,salt]];
    NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@",accountNum,reType]];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:reType,@"type",accountNum,@"account",md5_str,@"passwd",salt,@"salt",0,@"channel",sign,@"sign",nil];
    [NetworkingManager httpRequest:RTPost url:RURegist parameters:dict progress:nil success:success failure:failure completionHandler:nil];
}
-(void)createTable
{
    NSString *dbPath=[CommonMethod getPath:[NSString stringWithFormat:@"%@",self.userID]];
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath isDirectory:&isDir])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"AccountInfo" indexesWithProperties:@[@"user_id  INTEGER PRIMARY KEY UNIQUE",@"account varchar(255)",@"password varchar(512)",@"type integer",@"login_time varchar(255)"]];
}
-(void)saveAccount
{
    [self createTable];
    NSArray *colums=[[NSArray alloc]initWithObjects:@"user_id",@"account",@"password",@"type",@"login_time", nil];
    NSArray *values=[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"'%@'",self.userID],[NSString stringWithFormat:@"'%@'",self.account],[NSString stringWithFormat:@"'%@'",self.password],[NSString stringWithFormat:@"%ld",self.type],[NSString stringWithFormat:@"'%@'",self.loginTime], nil];
    [[MTDatabaseHelper sharedInstance] insertToTable:@"AccountInfo" withColumns:colums andValues:values];
    [[NSUserDefaults standardUserDefaults] setObject:@"in" forKey:@"AccountStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [FXKeychain defaultKeychain][ACCOUNT_KEYCHAIN] = self;
}

- (void)deleteAccount {
    userID = nil;
    account = nil;
    password = nil;
    openID = nil;
    completeInfo = NO;
    isActive = NO;
    type = 0;
    
    [[FXKeychain defaultKeychain] removeObjectForKey:ACCOUNT_KEYCHAIN];
    
//    [ShareSDK cancelAuthorize:SSDKPlatformTypeSinaWeibo];
//    [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
//    [ShareSDK cancelAuthorize:SSDKPlatformTypeQQ];
}
+ (void)checkPhoneInUse:(NSString *)phoneNumber
                success:(void (^)(BOOL isInused))success
                failure:(void (^)(NSString *message))failure
{
    if (!phoneNumber || ![phoneNumber isKindOfClass:[NSString class]] || [phoneNumber isEqualToString:@""]) {
        failure(@"输入错误");
        return;
    }
    NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@",phoneNumber,@"1"]];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:phoneNumber forKey:@"phone"];
    [dictionary setValue:sign forKey:@"sign"];
    [NetworkingManager httpRequest:RTPost url:RUCheckAvail parameters:dictionary progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        long int status=[[responseObject objectForKey:@"status"]integerValue];
        if (status==0)
        {
            success(NO);
        }
        else
            success(YES);
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        failure([NSString stringWithFormat:@"%@",error]);
    } completionHandler:nil];
}

@end
