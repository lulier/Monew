//
//  BookViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/19.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextBookCell.h"
#import "SCLAlertView.h"

@interface BookViewController : UIViewController<UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,textBookCellDelegate,ReaderViewControllerDelegate>
@property(strong,nonatomic)NSArray *list;
@property(strong,nonatomic)NSString *grade_id;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property(atomic)BOOL isLoading;
@property(nonatomic)BOOL showCache;
@property(strong,nonatomic)NSString *textCount;
@end
