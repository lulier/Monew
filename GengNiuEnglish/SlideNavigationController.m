//
//  SlideNavigationController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/21.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "SlideNavigationController.h"

@interface UINavigationController (SlideNavigationController)<UIGestureRecognizerDelegate>

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end


@implementation SlideNavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!self.shouldIgnorePushingViewControllers)
    {
        [super pushViewController:viewController animated:animated];
        self.shouldIgnorePushingViewControllers = YES;
    }
    
}
- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super didShowViewController:viewController animated:animated];
    self.shouldIgnorePushingViewControllers = NO;
}

@end
