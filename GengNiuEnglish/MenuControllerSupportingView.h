//
//  MenuControllerSupportingView.h
//  testForUILabelSelect
//
//  Created by luzegeng on 16/4/23.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCSDelegate <NSObject>

-(void)define;
-(void)addToUnknow;

@end


@interface MenuControllerSupportingView : UIView
@property(nonatomic,weak)id<MCSDelegate>delegate;
@end
