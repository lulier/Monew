//
//  MaterialCell.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "MaterialCell.h"
#import "CommonMethod.h"


@implementation MaterialCell



-(void)setMaterial:(DataForCell *)material
{
    _material=material;
    if (!_material)
    {
        NSLog(@"your material is nil");
    }
    [self.cellLabel setText:_material.text_name];
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type) {
        case Iphone5s:
            self.cellLabel.font=[UIFont italicSystemFontOfSize:15.0f];
            self.labelTopConstraint.constant=110;
            break;
        case Iphone6:
            self.labelTopConstraint.constant=120;
            self.cellLabel.font=[UIFont italicSystemFontOfSize:16.0f];
            break;
        case Iphone6p:
            self.labelTopConstraint.constant=140;
            self.cellLabel.font=[UIFont italicSystemFontOfSize:17.0f];
            break;
        default:
            break;
    }
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
    
}


- (void)awakeFromNib {
    // Initialization code
}
@end
