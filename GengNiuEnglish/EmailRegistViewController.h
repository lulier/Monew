//
//  EmailRegistViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/6.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonMethod.h"
#import "AccountManager.h"

@interface EmailRegistViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UIButton *registButton;

@end
