//
//  LyricViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/30.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import "LyricViewController.h"




@interface LyricViewController ()
@end

@implementation LyricViewController
{
    STKAudioPlayer *audioPlayer;
    NSTimer *timer;
    NSInteger endTime;
    NSInteger playTimes;
    BOOL isPlaying;
}
-(void)updateViewConstraints
{
    [super updateViewConstraints];
    //    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height);
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type) {
        case Iphone5s:
            self.lyricContent.font=[self.lyricContent.font fontWithSize:24.0f];
            self.titleTopConstraint.constant=4;
            break;
        case Iphone6:
            self.lyricContent.font=[self.lyricContent.font fontWithSize:25.0f];
            self.titleTopConstraint.constant=7;
            break;
        case Iphone6p:
            self.lyricContent.font=[self.lyricContent.font fontWithSize:26.0f];
            self.titleTopConstraint.constant=10;
            break;
        default:
            self.lyricContent.font=[self.lyricContent.font fontWithSize:23.0f];
            self.titleTopConstraint.constant=4;
            break;
    }
}
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate dismissView];
}
- (IBAction)playButtonClick:(id)sender {

    if (audioPlayer==nil)
    {
        audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
        audioPlayer.meteringEnabled = YES;
        audioPlayer.volume = 1;
        audioPlayer.delegate=self;
    }
    switch (audioPlayer.state)
    {
        case STKAudioPlayerStateReady:
            [self.playButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
            playTimes=[self getPlayTimes];
            [self startPlayMP3];
            break;
        case STKAudioPlayerStateStopped:
            [self.playButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
            playTimes=[self getPlayTimes];
            [self startPlayMP3];
            break;
        case STKAudioPlayerStatePaused:
            [audioPlayer resume];
            [self.playButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
            break;
        case STKAudioPlayerStatePlaying:
            [audioPlayer pause];
            [self.playButton setImage:[UIImage imageNamed:@"broadcast"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
}
- (IBAction)minusButtonClick:(id)sender {
    if (isPlaying)
    {
        //clear playing
        playTimes=0;
        [self stopPlayingMP3];
        isPlaying=false;
    }
    NSInteger currentTime=[self getPlayTimes];
    if (currentTime!=0)
    {
//        if (currentTime==INT_MAX)
//        {
//            currentTime=10;
//        }
        if (currentTime!=1)
        {
            currentTime--;
            self.timeLabel.text=[NSString stringWithFormat:@"%ld次",currentTime];
        }
    }
}
- (IBAction)plusButtonClick:(id)sender {
    if (isPlaying)
    {
        //clear playing
        playTimes=0;
        [self stopPlayingMP3];
        isPlaying=false;
    }
    NSInteger currentTime=[self getPlayTimes];
    if (currentTime!=0)
    {
        if (currentTime<9)
        {
            currentTime++;
            self.timeLabel.text=[NSString stringWithFormat:@"%ld次",currentTime];
        }
//        else
//        {
//            currentTime=INT_MAX;
//            self.timeLabel.text=@"∞ 次";
//        }
    }
}
-(NSInteger)getPlayTimes
{
    NSInteger currentTime=0;
    NSString *times=[self.timeLabel text];
    if ([times isEqualToString:@"∞ 次"])
    {
        currentTime=INT_MAX;
        return currentTime;
    }
    NSArray *tmp=[times componentsSeparatedByString:@"次"];
    currentTime=[[tmp firstObject] integerValue];
    return currentTime;
}
-(void)startPlayMP3
{
    endTime=0;
    isPlaying=true;
     __weak __typeof(self)weakself=self;
    timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:weakself selector:@selector(updateControls) userInfo:nil repeats:YES];
    [timer fire];
    NSString *path=[[self.book getDocumentPath] stringByAppendingPathComponent:[self.book getFileName:FTMP3]];
    NSURL *url=[NSURL fileURLWithPath:path];
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    [audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}
-(void)stopPlayingMP3
{
//    NSLog(@"log for stop");
    //首先是判断当前的循环次数是否到了，如果已经循环结束，就不需要再开始播放，如果还需要继续播放则调用startplaymp3
    [timer invalidate];
    if (playTimes>0)
    {
        playTimes--;
    }
    if (playTimes!=0)
    {
        [self startPlayMP3];
    }
    else
    {
        [self.playButton setImage:[UIImage imageNamed:@"broadcast"] forState:UIControlStateNormal];
        if (audioPlayer!=nil)
        {
            [audioPlayer stop];
        }
    }
    
}
-(void)initWithBook:(DataForCell *)book
{
    self.book=book;
    NSString *filePath=[self.book getDocumentPath];
    filePath=[filePath stringByAppendingPathComponent:[self.book getFileName:FTLRC]];
    self.lyricItems=[LyricItem parseLyric:filePath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.lyricContent setText:[self getLyric]];
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
//    [self playButtonClick:nil];
    NSError *categoryError = nil;
    [[AVAudioSession sharedInstance]
     setCategory:AVAudioSessionCategoryPlayback
     error:&categoryError];
    if (categoryError) {
        NSLog(@"Error setting category!");
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidDisappear:(BOOL)animated
{
    [timer invalidate];
    if (audioPlayer!=nil)
    {
        [audioPlayer stop];
        audioPlayer.delegate=nil;
        audioPlayer=nil;
    }
}
-(void)updateControls
{
    if (audioPlayer==nil)
    {
        return;
    }
    if (endTime<=audioPlayer.progress*1000)
    {
        [self.lyricContent setText:[self getLyric]];
//        if (audioPlayer.progress!=0)
//        {
//            [self playButtonClick:nil];
//        }
    }
}
//每次改变播放时间的时候将endtime置空，在updatecontrol的时候再去找对应的endtime，每次进到updatecontrol的时候如果current time没到end time的话就返回，如果到达endtime就从新找对应的字幕，同时更新endtime
-(void)setPlayerTime:(NSInteger)value
{
    [audioPlayer seekToTime:value];
    endTime=0;
}
-(NSString*)getLyric
{
    NSString *content;
    for (LyricItem *item in self.lyricItems)
    {
        if (item.endTime>=audioPlayer.progress*1000)
        {
            content=item.lyricBody;
            endTime=item.endTime;
            break;
        }
    }
    if (content!=nil)
    {
        CGFloat height=[CommonMethod calculateTextHeight:content width:self.lyricScrollView.frame.size.width fontSize:24.f];
        if (height<self.lyricScrollView.frame.size.height)
        {
            self.lyricContentHeight.constant=self.lyricScrollView.frame.size.height;
        }
        else
            self.lyricContentHeight.constant=height;
        self.lyricScrollView.contentInset=UIEdgeInsetsMake(10, 0, 0, 0);
    }
    return content;
}
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    SampleQueueId* queueId = (SampleQueueId*)queueItemId;
    
//    NSLog(@"Started: %@", [queueId.url description]);
    
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    if(isPlaying)
    {
        AccountManager *account=[AccountManager singleInstance];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[StudyDataManager sharedInstance] prepareUploadStudyState:account.userID textID:self.book.text_id starCount:@"0" readCount:@"0" sentenceCount:@"0" listenCount:@"1" challengeScore:@"0"];
        });
    }
    SampleQueueId* queueId = (SampleQueueId*)queueItemId;
    [self stopPlayingMP3];
    NSLog(@"Finished: %@", [queueId.url description]);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
