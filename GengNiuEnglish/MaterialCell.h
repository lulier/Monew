//
//  MaterialCell.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DataForCell.h"
#import "NetworkingManager.h"

@interface MaterialCell : UICollectionViewCell
@property(strong,nonatomic)DataForCell *material;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@end
