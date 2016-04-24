//
//  PracticeViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/20.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DataForCell.h"
#import "LyricItem.h"
#import "STKAudioPlayer.h"
#import "CommonMethod.h"
#import "SampleQueueId.h"
#import "LyricViewCell.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEEventsObserver.h>
#import <OpenEars/OELogging.h>
#import "MenuControllerSupportingView.h"
#import "MRProgress.h"




@interface PracticeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,lyricViewCellDelegate,OEEventsObserverDelegate,AVAudioPlayerDelegate>
@property(nonatomic,strong)NSArray *lyricItems;
@property(weak,nonatomic)id<dismissDelegate>delegate;
@property(nonatomic,weak)DataForCell *book;
@property(nonatomic,strong)NSIndexPath *selectedIndex;
@property (nonatomic, strong) OEEventsObserver *openEarsEventsObserver;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIButton *goBack;
@property (weak, nonatomic) IBOutlet UILabel *testReconition;
@property (weak, nonatomic) IBOutlet MenuControllerSupportingView *MCSupportingView;
@property(nonatomic)BOOL PlayingText;
-(void)initWithBook:(DataForCell*)book;
@end
