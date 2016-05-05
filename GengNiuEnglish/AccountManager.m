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
@synthesize gender;
@synthesize nickName;
@synthesize portraitKey;
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
        
        gender=[[aDecoder decodeObjectForKey:@"gender"] integerValue];
        nickName=[aDecoder decodeObjectForKey:@"nickName"];
        portraitKey=[aDecoder decodeObjectForKey:@"portraitKey"];
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
    
    [aCoder encodeObject:@(self.type) forKey:@"gender"];
    [aCoder encodeObject:self.nickName forKey:@"nickName"];
    [aCoder encodeObject:self.portraitKey forKey:@"portraitKey"];
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
    
    self.gender=accountManager.gender;
    self.nickName=accountManager.nickName;
    self.portraitKey=accountManager.portraitKey;
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
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:loginType,@"type",accountNum,@"account",md5_str,@"passwd",@"0",@"channel",sign,@"sign",nil];
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
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:reType,@"type",accountNum,@"account",md5_str,@"passwd",salt,@"salt",@"0",@"channel",sign,@"sign",nil];
    [NetworkingManager httpRequest:RTPost url:RURegist parameters:dict progress:nil success:success failure:failure completionHandler:nil];
}

-(void)bindPhone:(NSString*)phone bind:(BOOL)bind password:(NSString*)password success:(void (^)(BOOL bindSuccess))success failure:(void (^)(NSString * message))failure;
{
    NSInteger bindSign=0;
    if (bind)
    {
        bindSign=1;
    }
    NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@%ld",self.userID,phone,(long)bindSign]];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:self.userID,@"user_id",phone,@"phone",[NSString stringWithFormat:@"%ld",(long)bindSign],@"bind",sign,@"sign",nil];
    [NetworkingManager httpRequest:RTPost url:RUCheckAvail parameters:dict progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        long int status=[[responseObject objectForKey:@"status"]integerValue];
        if (status==0)
        {
            success(YES);
        }
        else
            success(NO);
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        failure([NSString stringWithFormat:@"%@",error]);
    } completionHandler:nil];
}



-(void)createTable
{
    NSString *dbPath=[CommonMethod getPath:[NSString stringWithFormat:@"%@/%@",MONEWFOLDER,self.userID]];
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath isDirectory:&isDir])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"AccountInfo" indexesWithProperties:@[@"user_id  INTEGER PRIMARY KEY UNIQUE",@"account varchar(255)",@"password varchar(512)",@"type integer",@"login_time varchar(255)"]];
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"UserInfo" indexesWithProperties:@[@"user_id  INTEGER PRIMARY KEY UNIQUE",@"gender INTEGER",@"nickname varchar(64)",@"portrait_key varchar(255)",@"extra varchar(255)"]];
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"GradeList" indexesWithProperties:@[@"grade_id  INTEGER PRIMARY KEY UNIQUE",@"grade_name varchar(255)",@"cover_url varchar(512)",@"text_count integer"]];
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"TextList" indexesWithProperties:@[@"text_id  INTEGER PRIMARY KEY UNIQUE",@"grade_id  INTEGER",@"text_name varchar(255)",@"cover_url varchar(512)",@"courseware_url varchar(512)",@"desc varchar(255)",@"challenge_goal integer",@"challenge_score integer",@"listen_count integer",@"practise_goal integer",@"star_count integer",@"listen_goal integer",@"practise_count integer",@"version integer"]];
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"Vocabulary" indexesWithProperties:@[@"word varchar(64) PRIMARY KEY UNIQUE",@"extra varchar(64)"]];
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"SentenceScore" indexesWithProperties:@[@"sentence_id  varchar(64) PRIMARY KEY UNIQUE",@"text_id INTEGER",@"record_path varchar(255)",@"score INTEGER",@"extra varchar(64)"]];
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"StudyData" indexesWithProperties:@[@"time_stamp  varchar(64) PRIMARY KEY UNIQUE",@"text_id INTEGER",@"user_id INTEGER",@"star_count INTEGER",@"listen_count INTEGER",@"practice_count INTEGER",@"challenge_score INTEGER",@"push_to_server INTEGER",@"extra varchar(64)"]];
}
-(void)saveAccount
{
    [self createTable];
    NSArray *colums=[[NSArray alloc]initWithObjects:@"user_id",@"account",@"password",@"type",@"login_time", nil];
    NSArray *values=[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"'%@'",self.userID],[NSString stringWithFormat:@"'%@'",self.account],[NSString stringWithFormat:@"'%@'",self.password],[NSString stringWithFormat:@"%lu",(unsigned long)self.type],[NSString stringWithFormat:@"'%@'",self.loginTime], nil];
    [[MTDatabaseHelper sharedInstance] insertToTable:@"AccountInfo" withColumns:colums andValues:values];
    [[NSUserDefaults standardUserDefaults] setObject:@"in" forKey:@"AccountStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [FXKeychain defaultKeychain][ACCOUNT_KEYCHAIN] = self;
    
    [self getUserInfo];
}
-(void)getUserInfo
{
    NSMutableString *sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@",self.userID]];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:self.userID,@"user_id",sign,@"sign",nil];
    __weak __typeof(self)weakself=self;
    [NetworkingManager httpRequest:RTPost url:RUUserInfo parameters:dict progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        long int status=[[responseObject objectForKey:@"status"] integerValue];
        if (status==0)
        {
            if ([[responseObject objectForKey:@"gender"] integerValue]==0)
            {
                weakself.gender=UGBoy;
            }
            else
                weakself.gender=UGGirl;
            weakself.nickName=[responseObject objectForKey:@"nickname"];
            weakself.portraitKey=[responseObject objectForKey:@"avatar"];
            NSArray *colums=[[NSArray alloc]initWithObjects:@"user_id",@"gender",@"nickname",@"portrait_key", nil];
            NSArray *values=[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"'%@'",weakself.userID],[NSString stringWithFormat:@"%ld",weakself.gender],[NSString stringWithFormat:@"'%@'",weakself.nickName],[NSString stringWithFormat:@"'%@'",weakself.portraitKey], nil];
            [[MTDatabaseHelper sharedInstance] insertToTable:@"UserInfo" withColumns:colums andValues:values];
            [FXKeychain defaultKeychain][ACCOUNT_KEYCHAIN] = self;
        }
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        
    } completionHandler:nil];
}
- (void)deleteAccount {
    userID = nil;
    account = nil;
    password = nil;
    openID = nil;
    completeInfo = NO;
    isActive = NO;
    type = 0;
    
    gender=0;
    nickName=nil;
    portraitKey=nil;
    
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
        [SMSSDK registerApp:appKey withSecret:appSecret];
        long int status=[[responseObject objectForKey:@"status"]integerValue];
        if (status==0)
        {
            long int available =[[responseObject objectForKey:@"available"] integerValue];
            if (available==1)
            {
                success(NO);
            }
            else
                success(YES);
        }
        else
            success(YES);
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        failure([NSString stringWithFormat:@"%@",error]);
    } completionHandler:nil];
}

