//
//  StudyDataManager.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/5/4.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "StudyDataManager.h"

static StudyDataManager *singleInstance = nil;

@implementation StudyDataManager

-(id) init
{
    self = [super init];
    if(self){
        
    }
    return self;
}

+(StudyDataManager*) sharedInstance
{
    if(singleInstance == nil)
        singleInstance = [[self alloc] init];
    return singleInstance;
}

-(void)loadSentenceScores:(NSString *)textID
{
    [[MTDatabaseHelper sharedInstance] queryTable:@"SentenceScore" withSelect:@[@"*"] andWhere:[NSDictionary dictionaryWithObjectsAndKeys:textID,@"text_id",nil] completion:^(NSMutableArray *resultsArray) {
        self.sentenceScores=resultsArray;
    }];
}
-(NSDictionary*)getSentenceScore:(NSString*)sentenceID
{
    NSDictionary *sentenceScore=nil;
    if (self.sentenceScores==nil)
    {
        return nil;
    }
    for (NSDictionary *tmp in self.sentenceScores)
    {
        if ([[tmp objectForKey:@"sentence_id"] isEqualToString:sentenceID])
        {
            sentenceScore=tmp;
        }
    }
    return sentenceScore;
}

-(void)updateSentenceScore:(NSString *)sentenceID recordPath:(NSString*)recordPath score:(NSString*)score textID:(NSString*)textID
{
    NSArray *colums=[[NSArray alloc]initWithObjects:@"sentence_id",@"record_path",@"score",@"text_id", nil];
    NSArray *values=[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"'%@'",sentenceID],[NSString stringWithFormat:@"'%@'",recordPath],[NSString stringWithFormat:@"'%@'",score],[NSString stringWithFormat:@"'%@'",textID], nil];
    
    [[MTDatabaseHelper sharedInstance] insertToTable:@"SentenceScore" withColumns:colums andValues:values];
}

-(void)prepareUploadStudyState:(NSString*)userID textID:(NSString*)textID starCount:(NSString*)starCount readCount:(NSString*)readCount sentenceCount:(NSString*)sentenceCount listenCount:(NSString*)listenCount challengeScore:(NSString*)challengeScore
{
    
    //load database for not push and sort by day
    NSUInteger timeStamp=[CommonMethod getTimeStamp];
    NSDictionary *current=[NSDictionary dictionaryWithObjectsAndKeys:userID,@"user_id",textID,@"text_id",starCount,@"star_count",readCount,@"read_count",sentenceCount,@"sentence_count",listenCount,@"listen_count",challengeScore,@"challenge_score",[NSString stringWithFormat:@"%ld",timeStamp],@"time_stamp",@"0",@"push_to_server",nil];
    [[MTDatabaseHelper sharedInstance] queryTable:@"StudyData" withSelect:@[@"*"] andWhere:nil completion:^(NSMutableArray *resultsArray) {
        
        [resultsArray addObject:current];
        for (NSDictionary *tmp in resultsArray)
        {
            NSString *push=[tmp objectForKey:@"push_to_server"];
            if ([push integerValue]==0)
            {
                NSInteger starC=[[tmp objectForKey:@"star_count"] integerValue];
                NSInteger readC=[[tmp objectForKey:@"read_count"] integerValue];
                NSInteger listenC=[[tmp objectForKey:@"listen_count"] integerValue];
                NSInteger sentenceC=[[tmp objectForKey:@"sentence_count"] integerValue];
                NSInteger challengeS=[[tmp objectForKey:@"challenge_score"] integerValue];
                NSString *text_id=[tmp objectForKey:@"text_id"];
                NSInteger timeS=[[tmp objectForKey:@"time_stamp"] integerValue];
                [self uploadStudyState:userID textID:text_id starCount:[NSString stringWithFormat:@"%ld",(long)starC] readCount:[NSString stringWithFormat:@"%ld",(long)readC] sentenceCount:[NSString stringWithFormat:@"%ld",(long)sentenceC] listenCount:[NSString stringWithFormat:@"%ld",(long)listenC] challengeScore:[NSString stringWithFormat:@"%ld",(long)challengeS] timeStamp:timeS];
                //update the database for addone
            }
            
        }
    }];
}

-(void)uploadStudyState:(NSString*)userID textID:(NSString*)textID starCount:(NSString*)starCount readCount:(NSString*)readCount sentenceCount:(NSString*)sentenceCount listenCount:(NSString*)listenCount challengeScore:(NSString*)challengeScore timeStamp:(NSInteger)timeStamp
{
    
    NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%ld%@",challengeScore,listenCount,readCount,sentenceCount,starCount,textID,(unsigned long)timeStamp,userID]];
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:challengeScore,@"challenge_score",listenCount,@"listen_count",readCount,@"read_count",sentenceCount,@"repeat_sentence_count",starCount,@"star_count",textID,@"text_id",[NSString stringWithFormat:@"%ld",(unsigned long)timeStamp],@"update_date",userID,@"user_id", sign,@"sign",nil];
    [NetworkingManager httpRequest:RTPost url:RUUpdateState parameters:parameters progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        //update database
        long int status=[[responseObject objectForKey:@"status"] integerValue];
        if (status==0)
        {
            [self updateStudyState:userID textID:textID starCount:starCount readCount:readCount listenCount:listenCount sentenceCount:sentenceCount challengeScore:challengeScore pushToServer:YES timeStamp:timeStamp];
        }
        else
            [self updateStudyState:userID textID:textID starCount:starCount readCount:readCount listenCount:listenCount sentenceCount:sentenceCount challengeScore:challengeScore pushToServer:NO timeStamp:timeStamp];
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        //update database
        [self updateStudyState:userID textID:textID starCount:starCount readCount:readCount listenCount:listenCount sentenceCount:sentenceCount challengeScore:challengeScore pushToServer:NO timeStamp:timeStamp];
    } completionHandler:nil];
}


-(void)updateStudyState:(NSString*)userID textID:(NSString*)textID starCount:(NSString*)starCount readCount:(NSString*)readCount listenCount:(NSString*)listenCount sentenceCount:(NSString *)sentenceCount challengeScore:(NSString*)challengeScore pushToServer:(BOOL)pushToServer timeStamp:(NSInteger)timeStamp
{
    NSInteger inServer=0;
    if (pushToServer)
    {
        inServer=1;
    }
    //update
    NSArray *colums=[[NSArray alloc]initWithObjects:@"time_stamp",@"text_id",@"user_id",@"star_count",@"read_count",@"listen_count",@"sentence_count",@"challenge_score",@"push_to_server",nil];
    NSArray *values=[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"'%ld'",(long)timeStamp],[NSString stringWithFormat:@"'%@'",textID],[NSString stringWithFormat:@"'%@'",userID],[NSString stringWithFormat:@"'%@'",starCount],[NSString stringWithFormat:@"'%@'",readCount],[NSString stringWithFormat:@"'%@'",listenCount],[NSString stringWithFormat:@"'%@'",sentenceCount],[NSString stringWithFormat:@"'%@'",challengeScore],[NSString stringWithFormat:@"'%ld'",(long)inServer], nil];
    [[MTDatabaseHelper sharedInstance] insertToTable:@"StudyData" withColumns:colums andValues:values];
}

@end
