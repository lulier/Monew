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

@interface MaterialViewController ()

@end

@implementation MaterialViewController

static NSString * const reuseIdentifierMaterial = @"MaterialCell";

-(void)reload:(__unused id)sender{
    NSURLSessionTask *task=[DataForCell getGradeList:^(NSArray *data, NSError *error) {
        if (!error) {
            self.list=data;
            [self.collectionView reloadData];
        }
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    self.collectionView.delegate=self;
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setHidden:YES];
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"background"] scaledToSize:CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
    self.collectionView.backgroundView=[[UIImageView alloc]initWithImage:background];
    [self reload:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
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
    return CGSizeMake(200, 250);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 100, 0, 100);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 100.0f;
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
    NSLog(@"log for index:%ld",indexPath.row);
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //        for (int i = 0; i < [scrollView.subviews count]; i++) {
    //            UIView *cell = [scrollView.subviews objectAtIndex:i];
    //            float position = cell.center.x - scrollView.contentOffset.x;
    //            float offset = 1.5 - (fabs(scrollView.center.x - position) * 1.0) / scrollView.center.x;
    //            if (offset<1.0)
    //            {
    //                offset=1.0;
    //            }
    //            cell.transform = CGAffineTransformIdentity;
    //            cell.transform = CGAffineTransformScale(cell.transform, offset, offset);
    //        }
}


#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

@end
