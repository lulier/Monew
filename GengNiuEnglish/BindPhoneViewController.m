//
//  BindPhoneViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/4/26.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "BindPhoneViewController.h"

@implementation BindPhoneViewController


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
    
    if (self.bind)
    {
        self.veriInput.hidden=NO;
        self.veriButton.hidden=NO;
        self.sendVeriCode.hidden=NO;
        self.phoneNumInput.delegate=self;
        self.veriInput.delegate=self;
        self.passwordInput.delegate=self;
        self.veriButton.enabled=YES;
        self.phoneNumInput.enabled=YES;
        self.codeVerified=NO;
        self.passwordInput.hidden=YES;
        self.registButton.hidden=YES;
        [self.registButton setTitle:@"绑定" forState:UIControlStateNormal];
    }
    else
    {
        self.veriInput.hidden=YES;
        self.veriButton.hidden=YES;
        self.sendVeriCode.hidden=YES;
        self.phoneNumInput.delegate=self;
        self.phoneNumInput.enabled=NO;
        self.phoneNumInput.text=self.currentPhone;
        self.veriInput.delegate=self;
        self.passwordInput.delegate=self;
        self.veriButton.enabled=YES;
        self.codeVerified=YES;
        self.passwordInput.hidden=NO;
        self.registButton.hidden=NO;
        [self.registButton setTitle:@"解除绑定" forState:UIControlStateNormal];
    }
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
            [alert showWaiting:self title:nil subTitle:@"验证成功" closeButtonTitle:nil duration:1.0f];
            self.phoneNumInput.enabled=NO;
            self.veriButton.enabled=NO;
            self.codeVerified=YES;
            self.veriInput.enabled=NO;
            [self updateViewConstraints];
            //验证成功之后需要绑定手机号
            //如果是邮箱的话不需要输入密码了，如果是第三方的话还需要再输入密码
            AccountManager *account=[AccountManager singleInstance];
            if (account.type==LTEmail)
            {
                [self bindPhone:@""];
            }
            else
            {
                //显示密码输入，输入密码之后再绑定手机
                self.passwordInput.hidden=NO;
                self.registButton.hidden=NO;
                self.veriInput.hidden=YES;
                self.veriButton.hidden=YES;
                self.sendVeriCode.hidden=YES;
            }
        } else {
            NSLog(@"验证失败");
            SCLAlertView *alert=[[SCLAlertView alloc]init];
            [alert showError:self title:nil subTitle:@"验证码错误" closeButtonTitle:@"确认" duration:0.0f];
        }
    }];
}
-(void)bindPhone:(NSString*)password
{
    //绑定中
    NSString *bindTip;
    if (self.bind)
    {
        bindTip=@"正在绑定手机";
    }
    else
        bindTip=@"正在解绑手机";
    __block MRProgressOverlayView *progressView=[MRProgressOverlayView showOverlayAddedTo:self.view title:bindTip mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    NSString *phone=self.phoneNumInput.text;
    AccountManager *accountManager=[AccountManager singleInstance];
    [accountManager bindPhone:phone bind:self.bind password:password success:^(BOOL bindSuccess) {
        if (progressView!=nil)
        {
            [progressView dismiss:NO];
            progressView=nil;
        }
        if (bindSuccess)
        {
            NSString *successTitle;
            if (self.bind)
            {
                successTitle=@"绑定成功";
            }
            else
                successTitle=@"解绑成功";
            SCLAlertView *alert=[[SCLAlertView alloc]init];
            [alert showWaiting:self title:nil subTitle:successTitle closeButtonTitle:nil duration:1.0f];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        else
        {
            NSString *failTitle;
            if (self.bind)
            {
                failTitle=@"绑定手机失败";
            }
            else
                failTitle=@"解绑手机失败";
            SCLAlertView *alert=[[SCLAlertView alloc]init];
            [alert showError:self title:nil subTitle:failTitle closeButtonTitle:@"确认" duration:0.0f];
        }
        
    } failure:^(NSString *message) {
        if (progressView!=nil)
        {
            [progressView dismiss:NO];
            progressView=nil;
        }
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"网络错误，请重新尝试" closeButtonTitle:@"确定" duration:0.0f];
    }];
}
- (IBAction)registButtonClick:(id)sender {
    NSString* password=self.passwordInput.text;
    if ([password length] < 5)
    {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"密码长度请不要少于5位" closeButtonTitle:@"确定" duration:0.0f];
        return;
    }
    [self bindPhone:password];
}
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
