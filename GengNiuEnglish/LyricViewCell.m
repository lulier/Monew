//
//  LyricViewCell.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/20.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "LyricViewCell.h"

@implementation LyricViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    return self;
}
-(void)setLyricItem:(LyricItem *)lyricItem
{
    self.cellText.text=lyricItem.lyricBody;
//    self.cellText.frame=CGRectMake(10, 10, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
