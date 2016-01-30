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


@interface TextBookCell : UICollectionViewCell<ReaderViewControllerDelegate,dismissDelegate>
@property(strong,nonatomic)DataForCell *book;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UIButton *xiuLian;
@property (weak, nonatomic) IBOutlet UIButton *moErDuo;
@property (weak, nonatomic) IBOutlet UIButton *chuangGuan;
- (IBAction)xiulianClick:(id)sender;
@end
