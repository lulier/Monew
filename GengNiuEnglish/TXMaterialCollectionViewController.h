//
//  TXMaterialCollectionViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface TXMaterialCollectionViewController : UICollectionViewController<UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
@property(strong,nonatomic)NSArray *list;
@end
