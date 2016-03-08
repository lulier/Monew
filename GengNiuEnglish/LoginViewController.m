//
//  LoginViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/6.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

-(void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:YES];
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
}
- (IBAction)registButtonClick:(id)sender {
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MobileRegistViewController *mobileRegistViewController=[storyboard instantiateViewControllerWithIdentifier:@"MobileRegistViewController"];
    [self.navigationController pushViewController:mobileRegistViewController animated:YES];
}

@end
