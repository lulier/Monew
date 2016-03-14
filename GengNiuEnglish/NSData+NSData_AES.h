//
//  NSData+NSData_AES.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/12.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSString;
@interface NSData (NSData_AES)

- (NSData *)AES128EncryptWithKey:(NSString *)key;   //加密
- (NSData *)AES128DecryptWithKey:(NSString *)key;   //解密

@end