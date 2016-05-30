//
//  BindPhoneViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/4/26.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonMethod.h"
#import "SCLAlertView.h"
#import "AccountManager.h"
#import <SMS_SDK/SMSSDK.h>
#import "MRProgress.h"

@interface BindPhoneViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumInput;
@property (weak, nonatomic) IBOutlet UITextField *veriInput;
@property (weak, nonatomic) IBOutlet UIButton *veriButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sendVeriCode;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UIButton *registButton;
@property(nonatomic,strong) NSString *currentPhone;
@property(nonatomic)BOOL bind;
@property(nonatomic)BOOL codeVerified;
@end
