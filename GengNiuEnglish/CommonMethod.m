//
//  CommonMethod.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "CommonMethod.h"
#import "NSData+NSData_AES.h"
#import "NetworkingManager.h"


@implementation CommonMethod

//传入参数格式: number of value_key,value,key,value,key...
+(NSMutableDictionary*)packParamsInDictionary:(id)params, ...
{
    NSMutableDictionary* myDic = [[NSMutableDictionary alloc]init];
    id value;
    NSString* key = [[NSString alloc]init];
    va_list dicList;
    value = params;
    if (value) {
        va_start(dicList, params);
        while (value) {
            key = va_arg(dicList, id);
            [myDic setValue:value forKey:key];
            value = va_arg(dicList, id);
        }
        va_end(dicList);
    }
    
    return myDic;
}

+(NSString*)randomStringWithLength:(int)length
{
    NSString* result =[[NSString alloc ]init];
    for (int i = 0; i < length; i++) {
        int temp1 = arc4random()%2;
        int temp2 = arc4random()%36;
        if (temp2>9) {
            if (temp1 <1) {
                char c = 'A'+temp2-10;
                NSString* temp3 = [[NSString alloc]initWithFormat:@"%c",c];
                result = [result stringByAppendingString:temp3];
            }
            else
            {
                char c = 'a'+temp2-10;
                NSString* temp3 = [[NSString alloc]initWithFormat:@"%c",c];
                result = [result stringByAppendingString:temp3];
            }
        }
        else
        {
            char c = '0'+temp2;
            NSString* temp3 = [[NSString alloc]initWithFormat:@"%c",c];
            result = [result stringByAppendingString:temp3];
        }
        
    }
    return result;
}

+(NSMutableString*)MD5EncryptionWithString:(NSString *)str
{
    const char *cstr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstr, (unsigned int)strlen(cstr), result);
    NSMutableString *md5_str = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [md5_str appendFormat:@"%02x", result[i]];
//    NSLog(@"MD5: %@",md5_str);
    return md5_str;
    
}
+(BOOL)isEmailValid:(NSString *)email
{
    if (email == nil || [email length]== 0)
        return NO;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
+ (BOOL)isPhoneNumberVaild:(NSString *)phoneNumber
{
    if (phoneNumber == nil || [phoneNumber length]== 0)
        return NO;
    NSString *rule = @"^1(3|5|7|8|4)\\d{9}";
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule];
    BOOL isMatch = [pred evaluateWithObject:phoneNumber];
    return isMatch;
}
+(float)calculateTextHeight:(NSString*)text width:(float)width fontSize:(float)fsize
{
    float height = 0;
    UIFont *font = [UIFont systemFontOfSize:fsize];
    CGSize size = CGSizeMake(width,FLT_MAX);
    CGRect labelRect = [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)  attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil];
    height = ceil(labelRect.size.height);
    return height;
}











+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//获取当前屏幕显示的viewcontroller
+(UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
+(NSString *)getPath:(NSString *)fileName
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths objectAtIndex:0];
    NSString *filePath=[doctPath stringByAppendingPathComponent:fileName];
    return filePath;
}
#pragma mark - AES加密
//将string转成带密码的data
+(NSData*)encryptAESData:(NSString*)string app_key:(NSString*)key
{
    //将nsstring转化为nsdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"log for data:%@",data);
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES128EncryptWithKey:key];
    //    NSString *result=[[NSString alloc]initWithData:encryptedData encoding:NSUTF8StringEncoding];
//    NSLog(@"加密后的字符串 :%@",encryptedData);
    
    return encryptedData;
}

#pragma mark - AES解密
//将带密码的data转成string
+(NSString*)decryptAESData:(NSData*)data  app_key:(NSString*)key
{
    //test for encode
    NSString* filePath=[CommonMethod getPath:@"3.cipher"];
//    NSLog(@"log for path:%@",filePath);
    BOOL is=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
//    NSString *content=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    NSData *result=[CommonMethod encryptAESData:content app_key:key];
//    [result writeToFile:[CommonMethod getPath:@"test.lrc"] atomically:YES];
    
//    NSData *test=[NSData dataWithContentsOfFile:filePath];

    
    
    
    //使用密码对data进行解密
    NSData *decryData = [data AES128DecryptWithKey:key];
    //将解了密码的nsdata转化为nsstring
    NSString *str = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    NSLog(@"解密后的字符串 :%@",str);
    return str;
}
+(IphoneType)checkIphoneType
{
    CGFloat height=[UIScreen mainScreen].bounds.size.height;
    CGFloat width=[UIScreen mainScreen].bounds.size.width;
    if ((height==320.0f&&width==568.0f)||(height==568.0f&&width==320.0f))
    {
        return Iphone5s;
    }
    if ((height==375.0f&&width==667.0f)||(height==667.0f&&width==375.0f))
    {
        return Iphone6;
    }
    if ((height==414.0f&&width==736.0f)||(height==736.0f&&width==414.0f))
    {
        return Iphone6p;
    }
    return IphoneDefault;
}
+ (void)checkNetwork:(void (^)( NSURLSessionTask *  task, id responseObject))success
{
    NSMutableString *sign=[CommonMethod MD5EncryptionWithString:@"15521223112"];
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:@"15521223112",@"phone",sign,@"sign", nil];
    [NetworkingManager httpRequest:RTPost url:RUCheckAvail parameters:dic progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        success(task,responseObject);
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        
    } completionHandler:nil];
}
+(BOOL)checkFileExistence:(NSString*)path
{
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir])
    {
        return YES;
    }
    else
        return NO;
}

+(BOOL)isTheSameDay:(NSString *)firstTimeStamp secondTimeStamp:(NSString *)secondTimeStamp
{
    NSDate *time1=[NSDate dateWithTimeIntervalSince1970:[firstTimeStamp integerValue]];
    NSDate *time2=[NSDate dateWithTimeIntervalSince1970:[secondTimeStamp integerValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *timeString1 = [dateFormatter stringFromDate:time1];
    NSString *timeString2=[dateFormatter stringFromDate:time2];
    if ([timeString1 isEqualToString:timeString2])
    {
        return true;
    }
    else
        return false;
}
+(NSInteger)getTimeStamp
{
    NSDate *date=[NSDate date];
//    NSTimeZone *zone=[NSTimeZone systemTimeZone];
//    date=[date dateByAddingTimeInterval:[zone secondsFromGMTForDate:date]];
    double currentTime=[date timeIntervalSince1970];
    NSUInteger timeStamp=(int)currentTime;
    return timeStamp;
}


@end
