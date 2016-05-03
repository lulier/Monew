//
//  ModifyPassword.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/5/3.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonMethod.h"
#import "AccountManager.h"
#import "SCLAlertView.h"
#import "MRProgress.h"

@interface ModifyPassword : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@end
