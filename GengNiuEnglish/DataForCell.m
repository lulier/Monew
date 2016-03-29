//
//  DataForCell.m
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/21.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import "DataForCell.h"
#import "NetworkingManager.h"
#import "ReaderDocument.h"
#import "ReaderViewController.h"
#import "FMDB.h"
#import "MTDatabaseHelper.h"
#import "CommonMethod.h"
#import "MRProgress.h"

@implementation DataForCell
{
    ReaderViewController *readerViewController;
}

-(instancetype)initWithAttributes:(NSDictionary *)attributes
{
    
    self=[super init];
    if (!self) {
        return nil;
    }
    if ([attributes objectForKey:@"text_id"]!=nil)
    {
        self.text_id=[attributes objectForKey:@"text_id"];
        self.text_name=[attributes objectForKey:@"text_name"];
        self.cover_url=[attributes objectForKey:@"cover_url"];
        self.category=[attributes objectForKey:@"category"];
        self.downloadURL=[attributes objectForKey:@"courseware_url"];
        self.zipFileName=[[[[self.downloadURL componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"?"] objectAtIndex:0];
        self.fileNames=[[NSMutableArray alloc]init];
        self.text_gradeID=[attributes objectForKey:@"grade_id"];
        self.progressView=nil;
        [self checkDatabase];
    }
    else
    {
        self.text_id=[attributes objectForKey:@"grade_id"];
        self.text_name=[attributes objectForKey:@"grade_name"];
        self.cover_url=[attributes objectForKey:@"cover_url"];
        self.text_count=[attributes objectForKey:@"text_count"];
        self.category=nil;
        self.fileNames=nil;
        self.downloadURL=nil;
        self.zipFileName=nil;
        self.progressView=nil;
    }
    self.task=nil;
    return self;
    
}
+(NSURLSessionTask*)getGradeList:(void (^)(NSArray *, NSError *))block{
    NSString *userID=[AccountManager singleInstance].userID;
    NSDictionary *parameters=[[NSDictionary alloc]initWithObjectsAndKeys:userID,@"user_id", nil];
    NSMutableArray *mutableBooks=[[NSMutableArray alloc]init];
    return [NetworkingManager httpRequest:RTGet url:RUGrade_list parameters:parameters progress:nil
    success:^(NSURLSessionTask *task,id JSON)
            {
                NSArray *list=[JSON valueForKey:@"grade_list"];
                //在数据库中纪录grade_list
                [DataForCell recordGradeList:list];
                for (NSDictionary *attributes in list)
                {
                    DataForCell *data=[[DataForCell alloc]initWithAttributes:attributes];
                    [mutableBooks addObject:data];
                }
                if (block)
                {
                    block([NSArray arrayWithArray:mutableBooks],nil);
                }
            }
    failure:^(NSURLSessionTask *task,NSError* error)
            {
                if (block)
                {
                    block(nil,error);
                }
            }
            
    completionHandler:nil];
    
}
+(void)recordGradeList:(NSArray*)gradeList
{
    if (gradeList==nil)
    {
        return;
    }
    for (NSDictionary *arg in gradeList)
    {
        NSString *gradeID=[arg objectForKey:@"grade_id"];
        NSString *gradeName=[arg objectForKey:@"grade_name"];
        NSString *coverURL=[arg objectForKey:@"cover_url"];
        NSString *textCount=[arg objectForKey:@"text_count"];
        NSArray *colums=[[NSArray alloc]initWithObjects:@"grade_id",@"grade_name",@"cover_url",@"text_count", nil];
        NSArray *values=[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"'%@'",gradeID],[NSString stringWithFormat:@"'%@'",gradeName],[NSString stringWithFormat:@"'%@'",coverURL],[NSString stringWithFormat:@"'%@'",textCount], nil];
        [[MTDatabaseHelper sharedInstance] insertToTable:@"GradeList" withColumns:colums andValues:values];
    }
}
+(void)getTextList:(void (^)(NSArray *, NSError *))block grade_id:(NSString*)grade_id text_id:(NSString*)text_id{
    
    NSString *userID=[AccountManager singleInstance].userID;
    NSDictionary *parameters=[[NSDictionary alloc]initWithObjectsAndKeys:userID,@"user_id",grade_id,@"grade_id",text_id,@"text_id",nil];
    NSMutableArray *mutableBooks=[[NSMutableArray alloc]init];
    [NetworkingManager httpRequest:RTGet url:RUText_list parameters:parameters progress:nil
        success:^(NSURLSessionTask *task,id JSON)
            {
                NSArray *list=[JSON valueForKey:@"text_list"];
                //在数据库中纪录text_list
                [DataForCell recordTextList:list gradeID:grade_id];
                for (NSDictionary *tmp in list)
                {
                    NSMutableDictionary *attributes=[NSMutableDictionary dictionaryWithDictionary:tmp];
                    [attributes setObject:grade_id forKey:@"grade_id"];
                    DataForCell *data=[[DataForCell alloc]initWithAttributes:attributes];
                    [mutableBooks addObject:data];
                }
                if (block)
                {
                    block([NSArray arrayWithArray:mutableBooks],nil);
                }
            }
        failure:^(NSURLSessionTask *task,NSError* error)
            {
                if (block)
                {
                    block(nil,error);
                }
            }
            
        completionHandler:nil];
    
}
+(void)recordTextList:(NSArray*)textList gradeID:(NSString*)gradeID
{
    if (textList==nil)
    {
        return;
    }
    for (NSDictionary *arg in textList)
    {
        NSString *textID=[arg objectForKey:@"text_id"];
        NSString *textName=[arg objectForKey:@"text_name"];
        NSString *coverURL=[arg objectForKey:@"cover_url"];
        NSString *coursewareURL=[arg objectForKey:@"courseware_url"];
        NSString *desc=[arg objectForKey:@"desc"];
        NSString *challengeGoal=[arg objectForKey:@"challenge_goal"];
        NSString *challengeScore=[arg objectForKey:@"challenge_score"];
        NSString *listenCount=[arg objectForKey:@"listen_count"];
        NSString *practiseGoal=[arg objectForKey:@"practise_goal"];
        NSString *starCount=[arg objectForKey:@"star_count"];
        NSString *listenGoal=[arg objectForKey:@"listen_goal"];
        NSString *practiseCount=[arg objectForKey:@"practise_count"];
        NSString *version=[arg objectForKey:@"version"];
        NSArray *colums=[[NSArray alloc]initWithObjects:@"text_id",@"grade_id",@"text_name",@"cover_url",@"courseware_url",@"desc",@"challenge_goal",@"challenge_score",@"listen_count",@"practise_goal",@"star_count",@"listen_goal",@"practise_count",@"version",nil];
        NSArray *values=[[NSArray alloc]initWithObjects:
            [NSString stringWithFormat:@"'%@'",textID],
            [NSString stringWithFormat:@"'%@'",gradeID],
            [NSString stringWithFormat:@"'%@'",textName],
            [NSString stringWithFormat:@"'%@'",coverURL],
            [NSString stringWithFormat:@"'%@'",coursewareURL],
            [NSString stringWithFormat:@"'%@'",desc],
            [NSString stringWithFormat:@"'%@'",challengeGoal],
            [NSString stringWithFormat:@"'%@'",challengeScore],
            [NSString stringWithFormat:@"'%@'",listenCount],
            [NSString stringWithFormat:@"'%@'",practiseGoal],
            [NSString stringWithFormat:@"'%@'",starCount],
            [NSString stringWithFormat:@"'%@'",listenGoal],
            [NSString stringWithFormat:@"'%@'",practiseCount],
            [NSString stringWithFormat:@"'%@'",version], nil];
        [[MTDatabaseHelper sharedInstance] insertToTable:@"TextList" withColumns:colums andValues:values];
    }
}
//这里需要改成添加block参数
+(void)queryGradeList:(void (^)(NSArray*data))block
{
    [[MTDatabaseHelper sharedInstance] queryTable:@"GradeList" withSelect:@[@"*"] andWhere:nil completion:
     ^(NSMutableArray *resultsArray) {
         NSMutableArray *mutableBooks=[[NSMutableArray alloc]init];
         if (resultsArray!=nil)
         {
             for (NSDictionary*tmp in resultsArray)
             {
                 DataForCell *data=[[DataForCell alloc]initWithAttributes:tmp];
                 [mutableBooks addObject:data];
             }
         }
         if (block)
         {
             block([NSArray arrayWithArray:mutableBooks]);
         }
     }];
}
+(void)queryTextList:(NSString *)gradeID block:(void (^)(NSArray *))block
{
    NSDictionary *where=[NSDictionary dictionaryWithObjectsAndKeys:gradeID,@"grade_id", nil];
    [[MTDatabaseHelper sharedInstance] queryTable:@"TextList" withSelect:@[@"*"] andWhere:where completion:
     ^(NSMutableArray *resultsArray) {
         NSMutableArray *mutableBooks=[[NSMutableArray alloc]init];
         if (resultsArray!=nil)
         {
             for (NSDictionary*tmp in resultsArray)
             {
                 DataForCell *data=[[DataForCell alloc]initWithAttributes:tmp];
                 [mutableBooks addObject:data];
             }
         }
         if (block)
         {
             block([NSArray arrayWithArray:mutableBooks]);
         }
     }];
}




//首先是检查数据库中对应text_id的书是否存在，如果不存在就加入一条记录，然后是检查数据库对应text_id的zipfileName与当前的zipfileName是否相同，如果不一样返回no，表示需要重新下载，如果一样则返回yes，表示不用下载
-(BOOL)checkDatabase
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths lastObject];
    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
    if (![database open])
    {
        NSLog(@"database open failed");
        return NO;
    }
    FMResultSet *result=[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Books WHERE BookID=%@",self.text_id]];
    if(![result next])
    {
        BOOL success=[database executeUpdate:@"INSERT INTO Books (BookID,GradeID,BookName,CoverURL,Category,DownloadURL,ZipName,DocumentName,LMName,LRCName,PDFName,MP3Name) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",self.text_id,self.text_gradeID,self.text_name,self.cover_url,self.category,self.downloadURL,self.zipFileName,[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null]];
        if (!success)
        {
            NSLog(@"error: %@",[database lastError]);
        }
    }
    else
    {
        
        NSString *documentName=[result stringForColumn:@"DocumentName"];
        NSString *zipfileName=[result stringForColumn:@"ZipName"];
        NSString *BookID=[result stringForColumn:@"BookID"];
        if (![zipfileName isEqualToString:self.zipFileName]||documentName==nil)
        {
            [database close];
            return NO;
        }
        if (documentName!=nil)
        {
            NSString *path=[CommonMethod getPath:documentName];
            BOOL existence=[CommonMethod checkFileExistence:path];
            if (!existence)
            {
                BOOL success=[database executeUpdate:[NSString stringWithFormat:@"DELETE FROM Books WHERE BookID=%@",BookID]];
                if (!success)
                {
                    NSLog(@"delete from books failed with bookID:%@",BookID);
                }
                return NO;
            }
        }
    }
    [database close];
    return YES;
}
-(void)updateDatabase
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths lastObject];
    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
    if (![database open])
    {
        NSLog(@"database open failed");
        return;
    }
    //在这里需要更新gradelist表里面的已下载课本数量
    NSString *update=[NSString stringWithFormat:@"UPDATE Books SET DocumentName='%@',LMName='%@',LRCName='%@',PDFName='%@',MP3Name='%@' WHERE BookID=%@",[self getFileName:FTDocument],[self getFileName:FTLM],[self getFileName:FTLRC],[self getFileName:FTPDF],[self getFileName:FTMP3],self.text_id];
    BOOL success=[database executeUpdate:update];
    if (!success)
    {
        NSLog(@"error:%@",[database lastError]);
    }
    [database close];
}
-(void)loadDatabase
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths lastObject];
    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
    if (![database open])
    {
        NSLog(@"database open failed");
        return;
    }
    
    
    FMResultSet* result=[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Books WHERE BookID=%@",self.text_id]];
    if ([result next])
    {
        [self.fileNames addObject:[result stringForColumn:@"DocumentName"]];
        [self.fileNames addObject:[result stringForColumn:@"LMName"]];
        [self.fileNames addObject:[result stringForColumn:@"LRCName"]];
        [self.fileNames addObject:[result stringForColumn:@"PDFName"]];
        [self.fileNames addObject:[result stringForColumn:@"MP3Name"]];
    }
    [database close];
}
- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath
{
    NSArray *paths=[unzippedFilePath componentsSeparatedByString:@"/"];
    [self.fileNames addObject:[paths lastObject]];
}
-(NSString *)getFileName:(FileType)fileType
{
    if ([self.fileNames count]==0)
    {
        [self loadDatabase];
    }
    NSString *str=@"";
    switch (fileType)
    {
        case FTDocument:
            if ([self.fileNames count]!=0)
            {
                return self.fileNames[0];
            }
            break;
        case FTLM:
            str=@".lm";
            break;
        case FTLRC:
            str=@".lrc";
            break;
        case FTPDF:
            str=@".pdf";
            break;
        case FTMP3:
            str=@".MP3";
            break;
        default:
            return nil;
    }
    NSString *desName=nil;
    for (NSString *name in self.fileNames)
    {
        NSRange range=[name rangeOfString:str];
        if (range.length!=0)
        {
            desName=name;
            break;
        }
    }
    return desName;
}
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    [self updateDatabase];
    //delete zip file after extracting
    [self deleteZipFile];
}
-(void)deleteZipFile
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctDirectory=[path objectAtIndex:0];
    NSString *filePath=[doctDirectory stringByAppendingPathComponent:self.download_zipFileName];
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSLog(@"start delete zip file");
        [fileManager removeItemAtPath:filePath error:nil];
    }
}
-(void)dismissReaderViewController:(ReaderViewController *)viewController
{
    
    [[CommonMethod getCurrentVC] dismissViewControllerAnimated:NO completion:NULL];
    readerViewController=nil;
}

