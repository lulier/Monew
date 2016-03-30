//
//  MobileRegistViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/6.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonMethod.h"
#import "EmailRegistViewController.h"
#import "SCLAlertView.h"
#import "MaterialViewController.h"
#import "MRProgress.h"

@interface MobileRegistViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumInput;
@property (weak, nonatomic) IBOutlet UITextField *veriInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UIButton *registButton;
@property (weak, nonatomic) IBOutlet UIButton *veriButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sendVeriCode;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registWithEmailConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputTopConstraint;



@end
