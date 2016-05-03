//
//  VocabularyViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/5/3.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonMethod.h"
#import "DictionaryDatabase.h"
#import "MTDatabaseHelper.h"
#import "ShowTextViewController.h"

@interface VocabularyViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property(nonatomic,strong)NSArray *list;
@end
