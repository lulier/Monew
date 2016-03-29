//
//  LyricItem.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/4.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "LyricItem.h"
#define CIPHER_KEY @"24BF8C08A00AFA00"
#import "CommonMethod.h"

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
    self.lyricWords=[LyricItem extractWords:self.lyricBody];
    self.stars=0;
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
    return [NSString stringWithFormat:@"%lu",(unsigned long)ms];
}
+(NSArray *)parseLyric:(NSString *)filePath
{
    NSMutableArray *lyrics=[[NSMutableArray alloc]init];
    NSData *secretText=[NSData dataWithContentsOfFile:filePath];
    NSString *result=[CommonMethod decryptAESData:secretText app_key:CIPHER_KEY];
    if (result==nil)
    {
        return nil;
    }
    NSString *tmp=[result stringByReplacingOccurrencesOfString:@"[ENDASH]" withString:@"–"];
    NSString *content=[tmp stringByReplacingOccurrencesOfString:@"[EMDASH]" withString:@"—"];
    NSArray *contents=[content componentsSeparatedByString:@"\n"];
    for (int i=0; i<[contents count]-1; i++)
    {
        NSArray *current=[contents[i] componentsSeparatedByString:@"]"];
        NSArray *next=[contents[i+1] componentsSeparatedByString:@"]"];
        NSString* beginTime=[LyricItem parseToMillisecond:current[0]];
        NSString* endTime=[LyricItem parseToMillisecond:next[0]];
        NSDictionary *attribute=[NSDictionary dictionaryWithObjectsAndKeys:beginTime,@"beginTime",endTime,@"endTime",current[1],@"lyricBody",nil];
        LyricItem *item=[[LyricItem alloc]initWithAttributes:attribute];
        [lyrics addObject:item];
    }
    return lyrics;
}
+(BOOL)isCharacter:(char)letter
{
    if ((letter-'a'>=0&&letter-'a'<26)||(letter-'A'>=0&&letter-'A'<26)||letter=='\''||(letter-'0'>=0&&letter-'0'<=9))
    {
        return YES;
    }
    return NO;
}
+(NSArray *)extractWords:(NSString*)sentence
{
    NSMutableArray *words=[[NSMutableArray alloc]init];
    NSInteger len=[sentence length];
    NSInteger start=0;
    NSInteger end=0;
    while (start<len&&end<len)
    {
        while (start<len&&(![LyricItem isCharacter:[sentence characterAtIndex:start]]))
        {
            start++;
        }
        end=start+1;
        while (end<len&&[LyricItem isCharacter:[sentence characterAtIndex:end]])
        {
            end++;
        }
        if (end<len) {
            [words addObject:[sentence substringWithRange:NSMakeRange(start, end-start)]];
            start=end+1;
        }
    }
    return words;
}
@end
