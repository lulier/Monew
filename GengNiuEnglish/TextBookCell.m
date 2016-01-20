//
//  TextBookCell.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "TextBookCell.h"
#import "UIImageView+AFNetworking.h"

@implementation TextBookCell

-(void)setBook:(DataForCell *)book
{
    _book=book;
    if (!_book)
    {
        NSLog(@"your book is nil");
    }
    [self.cellLabel setText:@""];
    [self.cellImage setImageWithURL:[NSURL URLWithString:_book.cover_url] placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}


- (void)layoutSubviews {
    [super layoutSubviews];
}
@end
