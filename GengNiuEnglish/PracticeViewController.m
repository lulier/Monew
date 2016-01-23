//
//  PracticeViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/20.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "PracticeViewController.h"

@interface PracticeViewController ()
{
    STKAudioPlayer *audioPlayer;
    NSInteger endTime;
    NSTimer *timer;
}
@end

@implementation PracticeViewController
static NSString* cellIdentifierLyric=@"LyricViewCell";
- (IBAction)goBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate dismissView];
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
    [self setupMP3];
}
-(void)setupMP3
{
    NSString *path=[[self.book getDocumentPath] stringByAppendingPathComponent:[self.book getFileName:FTMP3]];
    NSURL *url=[NSURL fileURLWithPath:path];
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
    [audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
    [self setPlayerTime:0];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
    self.selectedIndex=[NSIndexPath indexPathForRow:0 inSection:0];
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
-(void)setPlayerTime:(NSInteger)value
{
    double time=(double)value;
    [audioPlayer seekToTime:time/1000];
    __weak __typeof(self)weakself=self;
    timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:weakself selector:@selector(updateControls) userInfo:nil repeats:YES];
    [timer fire];
}
-(void)updateControls
{
    if (audioPlayer==nil)
    {
        return;
    }
    if (endTime<=audioPlayer.progress*1000)
    {
        [timer invalidate];
        [audioPlayer pause];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.lyricItems count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LyricViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierLyric forIndexPath:indexPath];
    if (!cell) {
        cell=[[LyricViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifierLyric];
    }
    // Configure the cell...
    cell.lyricItem=self.lyricItems[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(__unused UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:self.selectedIndex]==NSOrderedSame)
    {
        return 100.0f;
    }
    return 60.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    LyricItem *item=self.lyricItems[indexPath.row];
    NSLog(@"%f",audioPlayer.progress);
    endTime=item.endTime;
    [self setPlayerTime:item.beginTime];
    if (audioPlayer.state!=STKAudioPlayerStatePlaying)
    {
        [audioPlayer resume];
    }
    if (![indexPath compare:self.selectedIndex]==NSOrderedSame)
    {
        self.selectedIndex=indexPath;
    }
    [tableView endUpdates];
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
