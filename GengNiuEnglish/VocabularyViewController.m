//
//  VocabularyViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/5/3.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "VocabularyViewController.h"

@implementation VocabularyViewController

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    //    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height);
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type) {
        case Iphone5s:
            self.titleTopConstraint.constant=4;
            break;
        case Iphone6:
            self.titleTopConstraint.constant=7;
            break;
        case Iphone6p:
            self.titleTopConstraint.constant=10;
            break;
        default:
            self.titleTopConstraint.constant=4;
            break;
    }
}
-(void)viewDidLoad
{
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
}
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
