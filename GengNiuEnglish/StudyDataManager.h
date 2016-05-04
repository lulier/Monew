//
//  StudyDataManager.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/5/4.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTDatabaseHelper.h"

@interface StudyDataManager : NSObject
@property(nonatomic,strong)NSArray *sentenceScores;
+(StudyDataManager*) sharedInstance;
-(NSDictionary*)getSentenceScore:(NSString*)sentenceID;
-(void)loadSentenceScores:(NSString *)textID;
-(void)updateSentenceScore:(NSString *)sentenceID recordPath:(NSString*)recordPath score:(NSString*)score textID:(NSString*)textID;
-(void)prepareUploadStudyState:(NSString*)userID textID:(NSString*)textID starCount:(NSString*)starCount listenCount:(NSString*)listenCount practiceCount:(NSString *)practiceCount challengeScore:(NSString*)challengeScore;
@end
