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
#import "GNDownloadDatabase.h"


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
    self.shouldDownloadFirst=YES;
    self.shouldDownloadSecond=YES;
    if ([attributes objectForKey:@"text_id"]!=nil)
    {
        self.text_id=[attributes objectForKey:@"text_id"];
        self.text_name=[[attributes objectForKey:@"text_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"*"];
        self.cover_url=[attributes objectForKey:@"cover_url"];
        self.category=[attributes objectForKey:@"category"];
        self.downloadURL=[attributes objectForKey:@"courseware_multimedia_url"];
        self.zipFileName=[[[[[self.downloadURL componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"?"] objectAtIndex:0]stringByReplacingOccurrencesOfString:@"\%2F" withString:@"_"];
        self.fileNames=[[NSMutableArray alloc]init];
        self.text_gradeID=[attributes objectForKey:@"grade_id"];
        self.progressView=nil;
        
        
        
        self.downloadURLSecond=[attributes objectForKey:@"courseware_text_url"];
        self.mediaVersion=[attributes objectForKey:@"courseware_multimedia_version"];
        self.textVersion=[attributes objectForKey:@"courseware_text_version"];
        
//        self.mediaVersion=@"1";
//        self.textVersion=@"1";
        
        [self loadDatabase];
//        [self checkDatabase];
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
//使用courseware_url字段存储version信息
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
        textName=[textName stringByReplacingOccurrencesOfString:@"'" withString:@"*"];
        NSString *coverURL=[arg objectForKey:@"cover_url"];
        NSString *versionMerge=[NSString stringWithFormat:@"%@-%@",[arg objectForKey:@"courseware_multimedia_version"],[arg objectForKey:@"courseware_text_version"]];
        NSString *desc=[arg objectForKey:@"desc"];
        NSString *challengeGoal=[arg objectForKey:@"challenge_goal"];
        NSString *challengeScore=[arg objectForKey:@"challenge_score"];
        NSString *listenCount=[arg objectForKey:@"listen_count"];
        NSString *practiseGoal=[arg objectForKey:@"practise_goal"];
        NSString *starCount=[arg objectForKey:@"star_count"];
        NSString *listenGoal=[arg objectForKey:@"listen_goal"];
        NSString *practiseCount=[arg objectForKey:@"repeat_sentence_count"];
        NSString *version=[arg objectForKey:@"version"];
        NSArray *colums=[[NSArray alloc]initWithObjects:@"text_id",@"grade_id",@"text_name",@"cover_url",@"courseware_url",@"desc",@"challenge_goal",@"challenge_score",@"listen_count",@"practise_goal",@"star_count",@"listen_goal",@"practise_count",@"version",nil];
        NSArray *values=[[NSArray alloc]initWithObjects:
            [NSString stringWithFormat:@"'%@'",textID],
            [NSString stringWithFormat:@"'%@'",gradeID],
            [NSString stringWithFormat:@"'%@'",textName],
            [NSString stringWithFormat:@"'%@'",coverURL],
            [NSString stringWithFormat:@"'%@'",versionMerge],
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
//use zipfileName to record version info
-(void)checkDatabase:(void (^)(BOOL existence))block;
{
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *doctPath=[paths lastObject];
//    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
//    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
    [[GNDownloadDatabase sharedInstance] queryTable:@"Books" withSelect:@[@"*"]  andWhere:[NSDictionary dictionaryWithObjectsAndKeys:self.text_id,@"BookID", nil] completion:^(NSMutableArray *resultsArray) {
        
        if (resultsArray!=nil&&[resultsArray count]!=0)
        {
            NSDictionary *result=[resultsArray firstObject];
            NSString *documentName=[result objectForKey:@"DocumentName"];
            NSString *lrcName=[result objectForKey:@"LRCName"];
            NSString *version=[result objectForKey:@"ZipName"];
            NSString *mp3Name=[result objectForKey:@"MP3Name"];
            if (documentName==nil||lrcName==nil||mp3Name==nil)
            {
                block(NO);
                return;
            }
            if ([documentName isEqual:[NSNull null]]||[lrcName isEqual:[NSNull null]]||[mp3Name isEqual:[NSNull null]])
            {
                block(NO);
                return;
            }
            if ([documentName isEqualToString:@"(null)"]||[lrcName isEqualToString:@"(null)"]||[mp3Name isEqualToString:@"(null)"])
            {
                block(NO);
                return;
            }
            
            NSString *path=[CommonMethod getPath:documentName];
            NSString *path1=[path stringByAppendingPathComponent:lrcName];
            NSString *path2=[path stringByAppendingPathComponent:mp3Name];
            BOOL existence=[CommonMethod checkFileExistence:path]&&[CommonMethod checkFileExistence:path1]&&[CommonMethod checkFileExistence:path2];
            if (!existence)
            {
                block(NO);
                return;
            }
            //兼容旧版没有在下载完成进行解密
//            else
//            {
//                NSString *fileName=[NSString stringWithFormat:@"original_%@",[self getFileName:FTLRC]];
//                path=[path stringByAppendingPathComponent:fileName];
//                if (![CommonMethod checkFileExistence:path])
//                {
//                    [self decodeLyric:[self getFileName:FTLRC]];
//                }
//            }
            if (version!=nil&&self.mediaVersion!=nil&&self.textVersion!=nil)
            {
                NSArray *versions=[version componentsSeparatedByString:@"-"];
                NSString *ver1=[versions firstObject];
                NSString *ver2=[versions lastObject];
                if ([ver1 integerValue]!=[self.mediaVersion integerValue])
                {
                    self.shouldDownloadFirst=YES;
                }
                else
                    self.shouldDownloadFirst=NO;
                if ([ver2 integerValue]!=[self.textVersion integerValue])
                {
                    self.shouldDownloadSecond=YES;
                }
                else
                    self.shouldDownloadSecond=NO;
                if (self.shouldDownloadFirst||self.shouldDownloadSecond)
                {
                    block(NO);
                    return;
                }
            }
            block(YES);
        }
        else
             block(NO);
    }];
    
//    if (![database open])
//    {
//        NSLog(@"database open failed");
//        return NO;
//    }
//    FMResultSet *result=[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Books WHERE BookID=%@",self.text_id]];
//    if(![result next])
//    {
//        NSString *ver=[NSString stringWithFormat:@"%@-%@",self.mediaVersion,self.textVersion];
//        BOOL success=[database executeUpdate:@"INSERT INTO Books (BookID,GradeID,BookName,CoverURL,Category,DownloadURL,ZipName,DocumentName,LMName,LRCName,PDFName,MP3Name) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",self.text_id,self.text_gradeID,self.text_name,self.cover_url,self.category,self.downloadURL,ver,[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null]];
//        if (!success)
//        {
//            NSLog(@"error: %@",[database lastError]);
//        }
//    }
//    else
//    {
//        
//
//    }
//    [database close];
//    return YES;
}

-(void)updateDatabase
{
    
    NSArray *colums=[[NSArray alloc]initWithObjects:@"BookID",@"GradeID",@"BookName",@"CoverURL",@"Category",@"DownloadURL",@"ZipName",@"DocumentName",@"LMName",@"LRCName",@"PDFName",@"MP3Name", nil];
    NSString *ver=[NSString stringWithFormat:@"%@-%@",self.mediaVersion,self.textVersion];
    NSArray *values=[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"'%@'",self.text_id],[NSString stringWithFormat:@"'%@'",self.text_gradeID],[NSString stringWithFormat:@"'%@'",self.text_name],[NSString stringWithFormat:@"'%@'",self.cover_url],[NSString stringWithFormat:@"'%@'",self.category],[NSString stringWithFormat:@"'%@'",self.downloadURL],[NSString stringWithFormat:@"'%@'",ver],[NSString stringWithFormat:@"'%@'",[self getFileName:FTDocument]],[NSString stringWithFormat:@"'%@'",[self getFileName:FTLM]], [NSString stringWithFormat:@"'%@'",[self getFileName:FTLRC]],[NSString stringWithFormat:@"'%@'",[self getFileName:FTPDF]],[NSString stringWithFormat:@"'%@'",[self getFileName:FTMP3]],nil];
    [[GNDownloadDatabase sharedInstance] insertToTable:@"Books" withColumns:colums andValues:values];
    
    
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *doctPath=[paths lastObject];
//    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
//    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
//    if (![database open])
//    {
//        NSLog(@"database open failed");
//        return;
//    }
//
//    //在这里需要更新gradelist表里面的已下载课本数量
//    NSString *version=[NSString stringWithFormat:@"%@-%@",self.mediaVersion,self.textVersion];
//    NSString *update=[NSString stringWithFormat:@"UPDATE Books SET ZipName='%@',DocumentName='%@',LMName='%@',LRCName='%@',PDFName='%@',MP3Name='%@' WHERE BookID=%@",version,[self getFileName:FTDocument],[self getFileName:FTLM],[self getFileName:FTLRC],[self getFileName:FTPDF],[self getFileName:FTMP3],self.text_id];
//    
//    BOOL success=[database executeUpdate:update];
//    if (!success)
//    {
//        NSLog(@"error:%@",[database lastError]);
//    }
//    [database close];
}
-(void)loadDatabase
{
    
    
    [[GNDownloadDatabase sharedInstance] queryTable:@"Books" withSelect:@[@"*"] andWhere:[NSDictionary dictionaryWithObjectsAndKeys:self.text_id,@"BookID", nil] completion:^(NSMutableArray *resultsArray) {
        if (resultsArray!=nil&&[resultsArray count]!=0)
        {
            NSDictionary *result=[resultsArray firstObject];
            [self.fileNames addObject:[result objectForKey:@"DocumentName"]];
            [self.fileNames addObject:[result objectForKey:@"LMName"]];
            [self.fileNames addObject:[result objectForKey:@"LRCName"]];
            [self.fileNames addObject:[result objectForKey:@"PDFName"]];
            [self.fileNames addObject:[result objectForKey:@"MP3Name"]];
        }
    }];
    
    
    
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *doctPath=[paths lastObject];
//    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
//    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
//    if (![database open])
//    {
//        NSLog(@"database open failed");
//        return;
//    }
//    FMResultSet* result=[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Books WHERE BookID=%@",self.text_id]];
//    if ([result next])
//    {
//        [self.fileNames addObject:[result stringForColumn:@"DocumentName"]];
//        [self.fileNames addObject:[result stringForColumn:@"LMName"]];
//        [self.fileNames addObject:[result stringForColumn:@"LRCName"]];
//        [self.fileNames addObject:[result stringForColumn:@"PDFName"]];
//        [self.fileNames addObject:[result stringForColumn:@"MP3Name"]];
//    }
//    [database close];
}
- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath
{
    NSArray *paths=[unzippedFilePath componentsSeparatedByString:@"/"];
    [self.fileNames addObject:[paths lastObject]];
}
-(NSString *)getFileName:(FileType)fileType
{
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
    //为了适配学前班beyond中出现mp3后缀的文件
    if (desName==nil&&[self.fileNames count]!=0)
    {
        str=[str lowercaseString];
        NSString *path=[CommonMethod getPath:[self.fileNames objectAtIndex:0]];
        NSArray *tmpList=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        for (NSString *name in tmpList)
        {
            NSRange range=[name rangeOfString:str];
            if (range.length!=0)
            {
                desName=name;
                break;
            }
        }
    }
    return desName;
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    //when you can get the lrc file move all the file from the current doc to the first doc
    
    
    [self updateDatabase];
//    //delete zip file after extracting
    [self deleteZipFile];
//    [self decodeLyric:[self getFileName:FTLRC]];
}
- (void)decodeLyric:(NSString *)fileName
{
    if (fileName==nil)
    {
        return;
    }
    
    NSString *filePath=[self getDocumentPath];
    filePath=[filePath stringByAppendingPathComponent:fileName];
    NSString *newFilePath=[self getDocumentPath];
    newFilePath=[newFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"original_%@",fileName]];
    if ([CommonMethod checkFileExistence:newFilePath])
    {
        return;
    }
    NSData *secretText=[NSData dataWithContentsOfFile:filePath];
    NSString *result=[CommonMethod decryptAESData:secretText app_key:CIPHER_KEY];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager moveItemAtPath:filePath toPath:newFilePath error:nil])
    {
        if (![result writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil])
        {
            NSLog(@"write decode file failed");
        }
    }
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
    
    [[GNDownloadDatabase sharedInstance] queryTable:@"Books" withSelect:@[@"*"] andWhere:[NSDictionary dictionaryWithObjectsAndKeys:gradeID,@"GradeID", nil] completion:^(NSMutableArray *resultsArray) {
        if (resultsArray!=nil&&[resultsArray count]!=0)
        {
            for (NSDictionary *result in resultsArray)
            {
                NSString *documentName=[result objectForKey:@"DocumentName"];
                NSString *BookID=[result objectForKey:@"BookID"];
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
                NSDictionary *where=[NSDictionary dictionaryWithObjectsAndKeys:BookID,@"BookID",nil];
                [[GNDownloadDatabase sharedInstance] deleteTurpleFromTable:@"Books" withWhere:where];
            }
        }
    }];
    
    
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *doctPath=[paths lastObject];
//    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
//    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
//    if (![database open])
//    {
//        NSLog(@"database open failed");
//        return;
//    }
//    FMResultSet* result=[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Books WHERE GradeID=%@",gradeID]];
//    while([result next])
//    {
//        NSString *documentName=[result stringForColumn:@"DocumentName"];
//        NSString *BookID=[result stringForColumn:@"BookID"];
//        if (documentName!=nil)
//        {
//            //delete files
//            NSString *Path=[CommonMethod getPath:[NSString stringWithFormat:@"%@",documentName]];
//            BOOL isDir;
//            if ([[NSFileManager defaultManager] fileExistsAtPath:Path isDirectory:&isDir])
//            {
//                [[NSFileManager defaultManager] removeItemAtPath:Path error:nil];
//            }
//        }
//        BOOL success=[database executeUpdate:[NSString stringWithFormat:@"DELETE FROM Books WHERE BookID=%@",BookID]];
//        if (!success)
//        {
//            NSLog(@"delete from books failed with bookID:%@",BookID);
//        }
//    }
//    [database close];
}
+(void)showCache:(void (^)(NSArray *cacheData))block currentData:(NSArray *)currentData
{
    [[GNDownloadDatabase sharedInstance] queryTable:@"Books" withSelect:@[@"*"] andWhere:nil completion:^(NSMutableArray *resultsArray) {
        if (resultsArray!=nil&&[resultsArray count]!=0)
        {
            NSMutableSet *cacheGradeList=[[NSMutableSet alloc]init];
            for (NSDictionary *result in resultsArray)
            {
                NSString *documentName=[result objectForKey:@"DocumentName"];
                NSString *GradeID=[result objectForKey:@"GradeID"];
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
            NSMutableArray *where=[[NSMutableArray alloc]init];
            for (NSString* item in cacheGradeList)
            {
                [where addObject:item];
            }
            if ([where count]>0)
            {
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
            else
                block(nil);
        }
    }];
    
    
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *doctPath=[paths lastObject];
//    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
//    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
//    if (![database open])
//    {
//        NSLog(@"database open failed");
//        return;
//    }
//    FMResultSet* result=[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Books"]];
//    NSMutableSet *cacheGradeList=[[NSMutableSet alloc]init];
//    while([result next])
//    {
//        NSString *documentName=[result stringForColumn:@"DocumentName"];
//        NSString *GradeID=[result stringForColumn:@"GradeID"];
//        BOOL isCache=true;
//        for (DataForCell* tmp in currentData)
//        {
//            if ([GradeID integerValue]==[tmp.text_id integerValue])
//            {
//                isCache=false;
//            }
//        }
//        if (isCache)
//        {
//            if (documentName!=nil)
//            {
//                NSString *Path=[CommonMethod getPath:[NSString stringWithFormat:@"%@",documentName]];
//                BOOL isDir;
//                if ([[NSFileManager defaultManager] fileExistsAtPath:Path isDirectory:&isDir])
//                {
//                    [cacheGradeList addObject:GradeID];
//                }
//            }
//        }
//    }
//    [database close];
//    NSMutableArray *where=[[NSMutableArray alloc]init];
//    for (NSString* item in cacheGradeList)
//    {
//        [where addObject:item];
//    }
//    if ([where count]>0)
//    {
//        [[MTDatabaseHelper sharedInstance] queryTable:@"GradeList" withSelect:@[@"*"] column:@"grade_id" andIDs:where completion:
//         ^(NSMutableArray *resultsArray) {
//             NSMutableArray *mutableBooks=[[NSMutableArray alloc]init];
//             if (resultsArray!=nil)
//             {
//                 for (NSDictionary*tmp in resultsArray)
//                 {
//                     DataForCell *data=[[DataForCell alloc]initWithAttributes:tmp];
//                     [mutableBooks addObject:data];
//                 }
//             }
//             if (block)
//             {
//                 block([NSArray arrayWithArray:mutableBooks]);
//             }
//         }];
//    }
//    else
//        block(nil);
}
+(void)getCacheBooks:(NSString*)gradeID block:(void (^)(NSArray*data))block
{
    
    [[GNDownloadDatabase sharedInstance] queryTable:@"Books" withSelect:@[@"*"] andWhere:[NSDictionary dictionaryWithObjectsAndKeys:gradeID,@"GradeID",nil] completion:^(NSMutableArray *resultsArray) {
        if (resultsArray!=nil&&[resultsArray count]!=0)
        {
            NSMutableArray *where=[[NSMutableArray alloc]init];
            for (NSDictionary *result in resultsArray)
            {
                NSString *documentName=[result objectForKey:@"DocumentName"];
                NSString *BookID=[result objectForKey:@"BookID"];
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
        }
    }];
    
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *doctPath=[paths lastObject];
//    NSString *databasePath=[doctPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
//    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
//    if (![database open])
//    {
//        NSLog(@"database open failed");
//        return;
//    }
//    FMResultSet* result=[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Books WHERE GradeID=%@",gradeID]];
//    NSMutableArray *where=[[NSMutableArray alloc]init];
//    while([result next])
//    {
//        NSString *documentName=[result stringForColumn:@"DocumentName"];
//        NSString *BookID=[result stringForColumn:@"BookID"];
//        if (documentName!=nil)
//        {
//            //query textlist
//            [where addObject:BookID];
//        }
//    }
//    [[MTDatabaseHelper sharedInstance] queryTable:@"TextList" withSelect:@[@"*"] column:@"text_id" andIDs:where completion:
//     ^(NSMutableArray *resultsArray) {
//         NSMutableArray *mutableBooks=[[NSMutableArray alloc]init];
//         if (resultsArray!=nil)
//         {
//             for (NSDictionary*tmp in resultsArray)
//             {
//                 DataForCell *data=[[DataForCell alloc]initWithAttributes:tmp];
//                 [mutableBooks addObject:data];
//             }
//         }
//         if (block)
//         {
//             block([NSArray arrayWithArray:mutableBooks]);
//         }
//     }];
//    [database close];
}
@end
