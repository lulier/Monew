//
//  ShowTextViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/5/2.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonMethod.h"
#import "MTDatabaseHelper.h"

@interface ShowTextViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *addToUnknow;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *explanationHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(strong,nonatomic)NSString *word;
@property(strong,nonatomic)NSString *chineseExplanation;
@property(strong,nonatomic)NSString *englishExplanation;
@property(nonatomic)BOOL inVocabulary;
@end
