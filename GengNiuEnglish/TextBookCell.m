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
-(void)setBook:(DataForCell *)book
{
    _book=book;
    if (!_book)
    {
        NSLog(@"your book is nil");
    }
    [self.cellImage setImageWithURL:[NSURL URLWithString:_book.cover_url] placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openBook)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.cancelsTouchesInView=NO;
    [self.cellImage addGestureRecognizer:singleTap];
    [self.cellImage setUserInteractionEnabled:YES];
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}
-(void)dismissView
{
    lyricViewController=nil;
}
- (IBAction)xiulianClick:(id)sender {
    if (![self.book checkDatabase])
    {
        NSLog(@"the book is nil");
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
        return;
    }
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    lyricViewController=[storyboard instantiateViewControllerWithIdentifier:@"LyricViewController"];
    [lyricViewController initWithBook:self.book];
    lyricViewController.delegate=self;
    UINavigationController *navigationController=(UINavigationController*)self.window.rootViewController;
    [navigationController pushViewController:lyricViewController animated:YES];
}
- (IBAction)chuangGuanClick:(id)sender {
    if (![self.book checkDatabase])
    {
        NSLog(@"the book is nil");
        return;
    }
}
-(void)openBook
{
    if (![self.book checkDatabase])
    {
        NSLog(@"the book is nil");
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
