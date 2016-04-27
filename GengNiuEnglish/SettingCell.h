//
//  SettingCell.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/4/25.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol settingCellDelegate <NSObject>

- (void)logoutButtonClick;

@end

@interface SettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *cellButton;
@property (weak, nonatomic) IBOutlet UIImageView *cellLeftImage;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property(nonatomic,weak)id<settingCellDelegate>delegate;

@end
