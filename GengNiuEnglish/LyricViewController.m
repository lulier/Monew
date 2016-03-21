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
}
-(void)updateViewConstraints
{
    [super updateViewConstraints];
    //    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height);
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type) {
        case Iphone5s:
            self.imageViewTopConstraint.constant=20;
            break;
        case Iphone6:
            self.imageViewTopConstraint.constant=30;
            self.lyricTextAlignY.constant=15;
            break;
        case Iphone6p:
            self.imageViewTopConstraint.constant=40;
            self.lyricTextAlignY.constant=25;
            break;
        default:
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
        return;
    }
    NSLog(@"log for state:%ld",audioPlayer.state);
    switch (audioPlayer.state)
    {
        case STKAudioPlayerStateReady:
            [self startPlayMP3];
//            [self.playButton setTitle:@"pause" forState:UIControlStateNormal];
            break;
        case STKAudioPlayerStateStopped:
            [self startPlayMP3];
//            [self.playButton setTitle:@"pause" forState:UIControlStateNormal];
            break;
        case STKAudioPlayerStatePaused:
            [audioPlayer resume];
//            [self.playButton setTitle:@"pause" forState:UIControlStateNormal];
            break;
        case STKAudioPlayerStatePlaying:
            [audioPlayer pause];
//            [self.playButton setTitle:@"play" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
}

-(void)startPlayMP3
{
    NSString *path=[[self.book getDocumentPath] stringByAppendingPathComponent:[self.book getFileName:FTMP3]];
    NSURL *url=[NSURL fileURLWithPath:path];
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    [audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}
-(void)initWithBook:(DataForCell *)book
{
    endTime=0;
    self.book=book;
    NSString *filePath=[self.book getDocumentPath];
    filePath=[filePath stringByAppendingPathComponent:[self.book getFileName:FTLRC]];
    self.lyricItems=[LyricItem parseLyric:filePath];
    audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
    audioPlayer.meteringEnabled = YES;
    audioPlayer.volume = 1;
    __weak __typeof(self)weakself=self;
    timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:weakself selector:@selector(updateControls) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.lyricText setText:[self getLyric]];
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
    [self playButtonClick:nil];
    __weak __typeof(self)weakSelf=self;
    [NetworkingManager downloadImage:[NSURL URLWithString:self.imageURL] block:^(UIImage * _Nullable image) {
        [weakSelf.coverImageView setImage:image];
        weakSelf.coverImageView.alpha=0.3f;
    }];
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
        [self.lyricText setText:[self getLyric]];
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
//            NSLog(@"endTime:%ld progress:%f",item.endTime,audioPlayer.progress);
            content=item.lyricBody;
            endTime=item.endTime;
            break;
        }
    }
//    NSLog(@"%@",content);
    return content;
}
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    [self updateControls];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    [self updateControls];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    SampleQueueId* queueId = (SampleQueueId*)queueItemId;
    
    NSLog(@"Started: %@", [queueId.url description]);
    
    [self updateControls];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    [self updateControls];
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    [self updateControls];
    
    SampleQueueId* queueId = (SampleQueueId*)queueItemId;
    
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
