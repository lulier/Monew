//
//  ViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/9.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLua];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)initLua
{
    L=luaL_newstate();
    luaL_openlibs(L);
    lua_settop(L, 0);
    luaL_dostring(L, "text=\"this is leolu\"");
    lua_getglobal(L, "text");
    const char *str=lua_tostring(L,1);
    printf("%s",str);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
