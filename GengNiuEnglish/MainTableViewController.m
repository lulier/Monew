//
//  MainTableViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/21.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import "MainTableViewController.h"
#import "DataForCell.h"
#import "TableViewCell.h"
#import "UIRefreshControl+AFNetworking.h"
#import "NetworkingManager.h"
#import "MRProgress.h"
#import <AVFoundation/AVFoundation.h>
#import "LyricViewController.h"
#import "FMDB.h"
#import "LyricItem.h"
#import "UIImageView+WebCache.h"




@interface MainTableViewController ()

@end

@implementation MainTableViewController
{
    ReaderViewController *readerViewController;
    LyricViewController *lyricViewController;
}

-(void)reload:(__unused id)sender{
    NSURLSessionTask *task=[DataForCell getTextList:^(NSArray *data, NSError *error) {
        if (!error) {
            self.list=data;
            [self.tableView reloadData];
        }
    }];
    [self.refreshControl setRefreshingWithStateOfTask:task];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = NSLocalizedString(@"Book List", nil);
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    self.tableView.rowHeight = 70.0f;
    
    [self.tableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"cellForList"];
    
    [self initDatabase];
    [self reload:nil];
}





-(void)initDatabase
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier=@"cellForList";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell=[[TableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.book=self.list[indexPath.row];
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(__unused UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DataForCell *book=self.list[indexPath.row];
    if ([book checkDatabase])//检查是否下载过
    {
        NSString *pdfName=[book getFileName:FTPDF];
        NSString *doctName=[book getFileName:FTDocument];
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *doctPath=[paths objectAtIndex:0];
        NSString *filePath=[doctPath stringByAppendingString:[NSString stringWithFormat:@"/%@/%@",doctName,pdfName]];
        
        
        //测试mp3
        
        [self playMP3:indexPath.row];
        return;
        
        
        BOOL exist=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (exist) {
            
            //打开pdf
            ReaderDocument *document=[ReaderDocument withDocumentFilePath:filePath password:nil];
            if (doctName!=nil)
            {
                readerViewController=[[ReaderViewController alloc]initWithReaderDocument:document];
                readerViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                readerViewController.modalPresentationStyle=UIModalPresentationFullScreen;
                readerViewController.delegate=self;
                [self presentViewController:readerViewController animated:YES
                                      completion:nil];
            }
            return;
        }
    }
    //这里还没有处理下载出错的情况
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:book.downloadURL,@"url",nil];
    __weak __typeof__(self) weakSelf = self;
    __block MRProgressOverlayView *progressView=[MRProgressOverlayView showOverlayAddedTo:self.view title:@"下载中" mode:MRProgressOverlayViewModeDeterminateCircular animated:YES];
    [NetworkingManager httpRequest:RTDownload url:RUCustom parameters:parameters
        progress:^(NSProgress *downloadProgress)
     {
         if (downloadProgress)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [progressView setProgress:downloadProgress.fractionCompleted];
                 if (downloadProgress.fractionCompleted == 1.0000) {
                     [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
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
        [weakSelf unzipDownloadFile:[filePath.absoluteString substringFromIndex:7] index:indexPath.row];
    }];
}
-(void)unzipDownloadFile:(NSString*)filePath index:(NSInteger)index
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doctPath=[paths objectAtIndex:0];
    NSString *zipFileName=[[filePath componentsSeparatedByString:@"/"] lastObject];
    DataForCell *book=self.list[index];
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



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
