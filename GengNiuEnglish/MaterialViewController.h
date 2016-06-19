//
//  MaterialViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/19.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "FMDB.h"

@interface MaterialViewController : UIViewController<UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property(strong,nonatomic)NSArray *list;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
-(void)reload:(__unused id)sender;
@end
