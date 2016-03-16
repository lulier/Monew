//
//  TextBookCell.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataForCell.h"
#import "LyricViewController.h"
#import "UIImageView+AFNetworking.h"
#import "CommonMethod.h"
#import "PracticeViewController.h"
#import "ReaderViewController.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NetworkingManager.h"



@interface TextBookCell : UICollectionViewCell<ReaderViewControllerDelegate,dismissDelegate>
@property(strong,nonatomic)DataForCell *book;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UIButton *xiuLian;
@property (weak, nonatomic) IBOutlet UIButton *moErDuo;
@property (weak, nonatomic) IBOutlet UIButton *chuangGuan;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *xiuLianTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moErDuoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chuangGuanTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chuangGuanRightConstraint;
- (IBAction)xiulianClick:(id)sender;
@end
