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
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 70 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f,-offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (IBAction)loginButtonClick:(id)sender {
    [self.accountInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
    
    NSString *account=self.accountInput.text;
    NSString *passWord=self.passwordInput.text;
    LoginType type;
    if ([[account componentsSeparatedByString:@"@"] count]>1)
    {
        type=LTEmail;
    }
    else
        type=LTPhone;
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:account,@"account",passWord,@"password" ,nil];
    [AccountManager login:type parameters:dict success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        
    }];
}
- (IBAction)registButtonClick:(id)sender {
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MobileRegistViewController *mobileRegistViewController=[storyboard instantiateViewControllerWithIdentifier:@"MobileRegistViewController"];
    [self.navigationController pushViewController:mobileRegistViewController animated:YES];
}

@end
