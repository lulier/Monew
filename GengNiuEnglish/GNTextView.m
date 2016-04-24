//
//  GNTextView.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/4/22.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "GNTextView.h"

@implementation GNTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

/* 选中文字后是否能够呼出菜单 */
- (BOOL)canBecameFirstResponder {
    return YES;
}

/* 选中文字后的菜单响应的选项 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (action == @selector(copy:)) { // 菜单不能响应copy项
        return NO;
    }
    if (action == @selector(callSelectText:)||action == @selector(cancelSelection:)) {
        return YES;
    }
    // 事实上一个return NO就可以将系统的所有菜单项全部关闭了
    return NO;
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        gestureRecognizer.enabled = NO;
    }
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        [(UITapGestureRecognizer *)gestureRecognizer setNumberOfTapsRequired:1];
        //        gestureRecognizer.enabled=NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
    return;
}
@end
