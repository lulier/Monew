//
//  BookViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/19.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "BookViewController.h"

#define PROGRESSVIEW_TAG 1234

@interface BookViewController ()
{
    ReaderViewController *readerViewController;
    LyricViewController *lyricViewController;
    SCLAlertView *alert;
    NSInteger currentSelectIndex;
    NSOperationQueue *operationQueue;
    UIInterfaceOrientation currentOrientation;
}
@end

@implementation BookViewController

static NSString * const reuseIdentifierBook = @"TextBookCell";


-(void)initDatabase
{
    NSString *databasePath=[CommonMethod getPath:[NSString stringWithFormat:@"%@_user.sqlite",MONEWFOLDER]];
    FMDatabase *database=[FMDatabase databaseWithPath:databasePath];
    if (![database open])
    {
        NSLog(@"database open failed");
        return;
    }
    
    NSString *createTable=@"CREATE TABLE IF NOT EXISTS Books(BookID  integer,GradeID integer,BookName varchar(255),CoverURL varchar(512),Category integer,DownloadURL varchar(512),ZipName varchar(255),DocumentName varchar(255),LMName varchar(255),LRCName varchar(255),PDFName varchar(255),MP3Name varchar(255));";
    BOOL success=[database executeUpdate:createTable];
    if (!success)
    {
        NSLog(@"create table books failed");
        return;
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
-(void)loadCacheBooks
{
    __weak __typeof__(self) weakSelf = self;
    [DataForCell getCacheBooks:self.grade_id block:^(NSArray *data) {
        weakSelf.list=data;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
    }];
}
- (IBAction)goBackClick:(id)sender {
    self.list=nil;
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isLoading=false;
    // Register cell classes
    self.collectionView.delegate=self;
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setHidden:YES];
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"background"] scaledToSize:CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
    self.collectionView.backgroundView=[[UIImageView alloc]initWithImage:background];
//    [self initDatabase];
    if (!self.showCache) {
        [self reload:nil];
    }
    else
    {
        //read cache files
        [self loadCacheBooks];
    }
    currentSelectIndex=1;
    operationQueue=[[NSOperationQueue alloc]init];
}
-(void)viewDidAppear:(BOOL)animated
{
    
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
//    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    currentSelectIndex=index;
    DataForCell *book=self.list[index];
    if (book.task!=nil)
    {
        return;
    }
    //分成两次下载
    BOOL firstProgress=false;
    BOOL secondProgress=false;
    if (book.shouldDownloadFirst)
    {
        firstProgress=true;
    }
    else
        secondProgress=true;
    
    if (book.shouldDownloadFirst)
    {
        [self downloadFile:book downloadURL:book.downloadURL showProgress:firstProgress index:index];
    }
    
    if (book.shouldDownloadSecond)
    {
        [self downloadFile:book downloadURL:book.downloadURLSecond showProgress:secondProgress index:index];
    }
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //6s width:180 height:250 6s width:160 height:220 5 width:150 height:200
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type)
    {
        case Iphone5s:
            return CGSizeMake(190, 180);
        case Iphone6:
            return CGSizeMake(210, 200);
        case Iphone6p:
            return CGSizeMake(220, 230);
        default:
            return CGSizeMake(180, 170);
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //6s: 100, 100, 100, 100 6: 90, 80, 100, 80 5: 90, 60, 100, 60
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type)
    {
        case Iphone5s:
            return UIEdgeInsetsMake(60, 60, 60, 60);
        case Iphone6:
            return UIEdgeInsetsMake(70, 80, 80, 80);
        case Iphone6p:
            return UIEdgeInsetsMake(90, 100, 100, 100);
        default:
            return UIEdgeInsetsMake(60, 60, 60, 60);
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
    
    if ([self.list count]>=[self.textCount integerValue]||self.isLoading)
    {
        return;
    }
    if (indexPath.item==[self.list count]-1)
    {
        self.isLoading=true;
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
            self.isLoading=false;
            if(data!=nil)
            {
                NSMutableArray *books=[NSMutableArray arrayWithArray:self.list];
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
        } grade_id:self.grade_id text_id:[NSString stringWithFormat:@"%ld",(long)maxID]];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    currentSelectIndex=indexPath.row;
//    DataForCell *book=self.list[indexPath.row];
//    if (book.task!=nil)//检查是否下载过
//    {
//        return;
//    }
//    [book checkDatabase:^(BOOL existence) {
//        
//        if (!existence)
//        {
//            //分成两次下载
//            BOOL firstProgress=false;
//            BOOL secondProgress=false;
//            if (book.shouldDownloadFirst)
//            {
//                firstProgress=true;
//            }
//            else
//                secondProgress=true;
//            
//            if (book.shouldDownloadFirst)
//            {
//                [self downloadFile:book downloadURL:book.downloadURL showProgress:firstProgress index:indexPath.row ];
//            }
//                
//            if (book.shouldDownloadSecond)
//            {
//                [self downloadFile:book downloadURL:book.downloadURLSecond showProgress:secondProgress index:indexPath.row];
//            }
//            
//        }
//    }];
}

