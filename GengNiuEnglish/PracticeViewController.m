//
//  PracticeViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/20.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "PracticeViewController.h"


typedef NS_ENUM(NSInteger,StarNum)
{
    noStar=0,
    oneStar,
    twoStar,
    threeStar,
};

@interface PracticeViewController ()
{
    STKAudioPlayer *audioPlayer;
    NSInteger endTime;
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *recordAudioPlayer;
    NSMutableDictionary *recordSettings;
    NSMutableSet *recognitionResult;
    NSString *lmPath ;
    NSString *dicPath ;
    NSInteger playTextID;
    NSInteger playTextIndex;
    NSArray *currentWords;
    UITapGestureRecognizer *gestureRecognizer;
    NSString *currentCheckWord;
    MRProgressOverlayView *progressView;
//    NSTimer *timer;
}
@end

@implementation PracticeViewController
static NSString* cellIdentifierLyric=@"LyricViewCell";
- (IBAction)goBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate dismissView];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [audioPlayer pause];
    });
    
//    [self setPlayerTime:0 duration:0];
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
    
    self.MCSupportingView.delegate=self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self initRecorderSettings];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tableView:self.tableview didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    });
    
    
    playTextID=-1;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
-(void)setPlayerTime:(NSInteger)value duration:(NSInteger)duration index:(NSInteger)index
{
    double time=(double)value;
    [audioPlayer seekToTime:time/1000];
    NSInteger currentID=playTextID;
    __block BOOL fistTime=true;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, duration * NSEC_PER_MSEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (fistTime) {
            fistTime=false;
        }
        else
        {
            if (audioPlayer!=nil&&playTextID==currentID)
            {
                LyricViewCell *cell=[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                if(cell!=nil)
                {
                    [cell.playText setImage:[UIImage imageNamed:@"playTextWW"] forState:UIControlStateNormal];
                }
                [audioPlayer pause];
                self.PlayingText=false;
            }
            dispatch_source_cancel(timer);
        }
    });
    dispatch_resume(timer);
}

-(void)checkEndOfSentence
{
    if (endTime<=audioPlayer.progress*1000)
    {
        if (audioPlayer!=nil)
        {
            LyricViewCell *cell=[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playTextIndex inSection:0]];
            if(cell!=nil)
            {
                [cell.playText setImage:[UIImage imageNamed:@"playTextWW"] forState:UIControlStateNormal];
            }
            [audioPlayer pause];
            self.PlayingText=false;
        }
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LyricItem *item=[self.lyricItems lastObject];
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
    
    //hide dictionary
    [cell.cellContent setHidden:YES];
    
    [cell.playText setImage:[UIImage imageNamed:@"playTextWW"] forState:UIControlStateNormal];
    cell.lyricItem=self.lyricItems[indexPath.row];
    cell.index=indexPath.row;
    cell.delegate=self;
    cell.playText.hidden=YES;
    cell.playVoice.hidden=YES;
    [cell.cellContent setUserInteractionEnabled:NO];
    cell.cellText.textColor=[UIColor blackColor];
    cell.cellContent.textColor=[UIColor blackColor];
    [cell.star1 setImage:[UIImage imageNamed:@"star_unlight"]];
    [cell.star2 setImage:[UIImage imageNamed:@"star_unlight"]];
    [cell.star3 setImage:[UIImage imageNamed:@"star_unlight"]];
    switch (cell.lyricItem.stars) {
        case oneStar:
            [cell.star1 setImage:[UIImage imageNamed:@"star_light"]];
            break;
        case twoStar:
            [cell.star1 setImage:[UIImage imageNamed:@"star_light"]];
            [cell.star2 setImage:[UIImage imageNamed:@"star_light"]];
            break;
        case threeStar:
            [cell.star1 setImage:[UIImage imageNamed:@"star_light"]];
            [cell.star2 setImage:[UIImage imageNamed:@"star_light"]];
            [cell.star3 setImage:[UIImage imageNamed:@"star_light"]];
            break;
        default:
            break;
    }
    if (self.selectedIndex.row==cell.index)
    {
        cell.playText.hidden=NO;
        if (self.isPlayingText&&cell.index==playTextIndex)
        {
            [cell.playText setImage:[UIImage imageNamed:@"playText"] forState:UIControlStateNormal];
        }
        cell.cellText.textColor=[UIColor colorWithRed:2/255.f green:196/255.f blue:188/255.f alpha:1.0];
        cell.cellContent.textColor=[UIColor colorWithRed:2/255.f green:196/255.f blue:188/255.f alpha:1.0];
        gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapped:)];
        gestureRecognizer.numberOfTapsRequired=1;
        [cell.cellContent addGestureRecognizer:gestureRecognizer];
    }
    return cell;
}

