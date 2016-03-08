//
//  MobileRegistViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/6.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "MobileRegistViewController.h"

@implementation MobileRegistViewController
-(void)viewDidLoad
{
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
}
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)useEmail:(id)sender {
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EmailRegistViewController *emailRegistViewController=[storyboard instantiateViewControllerWithIdentifier:@"EmailRegistViewController"];
    [self.navigationController pushViewController:emailRegistViewController animated:YES];
}

@end
