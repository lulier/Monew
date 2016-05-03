//
//  VocabularyViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/5/3.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "VocabularyViewController.h"


@interface VocabularyViewController ()
{
    ShowTextViewController *showView;
}
@end

@implementation VocabularyViewController

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    //    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height);
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type) {
        case Iphone5s:
            self.titleTopConstraint.constant=4;
            break;
        case Iphone6:
            self.titleTopConstraint.constant=7;
            break;
        case Iphone6p:
            self.titleTopConstraint.constant=10;
            break;
        default:
            self.titleTopConstraint.constant=4;
            break;
    }
}
-(void)viewDidLoad
{
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
    
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_bg.png"]];
    [tempImageView setFrame:self.tableView.frame];
//    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundView = tempImageView;

    self.tableView.layer.cornerRadius=15;
    self.tableView.layer.masksToBounds=YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self loadDatabase];
}
-(void)loadDatabase
{
    [[MTDatabaseHelper sharedInstance] queryTable:@"Vocabulary" withSelect:@[@"*"] andWhere:nil completion:^(NSMutableArray *resultsArray) {
        NSMutableArray *data=[[NSMutableArray alloc]init];
        for (NSDictionary *tmp in resultsArray)
        {
            [data addObject:[tmp objectForKey:@"word"]];
        }
        self.list=data;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [self.list count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"vocabularyViewCell" forIndexPath:indexPath];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"vocabularyViewCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text=self.list[indexPath.row];
    cell.backgroundColor=[UIColor clearColor];
    [cell setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showView!=nil)
    {
        showView=nil;
    }
    NSString *currentWord=self.list[indexPath.row];
    DictionaryDatabase *dictionary=[DictionaryDatabase sharedInstance];
    NSDictionary *where=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"'%@'",currentWord],@"WORD",nil];
    [dictionary queryTable:@"DICTIONARY" withSelect:@[@"*"] andWhere:where completion:^(NSMutableArray *resultsArray) {
        if (resultsArray!=nil&&[resultsArray count]!=0)
        {
            NSDictionary *dic=[resultsArray firstObject];
            NSMutableString *content=[NSMutableString stringWithString:[dic objectForKey:@"WORD"]];
            [content appendString:[dic objectForKey:@"CHINESEEXPLAIN"]];
            [content appendString:[dic objectForKey:@"ENGLISHEXPLAIN"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                showView=[storyboard instantiateViewControllerWithIdentifier:@"ShowTextViewController"];
                showView.word=[dic objectForKey:@"WORD"];
                showView.chineseExplanation=[dic objectForKey:@"CHINESEEXPLAIN"];
                showView.englishExplanation=[dic objectForKey:@"ENGLISHEXPLAIN"];
//                [self.navigationController pushViewController:showView animated:YES];
                [self.navigationController presentViewController:showView animated:YES completion:nil];
            });
            
        }
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