- (CGFloat)tableView:(__unused UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LyricItem *iterm=self.lyricItems[indexPath.row];
    NSString *content=iterm.lyricBody;
    CGFloat width=[UIScreen mainScreen].bounds.size.width-95;
    CGFloat height=[CommonMethod calculateTextHeight:content width:width fontSize:16.0f];
    if ([indexPath compare:self.selectedIndex]==NSOrderedSame)
    {
        return height+50.0f;
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    for (LyricViewCell *cell in [tableView visibleCells])
    {
        cell.playText.hidden=YES;
        if (self.isPlayingText&&cell.index==playTextIndex)
        {
            [cell.playText setImage:[UIImage imageNamed:@"playText"] forState:UIControlStateNormal];
        }
        else
            [cell.playText setImage:[UIImage imageNamed:@"playTextWW"] forState:UIControlStateNormal];
        if (cell.index!=indexPath.row)
        {
            LyricItem *item=self.lyricItems[cell.index];
            cell.cellText.text=item.lyricBody;
            cell.cellText.textColor=[UIColor blackColor];
            cell.cellContent.textColor=[UIColor blackColor];
            [cell.cellContent setUserInteractionEnabled:NO];
            //delete gesture detect
            [cell.cellContent removeGestureRecognizer:gestureRecognizer];
        }
        if (cell.index==indexPath.row)
        {
            cell.playText.hidden=NO;
            cell.cellText.textColor=[UIColor colorWithRed:2/255.f green:196/255.f blue:188/255.f alpha:1.0];
            cell.cellContent.textColor=[UIColor colorWithRed:2/255.f green:196/255.f blue:188/255.f alpha:1.0];
            [cell.cellContent setUserInteractionEnabled:YES];
            
            //添加动作监控
            gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapped:)];
            gestureRecognizer.numberOfTapsRequired=1;
            [cell.cellContent addGestureRecognizer:gestureRecognizer];
        }
    }
    if ([indexPath compare:self.selectedIndex]!=NSOrderedSame)
    {
        [self stopCellWorking];
        self.selectedIndex=indexPath;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView endUpdates];
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell removeGestureRecognizer:gestureRecognizer];
}
-(void)textViewTapped:(id)sender
{
    LyricViewCell *cell;
    for (LyricViewCell *tmp in [self.tableview visibleCells])
    {
        if(tmp.index==self.selectedIndex.row)
        {
            cell=tmp;
        }
    }
    if (cell==nil)
    {
        return;
    }
    UIMenuController *menucontroller=[UIMenuController sharedMenuController];
    
    if (menucontroller.isMenuVisible)
    {
        [menucontroller setMenuVisible:NO animated:YES];
        return;
    }
    
    NSLog(@"Clicked");
    
    CGPoint pos = [sender locationInView:cell.cellContent];
    CGPoint menuPos=[sender locationInView:self.MCSupportingView];
    UITextView *_tv = cell.cellContent;
    
    NSLog(@"Tap Gesture Coordinates: %.2f %.2f", pos.x, pos.y);
    
    //eliminate scroll offset
    pos.y += _tv.contentOffset.y;
    
    //get location in text from textposition at point
    UITextPosition *tapPos = [_tv closestPositionToPoint:pos];
    
    //fetch the word at this position (or nil, if not available)
    UITextRange * wr = [_tv.tokenizer rangeEnclosingPosition:tapPos withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    [_tv setSelectedTextRange:wr];
    NSLog(@"WORD: %@ %@", [_tv textInRange:wr],wr);
    
    if (wr==nil)
    {
        return;
    }
    
    currentCheckWord=[_tv textInRange:wr];
    
    UIMenuItem *MenuitemA=[[UIMenuItem alloc] initWithTitle:@"查字典" action:@selector(define)];
    
    UIMenuItem *MenuitemB=[[UIMenuItem alloc] initWithTitle:@"加入生词本" action:@selector(addToUnknow)];
    
    [menucontroller setMenuItems:[NSArray arrayWithObjects:MenuitemA,MenuitemB,nil]];
    
    //It's mandatory
    
    [self.MCSupportingView becomeFirstResponder];
    
    //It's also mandatory ...remeber we've added a mehod on view class
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([self.MCSupportingView canBecomeFirstResponder])
        {
            
            [menucontroller setTargetRect:CGRectMake(menuPos.x,menuPos.y, 0, 0) inView:self.view];
            
            [menucontroller setMenuVisible:YES animated:YES];
        }
    });
}
-(void)viewWillDisappear:(BOOL)animated
{
    if (progressView!=nil)
    {
        [progressView dismiss:NO];
        progressView=nil;
    }
}
-(void)define
{
   progressView=[MRProgressOverlayView showOverlayAddedTo:self.view title:@"正在查询单词" mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIReferenceLibraryViewController* ref =
        [[UIReferenceLibraryViewController alloc] initWithTerm:currentCheckWord];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:ref animated:YES completion:nil];
        });
    });
    
    
}
-(void)addToUnknow
{
    
}


