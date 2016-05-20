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
#import "DataForCell.h"
#import "CommonMethod.h"
#import "DataForCell.h"
#import "NetworkingManager.h"
#import <AVFoundation/AVFoundation.h>
#import "LyricViewController.h"
#import "FMDB.h"
#import "DAProgressOverlayView.h"
#import "MRProgress.h"
#import "NOZDecompress.h"
#import "MuDocRef.h"
#import "MuDocumentController.h"
#import "mupdf/fitz.h"
#import "common.h"
#import "MuTextSelectView.h"

@interface BookViewController : UIViewController<UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,textBookCellDelegate,ReaderViewControllerDelegate,MuDocumentControllerDelegate,MuTextSelectViewDelegate>
@property(strong,nonatomic)NSArray *list;
@property(strong,nonatomic)NSString *grade_id;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property(atomic)BOOL isLoading;
@property(nonatomic)BOOL showCache;
@property(strong,nonatomic)NSString *textCount;
@end
