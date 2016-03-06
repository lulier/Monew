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
    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
    [downloader downloadImageWithURL:[NSURL URLWithString:_material.cover_url]
                             options:0
                            progress:^(NSInteger receivedSize, NSInteger expectedSize){
                                // progression tracking code
                            }
                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                               if (image && finished)
                               {
                                   // do something with image
                                   [self.cellImage setImage:image];
                                   NSString *cacheKey=[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:_material.cover_url]];
                                   [[SDImageCache sharedImageCache] storeImage:self.cellImage.image forKey:cacheKey];
                               }
                               else
                               {
                                   NSString *cacheKey=[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:_material.cover_url]];
                                   [[SDImageCache sharedImageCache] queryDiskCacheForKey:cacheKey done:
                                   ^(UIImage *image, SDImageCacheType cacheType) {
                                       if (image!=nil)
                                       {
                                           [self.cellImage setImage:image];
                                       }
                                       else
                                       {
                                           [self.cellImage setImage:[UIImage imageNamed:@"profile-image-placeholder"]];
                                       }
                                   }];
                               }
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
