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
#import "DataForCell.h"
#import "NetworkingManager.h"
#import <AVFoundation/AVFoundation.h>
#import "LyricViewController.h"
#import "FMDB.h"
#import "DAProgressOverlayView.h"
#define PROGRESSVIEW_TAG 1234

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
        NSString *createTable=@"create table Books(BookID  integer,GradeID integer,BookName varchar(255),CoverURL varchar(512),Category integer,DownloadURL varchar(512),ZipName varchar(255),DocumentName varchar(255),LMName varchar(255),LRCName varchar(255),PDFName varchar(255),MP3Name varchar(255));";
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
    [DataForCell queryTextList:weakSelf.grade_id block:^(NSArray*cells){
        weakSelf.list=cells;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
    }];
    [DataForCell getTextList:^(NSArray *data, NSError *error) {
        if(data!=nil)
        {
            weakSelf.list=data;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadData];
            });
        }
        
    } grade_id:self.grade_id text_id:@"-1"];
}
- (IBAction)goBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
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
    cell.index=indexPath.row;
    cell.delegate=self;
    DataForCell* data=self.list[indexPath.row];
    if ([cell.contentView viewWithTag:PROGRESSVIEW_TAG]!=nil)
    {
        [[cell.contentView viewWithTag:PROGRESSVIEW_TAG] removeFromSuperview];
    }
    if (data.progressView!=nil)
    {
        [cell.contentView addSubview:data.progressView];
    }
    return cell;
    //需要维护当前的process
}
-(void)clickCellButton:(NSInteger)index
{
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //6s width:180 height:250 6s width:160 height:220 5 width:150 height:200
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type)
    {
        case Iphone5s:
            return CGSizeMake(150, 180);
        case Iphone6:
            return CGSizeMake(160, 200);
        case Iphone6p:
            return CGSizeMake(180, 220);
        default:
            return CGSizeMake(150, 180);
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //6s: 100, 100, 100, 100 6: 90, 80, 100, 80 5: 90, 60, 100, 60
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type)
    {
        case Iphone5s:
            return UIEdgeInsetsMake(40, 60, 60, 60);
        case Iphone6:
            return UIEdgeInsetsMake(60, 80, 80, 80);
        case Iphone6p:
            return UIEdgeInsetsMake(80, 100, 100, 100);
        default:
            return UIEdgeInsetsMake(40, 60, 60, 60);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type)
    {
        case Iphone5s:
            return 60.0f;
        case Iphone6:
            return 80.0f;
        case Iphone6p:
            return 100.0f;
        default:
            return 60.0f;
    }
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.list count]==[self.textCount integerValue])
    {
        return;
    }
    if (indexPath.item==[self.list count]-1)
    {
        __weak __typeof__(self) weakSelf = self;
        //load data
        NSInteger maxID=-1;
        for (DataForCell *data in self.list)
        {
            if ([data.text_id integerValue]>maxID)
            {
                maxID=[data.text_id integerValue];
            }
        }
        [DataForCell getTextList:^(NSArray *data, NSError *error)
        {
            if(data!=nil)
            {
                NSMutableArray *books=[[NSMutableArray alloc]initWithArray:self.list];
                //检查是否有重复
                for (DataForCell *tmp in data)
                {
                    for (DataForCell *cache in books)
                    {
                        if ([tmp.text_id integerValue]==[cache.text_id integerValue])
                        {
                            [books removeObject:cache];
                        }
                    }
                }
                [books addObjectsFromArray:data];
                self.list=nil;
                self.list=books;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.collectionView reloadData];
                });
            }
        } grade_id:self.grade_id text_id:[NSString stringWithFormat:@"%ld",maxID]];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TextBookCell *cell=(TextBookCell*)[collectionView cellForItemAtIndexPath:indexPath];
    DataForCell *book=self.list[indexPath.row];
    if (book.task!=nil||[book checkDatabase])//检查是否下载过
    {
        return;
    }
    //这里还没有处理下载出错的情况
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:book.downloadURL,@"url",nil];
    __weak __typeof__(self) weakSelf = self;
    DataForCell *data=self.list[indexPath.row];
    data.progressView=[[DAProgressOverlayView alloc]initWithFrame:cell.bounds];
    [data.progressView setHidden:NO];
    data.progressView.progress = 0;
    data.progressView.tag=PROGRESSVIEW_TAG;
    [cell.contentView addSubview:data.progressView];
    [data.progressView displayOperationWillTriggerAnimation];
    __block NSURLSessionTask *task=
    [NetworkingManager httpRequest:RTDownload url:RUCustom parameters:parameters
                          progress:^(NSProgress *downloadProgress)
     {
         if (downloadProgress)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [data.progressView setProgress:downloadProgress.fractionCompleted];
                 if (downloadProgress.fractionCompleted == 1.0000)
                 {
                     [data.progressView displayOperationDidFinishAnimation];
                     double delayInSeconds = data.progressView.stateChangeAnimationDuration;
                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                         [data.progressView removeFromSuperview];
                         data.progressView = nil;
                     });
                     NSLog(@"download complete");
                     if(data.progressView!=nil)
                         NSLog(@"progressView is not nil");
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
