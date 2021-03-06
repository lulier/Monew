////
////  MTImageGetter.m
////  WeShare
////
////  Created by 俊健 on 15/9/16.
////  Copyright (c) 2015年 WeShare. All rights reserved.
////
//
#import "MTImageGetter.h"


@interface MTImageGetter ()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, strong) NSString *imageName;
@property(nonatomic,strong)NSURL *downloadURL;
@end

@implementation MTImageGetter

-(instancetype)initWithImageView:(UIImageView*)imageView  imageName:(NSString *)imageName downloadURL:(NSURL *)downloadURL
{
    if (self) {
        self = [super init];
        self.imageView = imageView;
        self.imageName = imageName;
        self.downloadURL=downloadURL;
    }
    return self;
}
-(void)getImage
{
    [self getImageComplete:NULL];
}

-(void)getImageComplete:(void (^)(UIImage* image))block
{
    UIImage *placeHolder =[UIImage imageNamed:@"profile-image-placeholder"];
    
    if(![self.imageView.downloadName isEqualToString:self.imageName]){
        [self.imageView sd_cancelCurrentImageLoad];
        self.imageView.downloadName = self.imageName;
    }
    else
        return;
//    NSLog(@"%@",self.imageView.downloadName);
    NSString *cacheKey=[[SDWebImageManager sharedManager] cacheKeyForURL:self.downloadURL];
    NSURL *downloadPath=[self.downloadURL copy];
    if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:cacheKey]])
    {
        downloadPath=[NSURL URLWithString:cacheKey];
    }
    [self.imageView sd_setImageWithURL:downloadPath placeholderImage:placeHolder options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                NSString *cacheKey=[[SDWebImageManager sharedManager] cacheKeyForURL:self.downloadURL];
                [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey];
            });
        }
    }];
    
    
//    [[SDImageCache sharedImageCache] queryDiskCacheForKey:cacheKey done:
//     ^(UIImage *image, SDImageCacheType cacheType) {
//         if (![self.imageView.downloadName isEqualToString:self.imageName])
//             return ;
//         if (image!=nil)
//         {
//             dispatch_async(dispatch_get_main_queue(),^{
//                 block(image);
//             });
//         }
//         else
//         {
//          
//             
//             SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
//             [downloader downloadImageWithURL:self.downloadURL
//                                      options:0
//                                     progress:^(NSInteger receivedSize, NSInteger expectedSize){
//                                         // progression tracking code
//                                     }
//                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
//                                        if (![self.imageView.downloadName isEqualToString:self.imageName])
//                                            return ;
//                                        if (image && finished)
//                                        {
//                                            // do something with image
//                                            dispatch_async(dispatch_get_main_queue(),^{
//                                                block(image);
//                                                NSString *cacheKey=[[SDWebImageManager sharedManager] cacheKeyForURL:self.downloadURL];
//                                                [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey];
//                                            });
//                                            
//                                        }
//                                    }];
//
//         }
//     }];
}

@end
