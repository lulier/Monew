//
//  SampleQueueId.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/5.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SampleQueueId : NSObject
@property (readwrite) int count;
@property (readwrite) NSURL* url;

-(id) initWithUrl:(NSURL*)url andCount:(int)count;

@end
