//
//  CommonMethod.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>
#import "Reachability.h"
#import <SMS_SDK/SMSSDK.h>

#define CIPHER_KEY @"24BF8C08A00AFA00"
#define IPHONE6TOIPHONE5S 0.85
#define IPHONE6TOIPHONE6S 1.104

static NSString* const appKey=@"1041a2bf48e78";
static NSString* const appSecret=@"2c2ca1b896f428d3d258743bf50076d9";
@protocol dismissDelegate <NSObject>

-(void)dismissView;

@end
typedef NS_ENUM(NSInteger,IphoneType)
{
    IphoneDefault=0,
    Iphone5s,
    Iphone6,
    Iphone6p,
    Ipad
};
@interface CommonMethod : NSObject
//打包一个dictionary.传入参数格式: value,key,value,key...
+(NSMutableDictionary*)packParamsInDictionary:(id) params,...;
//生成随机字符串，包括数字和大小写的字母
+(NSString*)randomStringWithLength:(int)length;
//对str字符串进行md5加密
+(NSMutableString*)MD5EncryptionWithString:(NSString*)str;
+(BOOL)isEmailValid:(NSString *)email;
+ (BOOL)isPhoneNumberVaild:(NSString *)phoneNumber;
+(float)calculateTextHeight:(NSString*)text width:(float)width fontSize:(float)fsize;
+ (void)checkNetwork:(void (^)( NSURLSessionTask *  task, id responseObject))success;


#pragma mark - AES加密
//将string转成带密码的data
+ (NSData*)encryptAESData:(NSString*)string app_key:(NSString*)key;
//将带密码的data转成string
+(NSString*)decryptAESData:(NSData*)data app_key:(NSString*)key;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+(UIViewController*)getCurrentVC;
+(NSString*)getPath:(NSString*)fileName;
+(IphoneType)checkIphoneType;
+(BOOL)checkFileExistence:(NSString*)path;
@end
