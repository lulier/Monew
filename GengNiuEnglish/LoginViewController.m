//
//  LoginViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/6.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "LoginViewController.h"
#define CIPHER_KEY @"24BF8C08A00AFA00"
@interface LoginViewController()
{
    UIViewController *launchView;
    UIView *blackView;
}
@end
@implementation LoginViewController
-(void)viewWillAppear:(BOOL)animated
{
    //检查是否登陆过  在nsdefual中查询是否存在userid字段，同时是否是active，如果是自动登陆，同时跳到主界面
    [super viewWillAppear:animated];
    [self checkLogin];
    self.passwordInput.text=@"";
}
-(void)showBlackView
{
    if (!blackView) {
        CGRect screen = [UIScreen mainScreen].bounds;
        blackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen.size.width, screen.size.height)];
        [blackView setBackgroundColor:[UIColor blackColor]];
    }
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:blackView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [blackView removeFromSuperview];
        blackView = nil;
    });
}
-(void)showLaunchView
{
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    launchView=[storyboard instantiateViewControllerWithIdentifier:@"LaunchViewController"];
    launchView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:launchView animated:NO completion:
     ^{
         [blackView removeFromSuperview];
         blackView = nil;
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [launchView dismissViewControllerAnimated:YES completion:nil];
         });
     }];
}
-(void)checkLogin
{
    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"AccountStatus"];
    BOOL isIn = [userStatus isEqualToString:@"in"];
    if ([AccountManager isExist])
    {
        AccountManager *accountManager=[AccountManager singleInstance];
        self.accountInput.text=accountManager.account;
        if (!isIn)
        {
            self.accountInput.text=@"";
            self.passwordInput.text=@"";
            [accountManager deleteAccount];
            return;
        }
        [self login];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"out" forKey:@"MeticStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
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
}
-(void)viewDidLoad
{
    [self showBlackView];
    [self showLaunchView];
    [self.navigationController setNavigationBarHidden:YES];
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
    self.accountInput.delegate=self;
    self.passwordInput.delegate=self;
    self.passwordInput.text=@"";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide) name:UIKeyboardWillHideNotification object:nil];
}
-(void)onKeyboardHide
{
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
    int offset = frame.origin.y + 50 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.50f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f,-offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.accountInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
- (IBAction)loginButtonClick:(id)sender {
    [self.accountInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
    
    NSString *account=self.accountInput.text;
    NSString *passWord=self.passwordInput.text;
    
    if (![CommonMethod isEmailValid:account] && ![CommonMethod isPhoneNumberVaild:account]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"您输入的帐户格式有误" closeButtonTitle:@"确定" duration:0.0f];
        return;
    } else if ([passWord length] < 5) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"错误" subTitle:@"密码长度请不要少于5位" closeButtonTitle:@"确定" duration:0.0f];
        return;
    }
    
    [AccountManager singleInstance];
    LoginType type;
    if ([[account componentsSeparatedByString:@"@"] count]>1)
    {
        type=LTEmail;
    }
    else
        type=LTPhone;
    MRProgressOverlayView *progressView=[MRProgressOverlayView showOverlayAddedTo:self.view title:@"登录中" mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:account,@"account",passWord,@"password" ,nil];
    [AccountManager login:type parameters:dict success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
        //纪录登陆信息，跳转到主界面
        [progressView dismiss:YES];
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
        if (status==USER_NOT_EXIST||status==PASSWD_INCORRECT)
        {
            SCLAlertView *alert=[[SCLAlertView alloc]init];
            [alert showError:self title:@"错误" subTitle:@"您输入的用户名或密码错误" closeButtonTitle:nil duration:1.0f];
        }

        
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        [progressView dismiss:YES];
    }];
}
-(void)login
{
    AccountManager *accountManager=[AccountManager singleInstance];
    NSString *accountNum=accountManager.account;
    NSString *md5_str=accountManager.password;
    NSString *loginType;
    if (accountManager.type==LTPhone)
    {
        loginType=@"1";
    }
    if (accountManager.type==LTEmail)
    {
        loginType=@"2";
    }
    NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@",accountNum,loginType]];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:loginType,@"type",accountNum,@"account",md5_str,@"passwd",sign,@"sign",nil];
    [NetworkingManager httpRequest:RTPost url:RULogin parameters:dict progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
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
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {

    } completionHandler:nil];
}
- (IBAction)registButtonClick:(id)sender {
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MobileRegistViewController *mobileRegistViewController=[storyboard instantiateViewControllerWithIdentifier:@"MobileRegistViewController"];
    [self.navigationController pushViewController:mobileRegistViewController animated:YES];
}

@end
