//
//  MainTableViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/21.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "ReaderViewController.h"

@interface MainTableViewController : UITableViewController<ReaderViewControllerDelegate>
@property(strong,nonatomic)NSArray *list;
-(void)dismissReaderViewController:(ReaderViewController *)viewController;

@end