-(void)stopCellWorking
{
    for (LyricViewCell *cell in [self.tableview visibleCells])
    {
        if (cell.index!=self.selectedIndex.row)
        {
            cell.playVoice.hidden=YES;
        }
    }
    LyricViewCell *cell=[self.tableview cellForRowAtIndexPath:self.selectedIndex];
    if (cell!=nil)
    {
        if (cell.recording)
        {
            [cell recordVoiceClick:nil];
        }
        if (cell.recordPlaying)
        {
            [cell playVoiceClick:nil];
        }
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopCellWorking];
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
-(void)initRecorder:(NSInteger)index words:(NSArray *)words
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryRecord error:&err];
    if (recognitionResult!=nil)
    {
        recognitionResult=nil;
    }
    recognitionResult=[[NSMutableSet alloc]init];
    NSError *error;
    NSURL *soundFileURL=[NSURL URLWithString:[CommonMethod getPath:[NSString stringWithFormat:@"sound%ld.wav",index]]];
    NSLog(@"log for path:%@",soundFileURL.absoluteString);
    audioRecorder = [[AVAudioRecorder alloc]
                     initWithURL:soundFileURL
                     settings:recordSettings
                     error:&error];
    if (error)
    {
        
    } else
    {
        [audioRecorder prepareToRecord];
        [audioRecorder record];
    }
    currentWords=words;
    [self generateLM:words index:index];
