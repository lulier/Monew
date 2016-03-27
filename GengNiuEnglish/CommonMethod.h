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
@protocol dismissDelegate <NSObject>

-(void)dismissView;

@end
typedef NS_ENUM(NSInteger,IphoneType)
{
    Iphone5s=0,
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
