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
#import "SCLAlertView.h"

@interface MaterialViewController ()
{
    BOOL hideCache;
    BOOL deleteCache;
}
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
-(void)viewWillAppear:(BOOL)animated
{
    //每次进入materialview的时候检查一下当前的action code状态
    [self getActionCode];
}
-(void)getActionCode
{
    AccountManager *accountManager=[AccountManager singleInstance];
    NSString *accountNum=accountManager.userID;
    NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@",accountNum]];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:accountNum,@"user_id",sign,@"sign",nil];
    [NetworkingManager httpRequest:RTGet url:RUActionCode parameters:dict progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        long int status=[[responseObject objectForKey:@"status"] integerValue];
        if (status==0)
        {
            NSInteger actionCode=[[responseObject objectForKey:@"action_code"] integerValue];
            deleteCache=1&actionCode;
            hideCache=2&actionCode;
        }
        else
        {
            deleteCache=false;
            hideCache=false;
        }
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        
    } completionHandler:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.delegate=self;
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setHidden:YES];
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"background"] scaledToSize:CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
    self.collectionView.backgroundView=[[UIImageView alloc]initWithImage:background];
    [self initDatabase];
    [self reload:nil];
}
-(void)updateViewConstraints
{
    [super updateViewConstraints];
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
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type)
    {
        case Iphone5s:
            return CGSizeMake(150, 180);
        case Iphone6:
            return CGSizeMake(160, 200);
        case Iphone6p:
            return CGSizeMake(180, 220);
        default:
            return CGSizeMake(150, 180);
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //6s: 100, 100, 100, 100 6: 90, 80, 100, 80 5: 90, 60, 100, 60
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type)
    {
        case Iphone5s:
            return UIEdgeInsetsMake(40, 60, 60, 60);
        case Iphone6:
            return UIEdgeInsetsMake(60, 80, 80, 80);
        case Iphone6p:
            return UIEdgeInsetsMake(80, 100, 100, 100);
        default:
            return UIEdgeInsetsMake(40, 60, 60, 60);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type)
    {
        case Iphone5s:
            return 60.0f;
        case Iphone6:
            return 80.0f;
        case Iphone6p:
            return 100.0f;
        default:
            return 60.0f;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Prepare for animation
    
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BookViewController *bookViewController=[storyboard instantiateViewControllerWithIdentifier:@"BookViewController"];
    DataForCell *material=self.list[indexPath.row];
    bookViewController.grade_id=material.text_id;
    bookViewController.textCount=material.text_count;
    bookViewController.hideCache=hideCache;
    [self.navigationController pushViewController:bookViewController animated:YES];
}
- (IBAction)logoutButtonClick:(id)sender {
    SCLAlertView *alert=[[SCLAlertView alloc]init];
    [alert addButton:@"确定" target:self selector:@selector(logout)];
    [alert showNotice:self title:@"提示" subTitle:@"您确定要退出当前账号？" closeButtonTitle:@"取消" duration:0.0f];

}
-(void)logout
{
    [[AccountManager singleInstance] deleteAccount];
    [[NSUserDefaults standardUserDefaults] setValue:@"out" forKey:@"MeticStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
