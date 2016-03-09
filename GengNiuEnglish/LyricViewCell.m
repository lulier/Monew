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
    if (self.recordPlaying)
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
    if (self.recording)
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
    [self.delegate playText:self.index];
}
@end