-(void)uploadUserInfo
{
    NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@%ld%@",self.userID,self.nickName,(long)self.gender,self.portraitKey]];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:self.userID,@"user_id",self.nickName,@"nickname",[NSString stringWithFormat:@"%ld",(long)self.gender],@"gender",self.portraitKey,@"avatar",sign,@"sign",nil];
    [NetworkingManager httpRequest:RTPost url:RUSetUserInfo parameters:dict progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        long int status=[[responseObject objectForKey:@"status"]integerValue];
        if (status==0)
        {
            
        }
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        
    } completionHandler:nil];
}
- (void)resetPassword:(NSDictionary*)parameters success:(void (^)(BOOL resetSuccess))success failure:(void (^)(NSString * message))failure
{
    NSString *oldPassword=[parameters objectForKey:@"oldPassword"];
    NSString *newPassword=[parameters objectForKey:@"newPassword"];
    NSMutableString* sign=[CommonMethod MD5EncryptionWithString:self.account];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:self.account,@"account",sign,@"sign", nil];
    
    [NetworkingManager httpRequest:RTPost url:RUGetSalt parameters:dict progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        
        long int status=[[responseObject objectForKey:@"status"]integerValue];
        NSString* salt;
        if (status==0)
        {
            salt=[responseObject objectForKey:@"salt"];
            NSMutableString* oldP = [CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@",oldPassword,salt]];
            NSMutableString* newP = [CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@",newPassword,salt]];
            NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@%@",newP,oldP,self.userID]];
            NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:self.userID,@"user_id",oldP,@"old_passwd",newP,@"new_passwd",sign,@"sign",nil];
            [NetworkingManager httpRequest:RTPost url:RUResetPassword parameters:dic progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
                long int status=[[responseObject objectForKey:@"status"]integerValue];
                if (status==0)
                {
                    self.password=newP;
                    [self saveAccount];
                    success(YES);
                }
                else
                    success(NO);
            } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
                failure([NSString stringWithFormat:@"%@",error]);
            } completionHandler:nil];
            
        }
        else
            success(NO);
        
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        failure([NSString stringWithFormat:@"%@",error]);
    } completionHandler:nil];
}
-(void)checkWeixinBind:(void (^)(BOOL bind))success failure:(void (^)(NSString * message))failure
{
    
    NSMutableString *sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@",self.userID]];
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:self.userID,@"user_id",sign,@"sign",nil];
    [NetworkingManager httpRequest:RTPost url:RUWeixinBind parameters:dic progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        long int status=[[responseObject objectForKey:@"status"]integerValue];
        if (status==0)
        {
            long int available=[[responseObject objectForKey:@"available"] integerValue];
            if (available==1)
            {
                success(YES);
            }
            else
                success(NO);
        }
        else
            success(NO);
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        success(NO);
    } completionHandler:nil];
}
@end
