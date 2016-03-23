//
//  SlideNavigationController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/21.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideNavigationController : UINavigationController<UINavigationControllerDelegate>
@property (atomic, assign) BOOL shouldIgnorePushingViewControllers;
-(void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end
