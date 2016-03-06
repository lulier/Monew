//
//  MobileRegistViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/6.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobileRegistViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumInput;
@property (weak, nonatomic) IBOutlet UITextField *veriInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UIButton *registButton;

@end