-(NSString *)getDocumentPath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths objectAtIndex:0];
    NSString *filePath=[doctPath stringByAppendingPathComponent:[self getFileName:FTDocument]];
    return filePath;
}
+(void)deleteCache:(NSArray *)data
{
    [[MTDatabaseHelper sharedInstance] queryTable:@"GradeList" withSelect:@[@"*"] andWhere:nil completion:
     ^(NSMutableArray *resultsArray) {
         NSMutableArray *deleteGrade=[[NSMutableArray alloc]init];
         if (resultsArray!=nil)
         {
             
             for (NSDictionary*tmp in resultsArray)
             {
                 BOOL shouldDelete=true;
                 for (DataForCell *currentGrade in data)
                 {
                     if ([[tmp objectForKey:@"grade_id"] integerValue]==[currentGrade.text_id integerValue])
                     {
                         shouldDelete=false;
                         break;
                     }
                 }
                 if (shouldDelete)
                 {
                     [deleteGrade addObject:[tmp objectForKey:@"grade_id"]];
                 }
             }
             [DataForCell deleteListAndFiles:deleteGrade];
         }
     }];
}
//delete gradelist item booklist item and cache files
+(void)deleteListAndFiles:(NSArray*)gradeList
{
    //delete gradelist textlist
    for (NSString* item in gradeList)
    {
        NSDictionary *where=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",item],@"grade_id",nil];
        [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"GradeList" withWhere:where];
        [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"TextList" withWhere:where];
    }
    //delete books and files
    for (NSString* item in gradeList)
    {
        [DataForCell deleteBooks:item];
    }
}
+(void)deleteBooks:(NSString*)gradeID
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths lastObject];
    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
    if (![database open])
    {
        NSLog(@"database open failed");
        return;
    }
    FMResultSet* result=[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Books WHERE GradeID=%@",gradeID]];
    while([result next])
    {
        NSString *documentName=[result stringForColumn:@"DocumentName"];
        NSString *BookID=[result stringForColumn:@"BookID"];
        if (documentName!=nil)
        {
            //delete files
            NSString *Path=[CommonMethod getPath:[NSString stringWithFormat:@"%@",documentName]];
            BOOL isDir;
            if ([[NSFileManager defaultManager] fileExistsAtPath:Path isDirectory:&isDir])
            {
                [[NSFileManager defaultManager] removeItemAtPath:Path error:nil];
            }
        }
        BOOL success=[database executeUpdate:[NSString stringWithFormat:@"DELETE FROM Books WHERE BookID=%@",BookID]];
        if (!success)
        {
            NSLog(@"delete from books failed with bookID:%@",BookID);
        }
    }
    [database close];
}
+(void)showCache:(void (^)(NSArray *cacheData))block currentData:(NSArray *)currentData
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths lastObject];
    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
    if (![database open])
    {
        NSLog(@"database open failed");
        return;
    }
    FMResultSet* result=[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Books"]];
    NSMutableSet *cacheGradeList=[[NSMutableSet alloc]init];
    while([result next])
    {
        NSString *documentName=[result stringForColumn:@"DocumentName"];
        NSString *GradeID=[result stringForColumn:@"GradeID"];
        BOOL isCache=true;
        for (DataForCell* tmp in currentData)
        {
            if ([GradeID integerValue]==[tmp.text_id integerValue])
            {
                isCache=false;
            }
        }
        if (isCache)
        {
            if (documentName!=nil)
            {
                NSString *Path=[CommonMethod getPath:[NSString stringWithFormat:@"%@",documentName]];
                BOOL isDir;
                if ([[NSFileManager defaultManager] fileExistsAtPath:Path isDirectory:&isDir])
                {
                    [cacheGradeList addObject:GradeID];
                }
            }
        }
    }
    [database close];
    NSMutableArray *where=[[NSMutableArray alloc]init];
    for (NSString* item in cacheGradeList)
    {
        [where addObject:item];
    }
    [[MTDatabaseHelper sharedInstance] queryTable:@"GradeList" withSelect:@[@"*"] column:@"grade_id" andIDs:where completion:
     ^(NSMutableArray *resultsArray) {
         NSMutableArray *mutableBooks=[[NSMutableArray alloc]init];
         if (resultsArray!=nil)
         {
             for (NSDictionary*tmp in resultsArray)
             {
                 DataForCell *data=[[DataForCell alloc]initWithAttributes:tmp];
                 [mutableBooks addObject:data];
             }
         }
         if (block)
         {
             block([NSArray arrayWithArray:mutableBooks]);
         }
     }];
}
+(void)getCacheBooks:(NSString*)gradeID block:(void (^)(NSArray*data))block
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths lastObject];
    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
    if (![database open])
    {
        NSLog(@"database open failed");
        return;
    }
    FMResultSet* result=[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Books WHERE GradeID=%@",gradeID]];
    NSMutableArray *where=[[NSMutableArray alloc]init];
    while([result next])
    {
        NSString *documentName=[result stringForColumn:@"DocumentName"];
        NSString *BookID=[result stringForColumn:@"BookID"];
        if (documentName!=nil)
        {
            //query textlist
            [where addObject:BookID];
        }
    }
    [[MTDatabaseHelper sharedInstance] queryTable:@"TextList" withSelect:@[@"*"] column:@"text_id" andIDs:where completion:
     ^(NSMutableArray *resultsArray) {
         NSMutableArray *mutableBooks=[[NSMutableArray alloc]init];
         if (resultsArray!=nil)
         {
             for (NSDictionary*tmp in resultsArray)
             {
                 DataForCell *data=[[DataForCell alloc]initWithAttributes:tmp];
                 [mutableBooks addObject:data];
             }
         }
         if (block)
         {
             block([NSArray arrayWithArray:mutableBooks]);
         }
     }];
    [database close];
}
@end
