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

@interface LyricViewController : UIViewController<STKAudioPlayerDelegate>
@property(nonatomic,strong)NSArray *lyricItems;

@property (weak, nonatomic) IBOutlet UITextView *lyricText;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property(nonatomic,weak)DataForCell *book;
-(void)initWithBook:(DataForCell*)book;
@end
