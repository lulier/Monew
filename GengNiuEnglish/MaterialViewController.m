//
//  MaterialViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/19.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "MaterialViewController.h"
#import "DataForCell.h"
#import "CommonMethod.h"
#import "MaterialCell.h"
#import "BookViewController.h"
#import "MTDatabaseHelper.h"
#import "CustomCollectionViewLayout.h"

@interface MaterialViewController ()

@end

@implementation MaterialViewController

static NSString * const reuseIdentifierMaterial = @"MaterialCell";


-(void)reload:(__unused id)sender{
    __weak __typeof__(self) weakSelf = self;
    [DataForCell queryGradeList:^(NSArray*cells){
        weakSelf.list=cells;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
    }];
    NSURLSessionTask *task=[DataForCell getGradeList:^(NSArray *data, NSError *error) {
        if(data!=nil)
        {
            weakSelf.list=data;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadData];
            });
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate=self;
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setHidden:YES];
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"background"] scaledToSize:CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
    self.collectionView.backgroundView=[[UIImageView alloc]initWithImage:background];
     self.automaticallyAdjustsScrollViewInsets = NO;
    [self initDatabase];
    [self reload:nil];
}
-(void)updateViewConstraints
{
    [super updateViewConstraints];
//    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height);
//    self.labelTopConstraint.constant=100;
//    if ([UIScreen mainScreen].bounds.size.height>320.0f)
//    {
//        self.labelTopConstraint.constant=120;
//    }
    
}

-(void)initDatabase
{
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"GradeList" indexesWithProperties:@[@"grade_id  INTEGER PRIMARY KEY UNIQUE",@"grade_name varchar(255)",@"cover_url varchar(512)",@"text_count integer"]];
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"TextList" indexesWithProperties:@[@"text_id  INTEGER PRIMARY KEY UNIQUE",@"grade_id  INTEGER",@"text_name varchar(255)",@"cover_url varchar(512)",@"courseware_url varchar(512)",@"desc varchar(255)",@"challenge_goal integer",@"challenge_score integer",@"listen_count integer",@"practise_goal integer",@"star_count integer",@"listen_goal integer",@"practise_count integer",@"version integer"]];
    return;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.list count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MaterialCell *cell = (MaterialCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierMaterial forIndexPath:indexPath];
    // Configure the cell
    cell.material=self.list[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //6s width:180 height:250 6s width:160 height:220 5 width:150 height:200
    CGFloat screenHeight=[UIScreen mainScreen].bounds.size.height;
    if (screenHeight>320.0f)
    {
        if (screenHeight>375.0f)
        {
            return CGSizeMake(180, 220);
        }
        return CGSizeMake(160, 200);
    }
    return CGSizeMake(150, 180);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //6s: 100, 100, 100, 100 6: 90, 80, 100, 80 5: 90, 60, 100, 60
    CGFloat screenHeight=[UIScreen mainScreen].bounds.size.height;
    if (screenHeight>320.0f)
    {
        if (screenHeight>375.0f)
        {
            return UIEdgeInsetsMake(80, 100, 100, 100);
        }
        return UIEdgeInsetsMake(80, 80, 100, 80);
    }
    return UIEdgeInsetsMake(80, 60, 100, 60);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    CGFloat screenHeight=[UIScreen mainScreen].bounds.size.height;
    if (screenHeight>320.0f)
    {
        if (screenHeight>375.0f)
        {
            return 100.0f;
        }
        return 80.0f;
    }
    return 60.0f;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Prepare for animation
    
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BookViewController *bookViewController=[storyboard instantiateViewControllerWithIdentifier:@"BookViewController"];
    DataForCell *material=self.list[indexPath.row];
    bookViewController.grade_id=material.text_id;
    [self.navigationController pushViewController:bookViewController animated:YES];
    // Animate
//    NSLog(@"log for index:%ld",indexPath.row);
}
- (IBAction)logoutButtonClick:(id)sender {
    [[AccountManager singleInstance] deleteAccount];
    [[NSUserDefaults standardUserDefaults] setValue:@"out" forKey:@"MeticStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
