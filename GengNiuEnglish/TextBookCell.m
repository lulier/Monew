//
//  TextBookCell.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "TextBookCell.h"
#import "MTImageGetter.h"



@implementation TextBookCell
{
    LyricViewController *lyricViewController;
    PracticeViewController *practiceViewController;
    ReaderViewController *readerViewController;
}
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
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openBook)];
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
    if (![self.book checkDatabase])
    {
        NSLog(@"the book is nil");
        [self.delegate clickCellButton:self.index];
        return;
    }
    [self openBook];
}
- (IBAction)moErDuoClick:(id)sender {
    if (![self.book checkDatabase])
    {
        NSLog(@"the book is nil");
        [self.delegate clickCellButton:self.index];
        return;
    }
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    lyricViewController=[storyboard instantiateViewControllerWithIdentifier:@"LyricViewController"];
    [lyricViewController initWithBook:self.book];
    lyricViewController.delegate=self;
    lyricViewController.imageURL=self.book.cover_url;
    UINavigationController *navigationController=(UINavigationController*)self.window.rootViewController;
    [navigationController pushViewController:lyricViewController animated:YES];
}
- (IBAction)chuangGuanClick:(id)sender {
    if (![self.book checkDatabase])
    {
        NSLog(@"the book is nil");
        [self.delegate clickCellButton:self.index];
        return;
    }
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    practiceViewController=[storyboard instantiateViewControllerWithIdentifier:@"PracticeViewController"];
    [practiceViewController initWithBook:self.book];
    practiceViewController.delegate=self;
    UINavigationController *navigationController=(UINavigationController*)self.window.rootViewController;
    [navigationController pushViewController:practiceViewController animated:YES];
}
-(void)openBook
{
    if (![self.book checkDatabase])
    {
        NSLog(@"the book is nil");
        [self.delegate clickCellButton:self.index];
        return;
    }
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isReaderView=true;
    UIViewController *currentVC=[CommonMethod getCurrentVC];
    NSString *doctName=[self.book getFileName:FTDocument];
    NSString *pdfName=[self.book getFileName:FTPDF];
    NSString *pdfPath=[[self.book getDocumentPath] stringByAppendingPathComponent:pdfName];
    ReaderDocument *document=[ReaderDocument withDocumentFilePath:pdfPath password:nil];
    if (doctName!=nil)
    {
        readerViewController=[[ReaderViewController alloc]initWithReaderDocument:document];
        readerViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        readerViewController.modalPresentationStyle=UIModalPresentationFullScreen;
        readerViewController.delegate=self;
        [currentVC presentViewController:readerViewController animated:YES completion:nil];
    }
}
-(void)dismissReaderViewController:(ReaderViewController *)viewController
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isReaderView=false;
    [[CommonMethod getCurrentVC] dismissViewControllerAnimated:readerViewController completion:nil];
    readerViewController=nil;
}
@end
