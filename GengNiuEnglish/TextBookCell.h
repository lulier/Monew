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
#import "AccountManager.h"
#import "StudyDataManager.h"
enum
{
    ResourceCacheMaxSize = 1024<<20	/**< use at most 128M for resource cache */
};
@protocol textBookCellDelegate <NSObject>

-(void)clickCellButton:(NSInteger)index;
-(void)openBook:(NSString*)pdfPath;

@end


@interface TextBookCell : UICollectionViewCell<ReaderViewControllerDelegate,dismissDelegate>
@property(strong,nonatomic)DataForCell *book;
@property(nonatomic)NSInteger index;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UIButton *xiuLian;
@property (weak, nonatomic) IBOutlet UIButton *moErDuo;
@property (weak, nonatomic) IBOutlet UIButton *chuangGuan;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopConstraint;
@property(nonatomic,strong) ReaderViewController *readerViewController;
@property(weak,nonatomic)id<textBookCellDelegate,ReaderViewControllerDelegate>delegate;
- (IBAction)xiulianClick:(id)sender;
@end
