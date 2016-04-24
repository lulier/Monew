//
//  GNTextView.h
//  GengNiuEnglish
//
//  Created by luzegeng on 16/4/22.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GNTextViewDelegate <NSObject>

-(void)define:(id)sender;
-(void)addToUnknow:(id)sender;

@end

@interface GNTextView : UITextView
@property(nonatomic,weak) id <GNTextViewDelegate> delegate;
@end
