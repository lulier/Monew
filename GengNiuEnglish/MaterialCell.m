//
//  MaterialCell.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "MaterialCell.h"
#import "CommonMethod.h"
#import "MTImageGetter.h"


@implementation MaterialCell



-(void)setMaterial:(DataForCell *)material
{
    _material=material;
    if (!_material)
    {
        NSLog(@"your material is nil");
    }
    unichar chr[1] = {'\n'};
    NSString *singleCR = [NSString stringWithCharacters:(const unichar *)chr length:1];
    NSString *cellName=[material.text_name stringByReplacingOccurrencesOfString:@" " withString:singleCR];
    [self.cellLabel setText:cellName];
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type) {
        case Iphone5s:
            self.cellLabel.font=[UIFont italicSystemFontOfSize:15.0f];
            self.labelTopConstraint.constant=105;
            break;
        case Iphone6:
            self.labelTopConstraint.constant=115;
            self.cellLabel.font=[UIFont italicSystemFontOfSize:16.0f];
            break;
        case Iphone6p:
            self.labelTopConstraint.constant=135;
            self.cellLabel.font=[UIFont italicSystemFontOfSize:17.0f];
            break;
        default:
            break;
    }
    __weak __typeof__(self) weakSelf = self;
    NSString *cacheKey=[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:material.cover_url]];
    MTImageGetter *imageGetter=[[MTImageGetter alloc]initWithImageView:self.cellImage imageName:cacheKey downloadURL:[NSURL URLWithString:material.cover_url]];
    self.cellImage.downloadName=nil;
    [imageGetter getImageComplete:^(UIImage *image) {
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
