//
//  SettingCell.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/4/25.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "SettingCell.h"

@implementation SettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    
    return self;
}

- (IBAction)cellButtonClick:(id)sender {
    [self.delegate logoutButtonClick];
}

@end
