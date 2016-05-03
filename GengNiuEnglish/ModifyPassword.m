//
//  ModifyPassword.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/5/3.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "ModifyPassword.h"
#import "LoginViewController.h"

@implementation ModifyPassword
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
    self.oldPasswordInput.delegate=self;
    self.passwordInput.delegate=self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide) name:UIKeyboardWillHideNotification object:nil];
}
-(void)onKeyboardHide
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.oldPasswordInput resignFirstResponder];
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
- (IBAction)confirmButtonClick:(id)sender {
    //check format
    [self.oldPasswordInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
    
    NSString *oldPassword=self.oldPasswordInput.text;
    NSString *passWord=self.passwordInput.text;
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:oldPassword,@"oldPassword",passWord,@"newPassword",nil];
    __block MRProgressOverlayView *progressView=[MRProgressOverlayView showOverlayAddedTo:self.view title:@"正在修改密码" mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    AccountManager *account=[AccountManager singleInstance];
    [account resetPassword:dic success:^(BOOL resetSuccess) {
        if (progressView!=nil)
        {
            [progressView dismiss:NO];
            progressView=nil;
        }
        if (resetSuccess) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showSuccess:self title:@"成功" subTitle:@"修改密码成功" closeButtonTitle:nil duration:1.0f];
        }
        else
        {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showError:self title:@"错误" subTitle:@"修改密码失败，请重新尝试" closeButtonTitle:nil duration:1.0f];
        }
       
    } failure:^(NSString *message) {
        if (progressView!=nil)
        {
            [progressView dismiss:NO];
            progressView=nil;
        }
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"网络错误，请重新尝试" closeButtonTitle:nil duration:1.0f];
    }];
    
}
@end

