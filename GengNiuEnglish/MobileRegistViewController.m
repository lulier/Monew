//
//  MobileRegistViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/6.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "MobileRegistViewController.h"
#import <SMS_SDK/SMSSDK.h>


@implementation MobileRegistViewController
-(void)updateViewConstraints
{
    [super updateViewConstraints];
//    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height);
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type) {
        case Iphone5s:
            self.titleTopConstraint.constant=4;
            self.inputTopConstraint.constant=20;
            break;
        case Iphone6:
            self.titleTopConstraint.constant=7;
            self.inputTopConstraint.constant=40;
            break;
        case Iphone6p:
            self.titleTopConstraint.constant=10;
            self.inputTopConstraint.constant=60;
            break;
        default:
            break;
    }
    if (self.sendVeriCode.hidden==NO)
    {
        self.registWithEmailConstraint.constant=8;
    }
    else
        self.registWithEmailConstraint.constant=53;
}
-(void)viewDidLoad
{
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
    self.phoneNumInput.delegate=self;
    self.veriInput.delegate=self;
    self.passwordInput.delegate=self;
    self.passwordInput.hidden=YES;
    self.registButton.hidden=YES;
    self.veriButton.enabled=YES;
    self.phoneNumInput.enabled=YES;
    self.codeVerified=NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide) name:UIKeyboardWillHideNotification object:nil];
}
-(void)onKeyboardHide
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.phoneNumInput resignFirstResponder];
    [self.veriInput resignFirstResponder];
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
-(void)resignKeyboard
{
    [self.phoneNumInput resignFirstResponder];
    [self.veriButton resignFirstResponder];
    [self.passwordInput resignFirstResponder];
}
- (IBAction)getVeriCode:(id)sender {
    [self resignKeyboard];
    NSString *phoneNum=self.phoneNumInput.text;
    if (![CommonMethod isPhoneNumberVaild:phoneNum]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"您输入的手机号码有误" closeButtonTitle:nil duration:1.0f];
        return;
    }
    [sender setEnabled:NO];
    NSNumber *waitingTime = @60;
    NSMutableDictionary *dict = [@{@"waitingTime":waitingTime} mutableCopy];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshWaitingCount:) userInfo:dict repeats:YES];
    [timer fire];
    [AccountManager checkPhoneInUse:phoneNum success:^(BOOL isInused) {
        if (!isInused) {
            [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:phoneNum
                                           zone:@"86"
                               customIdentifier:nil
                                         result:^(NSError *error)
             {
                 if (!error) {
                     NSLog(@"验证码发送成功");
                     SCLAlertView *alert = [[SCLAlertView alloc] init];
                     [alert showSuccess:self title:nil subTitle:@"验证码已经发送" closeButtonTitle:nil duration:1.0f];
                 } else {
                     NSLog(@"验证码发送失败");
                     [timer invalidate];
                     [self.veriButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                     [self.veriButton setEnabled:YES];
                     SCLAlertView *alert = [[SCLAlertView alloc] init];
                     [alert showError:self title:@"错误" subTitle:@"获取验证码失败，请重新尝试" closeButtonTitle:@"确定" duration:0.0f];
                 }
             }];
        }else {
            [timer invalidate];
            [self.veriButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [self.veriButton setEnabled:YES];
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showError:self title:@"错误" subTitle:@"此手机号已被使用" closeButtonTitle:@"确定" duration:0.0f];
        }
    } failure:^(NSString * _Nullable message) {
        [timer invalidate];
        [self.veriButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.veriButton setEnabled:YES];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"网络错误，请重新尝试" closeButtonTitle:@"确定" duration:0.0f];
    }];
}
- (void)refreshWaitingCount:(id)sender {
    NSTimer *timer = sender;
    NSMutableDictionary *dict = [timer userInfo];
    NSNumber *waitingTime = dict[@"waitingTime"];
    dict[@"waitingTime"] = @([waitingTime integerValue]-1);
    
    if (self == self.navigationController.viewControllers.lastObject && [waitingTime integerValue] > 0) {
        NSString *title = [NSString stringWithFormat:@"%@秒后重试",waitingTime];
        [self.veriButton setTitle:title forState:UIControlStateNormal];
    }else {
        [timer invalidate];
        [self.veriButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        if (!self.codeVerified) {
            [self.veriButton setEnabled:YES];
        }
    }
}
- (IBAction)sendVeriCodeButtonClick:(id)sender {
    [self resignKeyboard];
    NSString *phoneNumber = self.phoneNumInput.text;
    NSString *verificationCode = self.veriInput.text;
    if (![CommonMethod isPhoneNumberVaild:phoneNumber]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"您输入的手机号码有误" closeButtonTitle:@"确定" duration:0.0f];
        return;
    }else if ([verificationCode length] == 0) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"请输入验证码" closeButtonTitle:@"确定" duration:0.0f];
        return;
    }
    __block MRProgressOverlayView *progressView=[MRProgressOverlayView showOverlayAddedTo:self.view title:@"发送中" mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    [SMSSDK commitVerificationCode:verificationCode phoneNumber:phoneNumber zone:@"+86" result:^(NSError *error) {
        if (progressView!=nil)
        {
            [progressView dismiss:NO];
            progressView=nil;
        }
        if (!error) {
            NSLog(@"验证成功");
            SCLAlertView *alert=[[SCLAlertView alloc]init];
            [alert showWaiting:self title:nil subTitle:@"验证成功，请输入登录密码" closeButtonTitle:nil duration:1.0f];
            self.sendVeriCode.hidden=YES;
            self.passwordInput.hidden=NO;
            self.registButton.hidden=NO;
            self.phoneNumInput.enabled=NO;
            self.veriButton.enabled=NO;
            self.codeVerified=YES;
            self.veriInput.enabled=NO;
            [self updateViewConstraints];
        } else {
            NSLog(@"验证失败");
            SCLAlertView *alert=[[SCLAlertView alloc]init];
            [alert showError:self title:nil subTitle:@"验证码错误" closeButtonTitle:@"确认" duration:0.0f];
        }
    }];
}
- (IBAction)registButtonClick:(id)sender {
    NSString* phoneNum=self.phoneNumInput.text;
    NSString* password=self.passwordInput.text;
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:phoneNum,@"account",password,@"password", nil];
    __block MRProgressOverlayView *progressView=[MRProgressOverlayView showOverlayAddedTo:self.view title:@"正在注册" mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    [AccountManager registAccount:REGPhone parameters:dic success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        if (progressView!=nil)
        {
            [progressView dismiss:NO];
            progressView=nil;
        }
        long int status=[[responseObject objectForKey:@"status"] integerValue];
        if(status==0)
        {
            [AccountManager login:LTPhone parameters:dic success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
                long int status=[[responseObject objectForKey:@"status"] integerValue];
                if (status==0)
                {
                    AccountManager *accountManager=[AccountManager singleInstance];
                    accountManager.userID=[responseObject objectForKey:@"userid"];
                    accountManager.completeInfo=[responseObject objectForKey:@"info_complete"];
                    accountManager.loginTime=[responseObject objectForKey:@"logintime"];
                    [accountManager saveAccount];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        MaterialViewController *materialViewController=[storyboard instantiateViewControllerWithIdentifier:@"MaterialViewController"];
                        [self.navigationController pushViewController:materialViewController animated:NO];
                    });
                }
                else
                {
                    SCLAlertView *alert=[[SCLAlertView alloc]init];
                    [alert showError:self title:@"错误" subTitle:@"登录失败，请重新尝试" closeButtonTitle:nil duration:1.0f];
                }
            } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                [alert showError:self title:@"错误" subTitle:@"网络错误，请重新尝试" closeButtonTitle:nil duration:1.0f];
            }];
        }
        else
        {
            SCLAlertView *alert=[[SCLAlertView alloc]init];
            [alert showError:self title:@"错误" subTitle:@"注册失败，请重新尝试" closeButtonTitle:nil duration:1.0f];
        }
        
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        if (progressView!=nil)
        {
            [progressView dismiss:NO];
            progressView=nil;
        }
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"网络错误，请重新尝试" closeButtonTitle:nil duration:1.0f];
    }];
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
