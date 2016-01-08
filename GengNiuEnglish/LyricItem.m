//
//  LyricItem.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/4.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "LyricItem.h"

@implementation LyricItem
-(instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self=[super init];
    if (!self)
    {
        return nil;
    }
    self.beginTime=[[attributes objectForKey:@"beginTime"] integerValue];
    self.endTime=[[attributes objectForKey:@"endTime"] integerValue];
    self.lyricBody=[attributes objectForKey:@"lyricBody"];
    return self;
}
+(NSString*)parseToMillisecond:(NSString*)time
{
    NSArray *timeData=[[[time stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@":"] componentsSeparatedByString:@":"];
    NSInteger minute=[timeData[0] integerValue];
    NSInteger second=[timeData[1] integerValue];
    NSInteger ms=[timeData[2] integerValue];
    ms=ms<100?ms*10:ms;
    ms=minute*60*1000+second*1000+ms;
    return [NSString stringWithFormat:@"%ld",ms];
}
+(NSArray *)parseLyric:(NSString *)filePath
{
    NSMutableArray *lyrics=[[NSMutableArray alloc]init];
    NSString *content=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *contents=[content componentsSeparatedByString:@"\n"];
    for (int i=0; i<[contents count]-1; i++)
    {
        NSArray *current=[contents[i] componentsSeparatedByString:@"]"];
        NSArray *next=[contents[i+1] componentsSeparatedByString:@"]"];
        NSString* beginTime=[LyricItem parseToMillisecond:current[0]];
        NSString* endTime=[LyricItem parseToMillisecond:next[0]];
        NSDictionary *attribute=[NSDictionary dictionaryWithObjectsAndKeys:beginTime,@"beginTime",endTime,@"endTime",current[1],@"lyricBody", nil];
        LyricItem *item=[[LyricItem alloc]initWithAttributes:attribute];
        [lyrics addObject:item];
    }
    return lyrics;
}
@end
