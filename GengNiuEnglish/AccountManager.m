//
//  AccountManager.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/8.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "AccountManager.h"

@implementation AccountManager
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
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:loginType,@"type",accountNum,@"account",md5_str,@"passwd",sign,@"sign",nil];
            [NetworkingManager httpRequest:RTPost url:RULogin parameters:dict progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
                NSLog(@"log for login response:%@",responseObject);
            } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
                
            } completionHandler:nil];
        }
        
        
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        
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
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:reType,@"type",accountNum,@"account",md5_str,@"passwd",salt,@"salt",sign,@"sign",nil];
    [NetworkingManager httpRequest:RTPost url:RURegist parameters:dict progress:nil success:success failure:failure completionHandler:nil];
}
@end
