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
    [self.cellImage setImage:[UIImage imageNamed:@"profile-image-placeholder"]];
    __weak __typeof__(self) weakSelf = self;
    
    [NetworkingManager downloadImage:[NSURL URLWithString:_material.cover_url] block:^(UIImage *image) {
        [weakSelf.cellImage setImage:image];
    }];
    

    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    self.cellImage.frame = CGRectMake(10.0f, 10.0f, 50.0f, 50.0f);
//    self.cellLabel.frame = CGRectMake(70.0f, 6.0f, 240.0f, 20.0f);
}


- (void)awakeFromNib {
    // Initialization code
}
@end
