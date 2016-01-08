//
//  ViewController.h
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/9.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

@interface ViewController : UIViewController
{
    lua_State *L;
}

@end

