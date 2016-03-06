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
#import "CommonMethod.h"
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
        [self checkDatabase];
//        [self getBookDetail];
    }
    else
    {
        self.text_id=[attributes objectForKey:@"grade_id"];
        self.text_name=[attributes objectForKey:@"grade_name"];
        self.cover_url=[attributes objectForKey:@"cover_url"];
        self.category=nil;
        self.fileNames=nil;
        self.downloadURL=nil;
        self.zipFileName=nil;
    }
    self.task=nil;
    return self;
    
}
+(NSURLSessionTask*)getTextList:(void (^)(NSArray *, NSError *))block grade_id:(NSString*)grade_id{
    
    NSDictionary *parameters=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"user_id",grade_id,@"grade_id", nil];
    NSMutableArray *mutableBooks=[[NSMutableArray alloc]init];
    return [NetworkingManager httpRequest:RTGet url:RUText_list parameters:parameters progress:nil
    success:^(NSURLSessionTask *task,id JSON)
            {
                NSArray *list=[JSON valueForKey:@"text_list"];
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
                    block([NSArray array],error);
                }
            }
            
    completionHandler:nil];
    
}
+(NSURLSessionTask*)getGradeList:(void (^)(NSArray *, NSError *))block{
    
    NSDictionary *parameters=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"user_id", nil];
    NSMutableArray *mutableBooks=[[NSMutableArray alloc]init];
    return [NetworkingManager httpRequest:RTGet url:RUGrade_list parameters:parameters progress:nil
    success:^(NSURLSessionTask *task,id JSON)
            {
                NSInteger status=[JSON valueForKey:@"status"];
                if (status!=0)
                {
                    NSLog(@"get gradeList error with errormsg: %@",[JSON valueForKey:@"errormsg"]);
                }
                NSArray *list=[JSON valueForKey:@"grade_list"];
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
                    block([NSArray array],error);
                }
            }
            
    completionHandler:nil];
    
}

-(void)getBookDetail
{
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:self.text_id,@"text_id",@"1",@"user_id",nil];
    __weak __typeof(self)weakself=self;
    [NetworkingManager httpRequest:RTGet url:RUText_detail parameters:parameters progress:nil
      success:^(NSURLSessionTask *task, id  _Nullable responseObject)
    {
        NSDictionary *text_detail=[responseObject objectForKey:@"text_detail"];
        weakself.downloadURL=[text_detail objectForKey:@"courseware_url"];
        weakself.zipFileName=[text_detail objectForKey:@"file_name"];
        [weakself checkDatabase];
    } failure:^(NSURLSessionTask * _Nullable task, NSError *error)
    {
        
    } completionHandler:nil];
}
//首先是检查数据库中对应text_id的书是否存在，如果不存在就加入一条记录，然后是检查数据库对应text_id的zipfileName与当前的zipfileName是否相同，如果不一样返回no，表示需要重新下载，如果一样则返回yes，表示不用下载
-(BOOL)checkDatabase
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths lastObject];
    NSString *databasePath=[doctPath stringByAppendingPathComponent:@"user.sqlite"];
    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
    if (![database open])
    {
        NSLog(@"database open failed");
        return NO;
    }
    FMResultSet *result=[database executeQuery:[NSString stringWithFormat:@"SELECT * FROM Books WHERE BookID=%@",self.text_id]];
    if(![result next])
    {
        BOOL success=[database executeUpdate:@"INSERT INTO Books (BookID,BookName,CoverURL,Category,DownloadURL,ZipName,DocumentName,LMName,LRCName,PDFName,MP3Name) VALUES (?,?,?,?,?,?,?,?,?,?,?)",self.text_id,self.text_name,self.cover_url,self.category,self.downloadURL,self.zipFileName,[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null]];
        if (!success)
        {
            NSLog(@"error: %@",[database lastError]);
        }
    }
    else
    {
        
        NSString *documentName=[result stringForColumn:@"DocumentName"];
        NSString *zipfileName=[result stringForColumn:@"ZipName"];
        if (![zipfileName isEqualToString:self.zipFileName]||documentName==nil)
        {
            [database close];
            return NO;
        }
    }
    [database close];
    return YES;
}
-(void)updateDatabase
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths lastObject];
    NSString *databasePath=[doctPath stringByAppendingPathComponent:@"user.sqlite"];
    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
    if (![database open])
    {
        NSLog(@"database open failed");
        return;
    }
    
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
    NSString *databasePath=[doctPath stringByAppendingPathComponent:@"user.sqlite"];
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
@end
