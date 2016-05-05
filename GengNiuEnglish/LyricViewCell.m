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
    CGFloat labelWidth=[UIScreen mainScreen].bounds.size.width-95;
    self.labelMaxWidth.constant=labelWidth;
    self.cellText.text=lyricItem.lyricBody;
    CGFloat width=labelWidth;
    CGFloat height=[CommonMethod calculateTextHeight:lyricItem.lyricBody width:width fontSize:16.f];
    self.cellContentWidth.constant=width;
    self.cellContentHeight.constant=height;
    [self.cellContent setText:lyricItem.lyricBody];
    //clear cell color
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    self.recording=false;
    self.recordPlaying=false;
    _lyricItem=lyricItem;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)recordVoiceClick:(id)sender {
    if (self.recordPlaying||[self.delegate isPlayingText])
    {
        return;
    }
    if (self.recording)
    {
        [self.recordVoice setTitle:@"录音" forState:UIControlStateNormal];
        [self.delegate stopRecorder:self.lyricItem.lyricWords index:self.index];
        self.recording=false;
        return;
    }
    self.recording=true;
    [self.recordVoice setTitle:@"停止录音" forState:UIControlStateNormal];
    [self.delegate initRecorder:self.index words:self.lyricItem.lyricWords];
}
- (IBAction)playVoiceClick:(id)sender {
    if (self.recording||[self.delegate isPlayingText])
    {
        return;
    }
    if (self.recordPlaying)
    {
        [self.playVoice setTitle:@"播放" forState:UIControlStateNormal];
        [self.delegate stopRecorderPlaying];
        self.recordPlaying=false;
        return;
    }
    self.recordPlaying=true;
    [self.playVoice setTitle:@"停止播放" forState:UIControlStateNormal];
    [self.delegate playRecord:self.index];
}
- (IBAction)playTextClick:(id)sender {
    if (self.recordPlaying||self.recording)
    {
        return;
    }
    [self.delegate playText:self.index];
}
- (IBAction)uploadButtonClick:(id)sender {
    [self.delegate uploadRecord:self.index score:self.lyricItem.stars sentence:self.lyricItem.lyricBody];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIView *subview in self.contentView.superview.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"SeparatorView"]) {
            subview.hidden = NO;
        }
    }
}

@end
