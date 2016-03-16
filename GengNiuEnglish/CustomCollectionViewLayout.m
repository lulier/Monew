//
//  CustomCollectionViewLayout.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/3/15.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "CustomCollectionViewLayout.h"

@implementation CustomCollectionViewLayout

-(id)init
{
    if ((self = [super init])) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 10000.0f;
    }
    return self;
}
@end
