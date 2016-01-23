//
//  LyricViewCell.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/20.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LyricItem.h"

@interface LyricViewCell : UITableViewCell
@property(strong,nonatomic)LyricItem *lyricItem;
@property (weak, nonatomic) IBOutlet UILabel *cellText;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier;
@end
