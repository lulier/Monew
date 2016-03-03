//
//  LyricItem.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/4.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LyricItem : NSObject
@property(nonatomic)NSInteger beginTime;
@property(nonatomic)NSInteger endTime;
@property(nonatomic,strong)NSString *lyricBody;
@property(nonatomic,strong)NSArray *lyricWords;
+(NSArray*)parseLyric:(NSString*)filePath;
-(instancetype)initWithAttributes:(NSDictionary *)attributes;
@end
