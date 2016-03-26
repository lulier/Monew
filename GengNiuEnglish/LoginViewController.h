//
//  LoginViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/6.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonMethod.h"
#import "MobileRegistViewController.h"
#import "MRProgress.h"
#import "MaterialViewController.h"
#import "SCLAlertView.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *accountInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *weiXinLogin;
@property (weak, nonatomic) IBOutlet UIButton *qqLogin;
@property (weak, nonatomic) IBOutlet UIButton *weiBoLogin;

@end