//加多一层，如果是需要更新进度则使用上面的方式，如果不需要则使用简单下载
-(void)downloadFile:(DataForCell*)book downloadURL:(NSString *)downloadURL showProgress:(BOOL)showProgress index:(NSInteger)index
{
    if (showProgress)
    {
        [self downloadWithProgress:book downloadURL:downloadURL index:index];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self downloadWithoutProgress:downloadURL index:index];
        });
    }
}
-(void)downloadWithProgress:(DataForCell*)book downloadURL:(NSString *)downloadURL index:(NSInteger)index
{
    TextBookCell *cell=(TextBookCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:downloadURL,@"url",nil];
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        book.progressView=[[DAProgressOverlayView alloc]initWithFrame:cell.bounds];
        [book.progressView setHidden:NO];
        book.progressView.progress = 0;
        book.progressView.tag=PROGRESSVIEW_TAG;
        [cell.contentView addSubview:book.progressView];
        [book.progressView displayOperationWillTriggerAnimation];
    });
    __block NSURLSessionTask *task=
    [NetworkingManager httpRequest:RTDownload url:RUCustom parameters:parameters
                          progress:^(NSProgress *progress)
     {
         if (progress)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [book.progressView setProgress:progress.fractionCompleted];
                 if (progress.fractionCompleted == 1.0000)
                 {
                     book.task=nil;
                     [book.progressView displayOperationDidFinishAnimation];
                     double delayInSeconds = book.progressView.stateChangeAnimationDuration;
                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                         [book.progressView removeFromSuperview];
                         book.progressView = nil;
                     });
                     NSLog(@"download complete");
                 }
             });
         }
     }
    success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
                               
    }
    failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
                               
    }
    completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error)
     {
         NSLog(@"log for download response:%@",response);
         NSLog(@"File downloaded to: %@", filePath.absoluteString);
         if (book.progressView!=nil)
         {
             [book.progressView removeFromSuperview];
             book.progressView=nil;
             book.task=nil;
         }
         if ([[NSFileManager defaultManager] fileExistsAtPath:[filePath.absoluteString substringFromIndex:7]]&&error==nil)
         {
            [weakSelf unzipDownloadFile:[filePath.absoluteString substringFromIndex:7] index:index];
         }
         else
         {
             if (alert==nil)
             {
                 alert=[[SCLAlertView alloc]init];
                 [alert showError:self title:@"错误" subTitle:@"下载失败，请重新尝试" closeButtonTitle:nil duration:1.0f];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     alert=nil;
                 });
             }
             
         }
     }];
    book.task=task;
}
-(void)downloadWithoutProgress:(NSString*)url index:(NSInteger)index
{
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:url,@"url", nil];
    [NetworkingManager httpRequest:RTDownload url:RUCustom parameters:parameters progress:^(NSProgress * _Nullable progress) {
        
    } success:nil failure:nil
    completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error)
     {
         NSLog(@"log for download response:%@",response);
         NSLog(@"File downloaded to: %@", filePath.absoluteString);
         if ([[NSFileManager defaultManager] fileExistsAtPath:[filePath.absoluteString substringFromIndex:7]]&&error==nil)
         {
             [self unzipDownloadFile:[filePath.absoluteString substringFromIndex:7] index:index];
         }
    }];
}


-(void)unzipDownloadFile:(NSString*)filePath index:(NSInteger)index
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *doctPath=[paths objectAtIndex:0];
        NSString *zipFileName=[[filePath componentsSeparatedByString:@"/"] lastObject];
        DataForCell *book=self.list[index];
        book.download_zipFileName=zipFileName;
        
        NOZDecompressRequest *request = [[NOZDecompressRequest alloc] initWithSourceFilePath:filePath destinationDirectoryPath:doctPath];
        
        NOZDecompressOperation *op = [[NOZDecompressOperation alloc] initWithRequest:request delegate:book];
        [operationQueue addOperation:op];
        
        
        
        
//       [SSZipArchive unzipFileAtPath:filePath toDestination:doctPath delegate:book];
    }
}

-(void)dismissReaderViewController:(ReaderViewController *)viewController
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isReaderView=false;
    [self dismissViewControllerAnimated:NO completion:NULL];
    TextBookCell *cell=(TextBookCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:currentSelectIndex inSection:0]];
    if (cell!=nil)
    {
        cell.readerViewController=nil;
    }
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
-(void)openBook:(NSString*)pdfPath index:(NSInteger)index
{
    DataForCell *book=self.list[index];
    NSString *textName=book.text_name;
    currentOrientation=[[UIApplication sharedApplication] statusBarOrientation];
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
        appDelegate.isReaderView=true;
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:pdfPath])
        {
            queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
            
            screenScale = [[UIScreen mainScreen] scale];
            
            ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
            fz_register_document_handlers(ctx);
            
            MuDocRef *doc;
            
            doc = [[MuDocRef alloc] initWithFilename:(char *)pdfPath.UTF8String];
            
            
            MuDocumentController *document = [[MuDocumentController alloc] initWithFilename:pdfPath path:(char *)pdfPath.UTF8String document: doc];
            document.delegate=self;
            document.textName=textName;
            [self.navigationController pushViewController:document animated:YES];
//            [currentVC presentViewController:document animated:YES completion:nil];
            
            
            
            
            
            
            
            //            ReaderDocument *document=[ReaderDocument withDocumentFilePath:pdfPath password:nil];
            //            readerViewController=[[ReaderViewController alloc]initWithReaderDocument:document];
            //            readerViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
            //            readerViewController.modalPresentationStyle=UIModalPresentationFullScreen;
            //            readerViewController.delegate=self.delegate;
            //            [currentVC presentViewController:readerViewController animated:YES completion:nil];
            
            
            
            
            
            
//            AccountManager *account=[AccountManager singleInstance];
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                [[StudyDataManager sharedInstance] prepareUploadStudyState:account.userID textID:self.book.text_id starCount:@"0" readCount:@"1" sentenceCount:@"0" listenCount:@"0" challengeScore:@"0"];
//            });
        }
    });
}
-(void)muPDFGoBack
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isReaderView=false;
    NSNumber *value = [NSNumber numberWithInt:currentOrientation];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [[self.navigationController navigationBar] setHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)didSelectWord:(NSString *)word
{
    NSLog(@"%@",word);
}

#pragma mark <UICollectionViewDelegate>

@end
