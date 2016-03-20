//
//  DataForCell.h
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/21.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSZipArchive.h"
#import "ReaderViewController.h"
#import "DAProgressOverlayView.h"
@import UIKit;

typedef NS_ENUM(NSInteger,FileType)
{
    FTDocument=0,
    FTLM,
    FTLRC,
    FTPDF,
    FTMP3
};

@interface DataForCell : NSObject<ReaderViewControllerDelegate,SSZipArchiveDelegate>
@property(strong,nonatomic)NSString *text_name;
@property(nonatomic)NSString *text_id;
@property(strong,nonatomic)NSString *cover_url;
@property(nonatomic)NSString *category;
@property(strong,nonatomic)NSString *downloadURL;
@property(strong,nonatomic)NSString *zipFileName;
@property(strong,nonatomic)NSString *download_zipFileName;
@property(strong,nonatomic)NSMutableArray *fileNames;
@property(strong,nonatomic)NSURLSessionTask *task;
@property(strong,nonatomic)NSString *text_count;
@property(nonatomic,strong)DAProgressOverlayView *progressView;

-(instancetype)initWithAttributes:(NSDictionary *)attributes;
+(NSURLSessionTask*)getGradeList:(void(^)(NSArray *data,NSError *error))block;
+(void)getTextList:(void (^)(NSArray *, NSError *))block grade_id:(NSString*)grade_id text_id:(NSString*)text_id;
- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath;
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath;
-(NSString*)getFileName:(FileType)fileType;
- (void)dismissReaderViewController:(ReaderViewController *)viewController;
-(BOOL)checkDatabase;
-(NSString*)getDocumentPath;
+(void)queryGradeList:(void (^)(NSArray*data))block;
+(void)queryTextList:(NSString*)gradeID block:(void (^)(NSArray*data))block;
@end
