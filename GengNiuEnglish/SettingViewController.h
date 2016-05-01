//
//  SettingViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/4/25.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonMethod.h"
#import "AccountManager.h"
#import "SCLAlertView.h"
#import "SettingCell.h"
#import "BindPhoneViewController.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface SettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,settingCellDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *settingView;
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingViewLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingViewRight;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *portraitImage;
@property (weak, nonatomic) IBOutlet UIImageView *genderImage;

@end
