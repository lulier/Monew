//
//  TextBookCell.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "TextBookCell.h"
#import "MTImageGetter.h"
#import "MuDocRef.h"
#import "MuDocumentController.h"
#include "mupdf/fitz.h"
#include "common.h"



@implementation TextBookCell
{
    LyricViewController *lyricViewController;
    PracticeViewController *practiceViewController;
    
}
@synthesize readerViewController;
-(id)init
{
    if ((self = [super init])) {
        
    }
    return self;
}
-(void)setBook:(DataForCell *)book
{
    _book=book;
    if (!_book)
    {
        NSLog(@"your book is nil");
    }
    __weak __typeof__(self) weakSelf = self;
//    [self.cellImage setImageWithURL:[NSURL URLWithString:book.cover_url] placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
    self.cellImage.downloadName=nil;
    NSString *cacheKey=[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:book.cover_url]];
    MTImageGetter *imageGetter=[[MTImageGetter alloc]initWithImageView:self.cellImage imageName:cacheKey downloadURL:[NSURL URLWithString:book.cover_url]];
    [imageGetter getImageComplete:^(UIImage *image) {
        [weakSelf.cellImage setImage:image];
    }];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ClickCover)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.cancelsTouchesInView=NO;
    [self.cellImage addGestureRecognizer:singleTap];
    [self.cellImage setUserInteractionEnabled:YES];
    
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type) {
        case Iphone5s:
            self.labelTopConstraint.constant=100;
            break;
        case Iphone6:
            self.labelTopConstraint.constant=110;
            break;
        case Iphone6p:
            self.labelTopConstraint.constant=135;
            [self.xiuLian.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
            [self.moErDuo.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
            [self.chuangGuan.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
            break;
        default:
            self.labelTopConstraint.constant=93;
            break;
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}
-(void)dismissView
{
    lyricViewController=nil;
    practiceViewController=nil;
}
- (IBAction)xiulianClick:(id)sender {
    [self.book checkDatabase:^(BOOL existence) {
        if (!existence)
        {
            NSLog(@"the book is nil");
            [self.delegate clickCellButton:self.index];
        }
        else
            [self openBook];
    }];
    
}
- (IBAction)moErDuoClick:(id)sender {
    [self.book checkDatabase:^(BOOL existence) {
        if (!existence)
        {
            NSLog(@"the book is nil");
            [self.delegate clickCellButton:self.index];
        }
        else
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                lyricViewController=[storyboard instantiateViewControllerWithIdentifier:@"LyricViewController"];
                [lyricViewController initWithBook:self.book];
                lyricViewController.delegate=self;
                lyricViewController.imageURL=self.book.cover_url;
                UINavigationController *navigationController=(UINavigationController*)self.window.rootViewController;
                [navigationController pushViewController:lyricViewController animated:YES];
            });
        }
    }];
    
}
- (IBAction)chuangGuanClick:(id)sender {
    [self.book checkDatabase:^(BOOL existence) {
        if (!existence)
        {
            NSLog(@"the book is nil");
            [self.delegate clickCellButton:self.index];
        }
        else
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                practiceViewController=[storyboard instantiateViewControllerWithIdentifier:@"PracticeViewController"];
                [practiceViewController initWithBook:self.book];
                practiceViewController.delegate=self;
                UINavigationController *navigationController=(UINavigationController*)self.window.rootViewController;
                [navigationController pushViewController:practiceViewController animated:YES];
            });
        }
    }];
    
}
-(void)ClickCover
{
    [self.book checkDatabase:^(BOOL existence) {
        if (!existence)
        {
            NSLog(@"the book is nil");
            [self.delegate clickCellButton:self.index];
        }
        else
        {
            [self openBook];
        }
    }];
}
-(void)openBook
{
    NSString *pdfName=[self.book getFileName:FTPDF];
    NSString *pdfPath=[[self.book getDocumentPath] stringByAppendingPathComponent:pdfName];
    [self.delegate openBook:pdfPath index:self.index];
    return;
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
        appDelegate.isReaderView=true;
        UIViewController *currentVC=[CommonMethod getCurrentVC];
        if ([[NSFileManager defaultManager]fileExistsAtPath:pdfPath])
        {
            queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
            
            screenScale = [[UIScreen mainScreen] scale];
            
            ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
            fz_register_document_handlers(ctx);
            
            NSString *file = [[NSBundle mainBundle] pathForResource:@"hello-world" ofType:@"pdf"];
            MuDocRef *doc;
            
            doc = [[MuDocRef alloc] initWithFilename:(char *)file.UTF8String];
            
            
            MuDocumentController *document = [[MuDocumentController alloc] initWithFilename:file path:(char *)file.UTF8String document: doc];
//            MuDocRef *doc;
//            
//            doc = [[MuDocRef alloc] initWithFilename:(char *)pdfPath.UTF8String];
//            
//            
//            MuDocumentController *document = [[MuDocumentController alloc] initWithFilename:pdfPath path:(char *)pdfPath.UTF8String document: doc];
            
            [currentVC presentViewController:document animated:YES completion:nil];
            
            
            
            
            
            
            
//            ReaderDocument *document=[ReaderDocument withDocumentFilePath:pdfPath password:nil];
//            readerViewController=[[ReaderViewController alloc]initWithReaderDocument:document];
//            readerViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
//            readerViewController.modalPresentationStyle=UIModalPresentationFullScreen;
//            readerViewController.delegate=self.delegate;
//            [currentVC presentViewController:readerViewController animated:YES completion:nil];
            
            
            
            
            
            
            AccountManager *account=[AccountManager singleInstance];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[StudyDataManager sharedInstance] prepareUploadStudyState:account.userID textID:self.book.text_id starCount:@"0" readCount:@"1" sentenceCount:@"0" listenCount:@"0" challengeScore:@"0"];
            });
        }
    });
}

-(void)dismissReaderViewController:(ReaderViewController *)viewController
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isReaderView=false;
    [[CommonMethod getCurrentVC] dismissViewControllerAnimated:readerViewController completion:nil];
    readerViewController=nil;
}
@end
