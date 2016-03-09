//
//  EmailRegistViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/6.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "EmailRegistViewController.h"

@implementation EmailRegistViewController
-(void)viewDidLoad
{
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
    self.emailInput.delegate=self;
    self.passwordInput.delegate=self;
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
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)registButtonClick:(id)sender {
    //check format
    [self.emailInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
    
    NSString *emailAddress=self.emailInput.text;
    NSString *passWord=self.passwordInput.text;
    
    if (![CommonMethod isEmailValid: emailAddress]) {
        NSLog(@"log for adderss:%@",emailAddress);
//        [SVProgressHUD showErrorWithStatus:@"邮箱格式不正确" duration:1.f];
        return;
    } else if ([passWord length] < 5) {
//        [SVProgressHUD showErrorWithStatus:@"密码长度请不要小于5位" duration:1.f];
        return;
    }
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:emailAddress,@"account",passWord,@"password",nil];
    [AccountManager registAccount:REGEmail parameters:dict success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        long int status=[[responseObject objectForKey:@"status"] integerValue];
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        
    }];
}
@end
