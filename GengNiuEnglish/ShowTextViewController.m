//
//  ShowTextViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/5/2.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "ShowTextViewController.h"

@interface ShowTextViewController ()

@end

@implementation ShowTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.inVocabulary=false;
    self.wordLabel.text=self.word;
    unichar chr[1] = {'\n'};
    NSString *singleCR = [NSString stringWithCharacters:(const unichar *)chr length:1];
    if (self.chineseExplanation==nil||[self.chineseExplanation isEqualToString:@"not found"])
    {
        self.chineseExplanation=@"";
    }
    if (self.englishExplanation==nil||[self.englishExplanation isEqualToString:@"not found"])
    {
        self.englishExplanation=@"";
    }
    NSString *explanation=[NSString stringWithFormat:@"%@%@%@",self.chineseExplanation,singleCR,self.englishExplanation];
    self.explanationLabel.text=explanation;
    CGFloat height=[CommonMethod calculateTextHeight:explanation width:self.explanationLabel.frame.size.width fontSize:16.f];
    self.explanationHeight.constant=height;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapped:)];
    gestureRecognizer.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    
    //check whether the word is in database
    [self checkDatabase];
}
-(void)viewDidAppear:(BOOL)animated
{
    self.scrollView.contentSize=CGSizeMake(self.view.frame.size.width, self.explanationHeight.constant+50);
}
-(void)viewDidLayoutSubviews
{
    
}
-(void)textViewTapped:(id)sender
{
//    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)checkDatabase
{
    NSDictionary *where=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"'%@'",self.word],@"word",nil];
    [[MTDatabaseHelper sharedInstance] queryTable:@"Vocabulary" withSelect:@[@"*"] andWhere:where completion:^(NSMutableArray *resultsArray) {
        if (resultsArray!=nil&&[resultsArray count]!=0)
        {
            NSDictionary *tmp=[resultsArray firstObject];
            if ([self.word isEqualToString:[tmp objectForKey:@"word"]])
            {
                [self.addToUnknow setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
                self.inVocabulary=true;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addToUnknowClick:(id)sender {
    
    if (self.inVocabulary)
    {
        //delete from database
        [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"Vocabulary" withWhere:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"'%@'",self.word],@"word", nil]];
        [self.addToUnknow setImage:[UIImage imageNamed:@"uncollect"] forState:UIControlStateNormal];
        self.inVocabulary=false;
    }
    else
    {
        NSArray *colums=[[NSArray alloc]initWithObjects:@"word",nil];
        NSArray *values=[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"'%@'",self.word], nil];
        [[MTDatabaseHelper sharedInstance] insertToTable:@"Vocabulary" withColumns:colums andValues:values];
        [self.addToUnknow setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
        self.inVocabulary=true;
    }
    
}




@end
