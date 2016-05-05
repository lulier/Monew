//
//  LyricViewCell.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/20.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LyricItem.h"
#import "CommonMethod.h"


@protocol lyricViewCellDelegate <NSObject>

-(void)initRecorder:(NSInteger)index words:(NSArray*)words;
-(void)stopRecorder:(NSArray*)words index:(NSInteger)index;
-(void)playRecord:(NSInteger)index;
-(void)stopRecorderPlaying;
-(void)runRecognition:(NSInteger)index;
-(void)playText:(NSInteger)index;
-(BOOL)isPlayingText;
-(void)uploadRecord:(NSInteger)index score:(NSInteger)score sentence:(NSString*)sentence;
@end

@interface LyricViewCell : UITableViewCell
@property(strong,nonatomic)LyricItem *lyricItem;
@property(nonatomic)NSInteger index;
@property(nonatomic)BOOL recording;
@property(nonatomic)BOOL recordPlaying;
@property (weak, nonatomic) IBOutlet UILabel *cellText;
@property (weak, nonatomic) IBOutlet UIButton *recordVoice;
@property (weak, nonatomic) IBOutlet UIButton *playVoice;
@property (weak, nonatomic) IBOutlet UIButton *playText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelMaxWidth;
@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
- (IBAction)recordVoiceClick:(id)sender;
- (IBAction)playVoiceClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *cellContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellContentWidth;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property(weak,nonatomic)id<lyricViewCellDelegate>delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier;
@end
