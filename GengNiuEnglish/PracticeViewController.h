//
//  PracticeViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/20.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataForCell.h"
#import "LyricItem.h"
#import "STKAudioPlayer.h"
#import "CommonMethod.h"
#import "SampleQueueId.h"
#import "LyricViewCell.h"

@interface PracticeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSArray *lyricItems;
@property(weak,nonatomic)id<dismissDelegate>delegate;
@property(nonatomic,weak)DataForCell *book;
@property(nonatomic,strong)NSIndexPath *selectedIndex;
@property (weak, nonatomic) IBOutlet UIButton *goBack;
-(void)initWithBook:(DataForCell*)book;
@end
