//
//  MaterialCell.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "MaterialCell.h"


@implementation MaterialCell



-(void)setMaterial:(DataForCell *)material
{
    _material=material;
    if (!_material)
    {
        NSLog(@"your material is nil");
    }
    [self.cellLabel setText:_material.text_name];
    CGFloat screenHeight=[UIScreen mainScreen].bounds.size.height;
    self.cellLabel.font=[UIFont italicSystemFontOfSize:15.0f];
    if (screenHeight>320.0f)
    {
        if (screenHeight>375.0f)
        {
            self.cellLabel.font=[UIFont italicSystemFontOfSize:17.0f];
        }
        else
            self.cellLabel.font=[UIFont italicSystemFontOfSize:16.0f];
    }
    [self.cellImage setImage:[UIImage imageNamed:@"profile-image-placeholder"]];
    __weak __typeof__(self) weakSelf = self;
    [NetworkingManager downloadImage:[NSURL URLWithString:_material.cover_url] block:^(UIImage *image) {
        [weakSelf.cellImage setImage:image];
    }];
    
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

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
}


- (void)awakeFromNib {
    // Initialization code
}
@end
