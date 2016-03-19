//
//  TextBookCell.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "TextBookCell.h"


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
    
    [self.cellImage setImage:[UIImage imageNamed:@"profile-image-placeholder"]];
    __weak __typeof__(self) weakSelf = self;
    
    [NetworkingManager downloadImage:[NSURL URLWithString:_book.cover_url] block:^(UIImage *image) {
        [weakSelf.cellImage setImage:image];
    }];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openBook)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.cancelsTouchesInView=NO;
    [self.cellImage addGestureRecognizer:singleTap];
    [self.cellImage setUserInteractionEnabled:YES];
    self.labelTopConstraint.constant=110;
    if ([UIScreen mainScreen].bounds.size.height>320.0f)
    {
        self.labelTopConstraint.constant=120;
        if ([UIScreen mainScreen].bounds.size.height>375.0f) {
            self.labelTopConstraint.constant=140;
        }
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([UIScreen mainScreen].bounds.size.height<=320.0f)
    {
        self.xiuLian.frame=CGRectMake(self.xiuLian.frame.origin.x, self.xiuLian.frame.origin.y, 36.0f, 32.0f);
        self.moErDuo.frame=CGRectMake(self.moErDuo.frame.origin.x, self.moErDuo.frame.origin.y, 42.0f, 33.0f);
        self.chuangGuan.frame=CGRectMake(self.chuangGuan.frame.origin.x, self.chuangGuan.frame.origin.y, 36.0f, 32.0f);
        self.xiuLianTopConstraint.constant=-25;
        self.moErDuoTopConstraint.constant=-25;
        self.chuangGuanTopConstraint.constant=-25;
        self.chuangGuanRightConstraint.constant=-10;
        self.moErDuo.titleLabel.font=[UIFont italicSystemFontOfSize:13.0f];
    }
}
-(void)dismissView
{
    lyricViewController=nil;
}
- (IBAction)xiulianClick:(id)sender {
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
        [currentVC presentViewController:readerViewController animated:YES
                              completion:nil];
    }
}
-(void)dismissReaderViewController:(ReaderViewController *)viewController
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isReaderView=false;
    [[CommonMethod getCurrentVC] dismissViewControllerAnimated:NO completion:NULL];
    readerViewController=nil;
}
@end
