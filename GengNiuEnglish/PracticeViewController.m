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
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *recordAudioPlayer;
    NSMutableDictionary *recordSettings;
    NSMutableString *recognitionResult;
    NSString *lmPath ;
    NSString *dicPath ;
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
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_bg.png"]];
    [tempImageView setFrame:self.tableview.frame];
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.opaque = NO;
    self.tableview.backgroundView = tempImageView;
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.openEarsEventsObserver.delegate = self;
//    [self initRecorderSettings];
    [self generateLM];
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
    if([OEPocketsphinxController sharedInstance].isListening) { // Stop if we are currently listening.
            NSError *error = nil;
            error = [[OEPocketsphinxController sharedInstance] stopListening];
            if(error)NSLog(@"Error stopping listening in stopButtonAction: %@", error);
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
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(tableView.frame)-20, 100)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover_bg.png"]];
//    imageView.frame = ;
    [headerView addSubview: imageView];
    return headerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LyricViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierLyric forIndexPath:indexPath];
    if (!cell) {
        cell=[[LyricViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifierLyric];
    }
    // Configure the cell...
    cell.lyricItem=self.lyricItems[indexPath.row];
    cell.index=indexPath.row;
    cell.delegate=self;
    //clear cell color
//    cell.backgroundColor = [UIColor clearColor];
//    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(__unused UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:self.selectedIndex]==NSOrderedSame)
    {
        return 100.0f;
    }
    return 50.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    if (![indexPath compare:self.selectedIndex]==NSOrderedSame)
    {
        self.selectedIndex=indexPath;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView endUpdates];
}
-(void)initRecorderSettings
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    err = nil;
    [audioSession setActive:YES error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    recordSettings = [NSMutableDictionary dictionary];
    [recordSettings setValue: [NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    
    [recordSettings setValue: [NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    
    [recordSettings setValue: [NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    [recordSettings setValue: [NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    [recordSettings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    
    [recordSettings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    [recordSettings setValue: [NSNumber numberWithInt: AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
}
//lyricViewCellDelegate
//还没有区分不同文章的不同录音
//当前的heightlight从一个cell转到另一个cell的时候需要停止前一个cell的所有的录音，播放，识别
-(void)initRecorder:(NSInteger)index
{
    
    if (recognitionResult!=nil)
    {
        recognitionResult=nil;
    }
    recognitionResult=[[NSMutableString alloc]init];
    [self runRecognition:index];
}
-(void)stopRecorder
{
    [[OEPocketsphinxController sharedInstance] suspendRecognition];
}
-(void)playRecord:(NSInteger)index
{
    if (recordAudioPlayer!=nil)
    {
        recordAudioPlayer=nil;
    }
    NSURL *path=[NSURL URLWithString:[CommonMethod getPath:[NSString stringWithFormat:@"sound%ld.wav",index]]];
    NSFileManager *fileMagager=[NSFileManager defaultManager];
    if ([fileMagager fileExistsAtPath:path.absoluteString])
    {
        recordAudioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:path error:nil];
        [recordAudioPlayer play];
    }
}
-(void)stopRecorderPlaying
{
    [recordAudioPlayer stop];
}
-(void)generateLM
{
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    NSDictionary *words=@{OneOfTheseCanBeSaidWithOptionalRepetitions:@[@"A",@"SAD",@"DAY",@"IN",@"YELLOWSTONE"]};
    NSString *name = @"testLM";
//    NSError *err=[lmGenerator generateLanguageModelFromTextFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"txt"] withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
//    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    NSError *err =[lmGenerator generateGrammarFromDictionary:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if(err == nil) {
        
        lmPath = [lmGenerator pathToSuccessfullyGeneratedGrammarWithRequestedName:@"testLM"];
        NSLog(@"log for path:%@",lmPath);
        dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"testLM"];
        
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
}
-(void)runRecognition:(NSInteger)index
{

    if(![OEPocketsphinxController sharedInstance].isListening) {
        //设置输出音频数据
        [[OEPocketsphinxController sharedInstance] setSecondsOfSilenceToDetect:0.3];
        [[OEPocketsphinxController sharedInstance] setVadThreshold:3.0];
        [[OEPocketsphinxController sharedInstance] setOutputAudio:YES];
        [[OEPocketsphinxController sharedInstance] setReturnNullHypotheses:YES];//返回空数据
        [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:TRUE]; // Start speech recognition if we aren't already listening.
    }
    else
    {
        [[OEPocketsphinxController sharedInstance] resumeRecognition];
    }
}
-(void)playText:(NSInteger)index
{
    LyricItem *item=self.lyricItems[index];
    endTime=item.endTime;
    [self setPlayerTime:item.beginTime];
    if (audioPlayer.state!=STKAudioPlayerStatePlaying)
    {
        [audioPlayer resume];
    }
}
#pragma mark -
#pragma mark OEEventsObserver delegate methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    
    NSLog(@"Local callback: The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID); // Log it.
    [recognitionResult appendString:hypothesis];
    self.testReconition.text=recognitionResult;
}



// An optional delegate method of OEEventsObserver which informs that Pocketsphinx is now listening for speech.
- (void) pocketsphinxDidStartListening {
    
    NSLog(@"Local callback: Pocketsphinx is now listening."); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected speech and is starting to process it.
- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Local callback: Pocketsphinx has detected speech."); // Log it.
    
}

// An optional delegate method of OEEventsObserver which informs that the Pocketsphinx recognition loop has entered its actual loop.
// This might be useful in debugging a conflict between another sound class and Pocketsphinx.
- (void) pocketsphinxRecognitionLoopDidStart {
    
    NSLog(@"Local callback: Pocketsphinx started."); // Log it.
    
}
// An optional delegate method of OEEventsObserver which informs that Pocketsphinx has exited its recognition loop, most
// likely in response to the OEPocketsphinxController being told to stop listening via the stopListening method.
- (void) pocketsphinxDidStopListening {
    NSLog(@"Local callback: Pocketsphinx has stopped listening."); // Log it.
}
- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
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
