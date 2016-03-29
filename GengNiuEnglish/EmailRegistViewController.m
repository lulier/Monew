//
//  EmailRegistViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/6.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "EmailRegistViewController.h"

@implementation EmailRegistViewController
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
            break;
    }
}
-(void)viewDidLoad
{
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
    self.emailInput.delegate=self;
    self.passwordInput.delegate=self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide) name:UIKeyboardWillHideNotification object:nil];
}
-(void)onKeyboardHide
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.emailInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
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
    NSTimeInterval animationDuration = 0.50f;
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
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"您输入的邮箱格式有误" closeButtonTitle:@"确定" duration:0.0f];
        return;
    }
    if ([passWord length] < 5)
    {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"密码长度请不要少于5位" closeButtonTitle:@"确定" duration:0.0f];
        return;
    }
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:emailAddress,@"account",passWord,@"password",nil];
    [AccountManager registAccount:REGEmail parameters:dict success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        long int status=[[responseObject objectForKey:@"status"] integerValue];
        SCLAlertView *alert=[[SCLAlertView alloc]init];
        switch (status)
        {
            case NORMAL_RESPONSE:
                [alert showSuccess:self title:@"成功" subTitle:@"验证邮件已经发送到您的邮箱，请查收" closeButtonTitle:@"确定" duration:0.0f];
                break;
            case USER_NOT_ACTIVE:
                [alert showSuccess:self title:@"成功" subTitle:@"该邮箱已注册，请到邮箱激活" closeButtonTitle:@"确定" duration:0.0f];
                break;
            case USER_EXISTS:
                [alert showNotice:self title:@"错误" subTitle:@"该邮箱已注册过更牛帐号" closeButtonTitle:nil duration:1.0f];
                break;
            default:
                [alert showError:self title:@"错误" subTitle:@"注册失败，请重新尝试" closeButtonTitle:nil duration:1.0f];
                break;
        }
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"网络错误，请重新尝试" closeButtonTitle:nil duration:1.0f];
    }];
}
@end
