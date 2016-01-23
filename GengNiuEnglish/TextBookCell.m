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
}

-(void)setBook:(DataForCell *)book
{
    _book=book;
    if (!_book)
    {
        NSLog(@"your book is nil");
    }
    [self.cellImage setImageWithURL:[NSURL URLWithString:_book.cover_url] placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
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
@end
