//
//  LyricViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/30.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataForCell.h"
#import "LyricItem.h"
#import "STKAudioPlayer.h"
#import "CommonMethod.h"
#import "SampleQueueId.h"
#import "NetworkingManager.h"
#import <AVFoundation/AVFoundation.h>

@interface LyricViewController : UIViewController<STKAudioPlayerDelegate>
@property(nonatomic,strong)NSArray *lyricItems;


@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *lyricScrollView;
@property (weak, nonatomic) IBOutlet UILabel *lyricContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lyricContentHeight;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property(nonatomic,strong)NSString *imageURL;
@property(weak,nonatomic)id<dismissDelegate>delegate;
@property(nonatomic,weak)DataForCell *book;
-(void)initWithBook:(DataForCell*)book;
@end
