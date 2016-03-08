//
//  BookViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/19.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "BookViewController.h"
#import "DataForCell.h"
#import "CommonMethod.h"
#import "TextBookCell.h"
#import "DataForCell.h"
#import "NetworkingManager.h"
#import "MRProgress.h"
#import <AVFoundation/AVFoundation.h>
#import "LyricViewController.h"
#import "FMDB.h"

@interface BookViewController ()
{
    ReaderViewController *readerViewController;
    LyricViewController *lyricViewController;
}
@end

@implementation BookViewController

static NSString * const reuseIdentifierBook = @"TextBookCell";


-(void)initDatabase
{
    NSString *databasePath=[CommonMethod getPath:@"user.sqlite"];
    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
    if (![database open])
    {
        NSLog(@"database open failed");
        return;
    }
    
    FMResultSet *result=[database executeQuery:@"select * from Books"];
    if (![result next])
    {
        NSString *createTable=@"create table Books(BookID  integer,BookName varchar(255),CoverURL varchar(512),Category integer,DownloadURL varchar(512),ZipName varchar(255),DocumentName varchar(255),LMName varchar(255),LRCName varchar(255),PDFName varchar(255),MP3Name varchar(255));";
        BOOL success=[database executeUpdate:createTable];
        if (!success)
        {
            NSLog(@"create table failed");
            return;
        }
        NSLog(@"create table success");
    }
    else
    {
        NSLog(@"table books exist");
    }
    [database close];
}


-(void)reload:(__unused id)sender{
    __weak __typeof__(self) weakSelf = self;
    NSURLSessionTask *task=[DataForCell getTextList:^(NSArray *data, NSError *error) {
        if (data==nil)
        {
            [DataForCell queryTextList:weakSelf.grade_id block:^(NSArray*cells){
                weakSelf.list=cells;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.collectionView reloadData];
                });
            }];
        }
        else
        {
            weakSelf.list=data;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadData];
            });
        }
        
    } grade_id:self.grade_id];
}
- (IBAction)goBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    self.collectionView.delegate=self;
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setHidden:YES];
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"background"] scaledToSize:CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
    self.collectionView.backgroundView=[[UIImageView alloc]initWithImage:background];
    [self initDatabase];
    [self reload:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.list count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TextBookCell *cell = (TextBookCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierBook forIndexPath:indexPath];
    // Configure the cell
    cell.book=self.list[indexPath.row];
    return cell;
}




- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(200, 250);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 100, 0, 100);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 100.0f;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TextBookCell *cell=(TextBookCell*)[collectionView cellForItemAtIndexPath:indexPath];
    DataForCell *book=self.list[indexPath.row];
    if ([book checkDatabase]||book.task!=nil)//检查是否下载过
    {
        return;
    }
    //这里还没有处理下载出错的情况
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:book.downloadURL,@"url",nil];
    __weak __typeof__(self) weakSelf = self;
    __block MRProgressOverlayView *progressView=[MRProgressOverlayView showOverlayAddedTo:cell title:@"downloading" mode:MRProgressOverlayViewModeDeterminateCircular animated:YES];
    __block NSURLSessionTask *task=
    [NetworkingManager httpRequest:RTDownload url:RUCustom parameters:parameters
                          progress:^(NSProgress *downloadProgress)
     {
         if (downloadProgress)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [progressView setProgress:downloadProgress.fractionCompleted];
                 if (downloadProgress.fractionCompleted == 1.0000) {
                     [progressView dismiss:YES];
                     progressView=nil;
                     NSLog(@"download complete");
                     if(progressView!=nil)
                         NSLog(@"progressView is not nil");
                 } else {
                     
                 }
             });
         }
     }
    success:nil failure:nil
    completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error)
     {
         NSLog(@"log for download response:%@",response);
         NSLog(@"File downloaded to: %@", filePath.absoluteString);
         if ([[NSFileManager defaultManager] fileExistsAtPath:[filePath.absoluteString substringFromIndex:7]])
         {
             [weakSelf unzipDownloadFile:[filePath.absoluteString substringFromIndex:7] index:indexPath.row];
         }
     }];
    book.task=task;
    progressView.stopBlock = ^(MRProgressOverlayView *view){
        if (task.state==NSURLSessionTaskStateSuspended)
        {
            [view setTitleLabelText:@"downloading"];
            [task resume];
        }
        else
        {
            [view setTitleLabelText:@"suspended"];
            [task suspend];
        }
    };
}


-(void)unzipDownloadFile:(NSString*)filePath index:(NSInteger)index
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths objectAtIndex:0];
    NSString *zipFileName=[[filePath componentsSeparatedByString:@"/"] lastObject];
    DataForCell *book=self.list[index];
    book.download_zipFileName=zipFileName;
    [SSZipArchive unzipFileAtPath:filePath toDestination:doctPath delegate:book];
}

-(void)dismissReaderViewController:(ReaderViewController *)viewController
{
    
    [self dismissViewControllerAnimated:NO completion:NULL];
    readerViewController=nil;
}


-(void)playMP3:(NSInteger)index
{
    DataForCell *book=self.list[index];
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    lyricViewController=[storyboard instantiateViewControllerWithIdentifier:@"LyricViewController"];
    [lyricViewController initWithBook:book];
    [self.navigationController pushViewController:lyricViewController animated:YES];
}




#pragma mark <UICollectionViewDelegate>

@end