//    [self runRecognition:index];
}
-(void)stopRecorder:(NSArray*)words index:(NSInteger)index
{
    [audioRecorder stop];
    [self runRecognition:index];
    LyricViewCell *cell=[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.lyricItem.stars=0;
    cell.playVoice.hidden=NO;
    [cell.star1 setImage:[UIImage imageNamed:@"star_unlight"]];
    [cell.star2 setImage:[UIImage imageNamed:@"star_unlight"]];
    [cell.star3 setImage:[UIImage imageNamed:@"star_unlight"]];
}
-(void)playRecord:(NSInteger)index
{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    NSError* err;
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&err];
    if (recordAudioPlayer!=nil)
    {
        recordAudioPlayer=nil;
    }
    NSURL *path=[NSURL URLWithString:[CommonMethod getPath:[NSString stringWithFormat:@"sound%ld.wav",index]]];
    NSFileManager *fileMagager=[NSFileManager defaultManager];
    if ([fileMagager fileExistsAtPath:path.absoluteString])
    {
        recordAudioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:path error:nil];
        recordAudioPlayer.delegate=self;
        [recordAudioPlayer play];
    }
    else
    {
        [self stopCellWorking];
    }
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopCellWorking];
}
-(void)stopRecorderPlaying
{
    [recordAudioPlayer stop];
}
-(void)generateLM:(NSArray *)words index:(NSInteger)index
{
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    NSDictionary *grammar=@{OneOfTheseCanBeSaidWithOptionalRepetitions:words};
    NSString *name = [NSString stringWithFormat:@"GrammarLM%ld",index];
    NSLog(@"log for words:%@",words);
    NSError *err =[lmGenerator generateGrammarFromDictionary:grammar withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if(err == nil) {
        lmPath = [lmGenerator pathToSuccessfullyGeneratedGrammarWithRequestedName:name];
        dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:name];
        
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
}
-(void)runRecognition:(NSInteger)index
{
    if(![OEPocketsphinxController sharedInstance].isListening) {
        //设置输出音频数据
//        [[OEPocketsphinxController sharedInstance] setVerbosePocketSphinx:YES];
        [[OEPocketsphinxController sharedInstance] setSecondsOfSilenceToDetect:0.3];
        [[OEPocketsphinxController sharedInstance] setVadThreshold:2.0];
        [[OEPocketsphinxController sharedInstance] setOutputAudio:YES];
        [[OEPocketsphinxController sharedInstance] setReturnNullHypotheses:YES];//返回空数据
        [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
        [[OEPocketsphinxController sharedInstance] runRecognitionOnWavFileAtPath:[CommonMethod getPath:[NSString stringWithFormat:@"sound%ld.wav",index]] usingLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:YES];
    }
    else
    {
//        [[OEPocketsphinxController sharedInstance] changeLanguageModelToFile:lmPath withDictionary:dicPath];
//        [[OEPocketsphinxController sharedInstance] resumeRecognition];
    }
}
-(void)playText:(NSInteger)index
{
//    if (self.isPlayingText)
//    {
//        return;
//    }
    playTextIndex=index;
    LyricViewCell *cell=[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if(cell!=nil)
    {
        [cell.playText setImage:[UIImage imageNamed:@"playText"] forState:UIControlStateNormal];
    }
    playTextID++;
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    NSError* err;
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&err];
    self.PlayingText=true;
    LyricItem *item=self.lyricItems[index];
    endTime=item.endTime;
    if (endTime==-1)
    {
        endTime=audioPlayer.duration*1000;
    }
    [self setPlayerTime:item.beginTime duration:endTime-item.beginTime index:index];
    
    //set the timer
//    if (timer!=nil)
//    {
//        [timer invalidate];
//    }
//    timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkEndOfSentence) userInfo:nil repeats:YES];
//    [timer fire];
    
    
    
    if (audioPlayer.state!=STKAudioPlayerStatePlaying)
    {
        [audioPlayer resume];
    }
}
-(BOOL)isPlayingText
{
    return self.PlayingText?YES:NO;
}
#pragma mark -
#pragma mark OEEventsObserver delegate methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    
    NSLog(@"Local callback: The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID); // Log it.
    NSArray *result=[hypothesis componentsSeparatedByString:@" "];
    if (result!=nil)
    {
        for (NSString *tmp in result)
        {
            if(![tmp isEqualToString:@""])
            [recognitionResult addObject:[tmp uppercaseString]];
        }
    }
    else
    {
        return;
    }
    NSMutableAttributedString *resultString=[[NSMutableAttributedString alloc]init];
    NSInteger correct=0;
    NSInteger wrong=0;
    for (NSString *tmp in currentWords)
    {
        NSAttributedString *word;
        NSDictionary *attributes;
        if ([recognitionResult containsObject:[tmp uppercaseString]])
        {
            attributes=[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
            word=[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",tmp] attributes:attributes];
            correct++;
        }
        else
        {
            attributes=[NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
            word=[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",tmp] attributes:attributes];
            wrong++;
        }
        [resultString appendAttributedString:word];
    }
    StarNum number;
    if (wrong>=correct)
    {
        number=oneStar;
    }
    else
    {
        number=twoStar;
        if (wrong<=2)
        {
            number=threeStar;
        }
    }
    for (LyricViewCell *cell in [self.tableview visibleCells])
    {
        if (cell.index==self.selectedIndex.row)
        {
            switch (number) {
                case oneStar:
                    [cell.star1 setImage:[UIImage imageNamed:@"star_light"]];
                    cell.lyricItem.stars=1;
                    break;
                case twoStar:
                    [cell.star1 setImage:[UIImage imageNamed:@"star_light"]];
                    [cell.star2 setImage:[UIImage imageNamed:@"star_light"]];
                    cell.lyricItem.stars=2;
                    break;
                case threeStar:
                    [cell.star1 setImage:[UIImage imageNamed:@"star_light"]];
                    [cell.star2 setImage:[UIImage imageNamed:@"star_light"]];
                    [cell.star3 setImage:[UIImage imageNamed:@"star_light"]];
                    cell.lyricItem.stars=3;
                    break;
                default:
                    break;
            }
        }
        
    }
    
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
@end
