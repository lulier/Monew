//
//  MenuControllerSupportingView.m
//  testForUILabelSelect
//
//  Created by luzegeng on 16/4/23.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "MenuControllerSupportingView.h"

@implementation MenuControllerSupportingView

//It's mandatory and it has to return YES then only u can show menu items..
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)define
{
    [self.delegate define];
}

-(void)addToUnknow
{
    [self.delegate addToUnknow];
}



//It's not mandatory for custom menu items

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(define))
        return YES;
    else if(action == @selector(addToUnknow))
        return YES;
    else
        return NO;
}
@end
