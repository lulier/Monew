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

-(void)prepareUploadStudyState:(NSString*)userID textID:(NSString*)textID starCount:(NSString*)starCount listenCount:(NSString*)listenCount practiceCount:(NSString *)practiceCount challengeScore:(NSString*)challengeScore
{
    [[MTDatabaseHelper sharedInstance] queryTable:@"StudyData" withSelect:@[@"*"] andWhere:nil completion:^(NSMutableArray *resultsArray) {
        NSInteger starC=[starCount integerValue];
        NSInteger listenC=[listenCount integerValue];
        NSInteger practiceC=[practiceCount integerValue];
        NSInteger challengeS=[challengeScore integerValue];
        for (NSDictionary *tmp in resultsArray)
        {
            NSString *push=[tmp objectForKey:@"push_to_server"];
            if ([push integerValue]==0)
            {
                starC+=[[tmp objectForKey:@"star_count"] integerValue];
                listenC+=[[tmp objectForKey:@"listen_count"] integerValue];
                practiceC+=[[tmp objectForKey:@"practice_count"] integerValue];
                if (challengeS<[[tmp objectForKey:@"challenge_score"]integerValue])
                {
                    challengeS=[[tmp objectForKey:@"challenge_score"] integerValue];
                }
            }
        }
        
        [self uploadStudyState:userID textID:textID starCount:[NSString stringWithFormat:@"%ld",starC] listenCount:[NSString stringWithFormat:@"%ld",listenC] practiceCount:[NSString stringWithFormat:@"%ld",practiceC] challengeScore:[NSString stringWithFormat:@"%ld",challengeS]];
        
    }];
}

-(void)uploadStudyState:(NSString*)userID textID:(NSString*)textID starCount:(NSString*)starCount listenCount:(NSString*)listenCount practiceCount:(NSString *)practiceCount challengeScore:(NSString*)challengeScore
{
    NSDate *date=[NSDate date];
    double currentTime=[date timeIntervalSince1970];
    NSUInteger timeStamp=(int)currentTime;
    NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@%@%@%@%ld%@",challengeScore,listenCount,practiceCount,starCount,textID,timeStamp,userID]];
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:challengeScore,@"challenge_score",listenCount,@"listen_count",practiceCount,@"practice_count",starCount,@"star_count",textID,@"text_id",[NSString stringWithFormat:@"%ld",timeStamp],@"update_date", sign,@"sign",nil];
    [NetworkingManager httpRequest:RTPost url:RUUpdateState parameters:parameters progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        //update database
        long int status=[[responseObject objectForKey:@"status"] integerValue];
        if (status==0)
        {
            [self updateStudyState:userID textID:textID starCount:starCount listenCount:listenCount practiceCount:practiceCount challengeScore:challengeScore pushToServer:YES timeStamp:timeStamp];
        }
        else
            [self updateStudyState:userID textID:textID starCount:starCount listenCount:listenCount practiceCount:practiceCount challengeScore:challengeScore pushToServer:NO timeStamp:timeStamp];
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        //update database
        [self updateStudyState:userID textID:textID starCount:starCount listenCount:listenCount practiceCount:practiceCount challengeScore:challengeScore pushToServer:NO timeStamp:timeStamp];
    } completionHandler:nil];
}


-(void)updateStudyState:(NSString*)userID textID:(NSString*)textID starCount:(NSString*)starCount listenCount:(NSString*)listenCount practiceCount:(NSString *)practiceCount challengeScore:(NSString*)challengeScore pushToServer:(BOOL)pushToServer timeStamp:(NSInteger)timeStamp
{
    NSInteger inServer=0;
    if (pushToServer)
    {
        inServer=1;
    }
    //update
    NSArray *colums=[[NSArray alloc]initWithObjects:@"time_stamp",@"text_id",@"user_id",@"star_count",@"listen_count",@"practice_count",@"challenge_score",@"push_to_server",nil];
    NSArray *values=[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"'%ld'",timeStamp],[NSString stringWithFormat:@"'%@'",textID],[NSString stringWithFormat:@"'%@'",userID],[NSString stringWithFormat:@"'%@'",starCount],[NSString stringWithFormat:@"'%@'",listenCount],[NSString stringWithFormat:@"'%@'",practiceCount],[NSString stringWithFormat:@"'%@'",challengeScore],[NSString stringWithFormat:@"'%ld'",inServer], nil];
    [[MTDatabaseHelper sharedInstance] insertToTable:@"StudyData" withColumns:colums andValues:values];
}

@end
