//
//  AppDelegate.m
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/9.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworking.h"
#import "ReaderViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SMS_SDK/SMSSDK.h>
#import "CommonMethod.h"
#import "MaterialViewController.h"
#import "SettingViewController.h"
#import "Reachability.h"
#import "StudyDataManager.h"
#import "MuDocumentController.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"

//shareSDK SMS
#import <SMS_SDK/SMSSDK.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //streamingkit init
    NSError* error;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    Float32 bufferLength = 0.1;
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(bufferLength), &bufferLength);

    
    NSURLCache *URLCache=[[NSURLCache alloc]initWithMemoryCapacity:4*1024*1024 diskCapacity:20*1024*1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    SDWebImageManager.sharedManager.cacheKeyFilter = ^(NSURL *url) {
        NSString *path=url.path;
        return path;
    };
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //check network
    
    [CommonMethod checkNetwork:^(NSURLSessionTask *task, id responseObject) {
        [SMSSDK registerApp:appKey withSecret:appSecret];
        [self initShareSDK];
    }];
    

    
    // Override point for customization after application launch.
    
    self.isReaderView=self.isPickerView=false;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    UINavigationController *current=[CommonMethod getCurrentVC];
    if ([current isKindOfClass:[UINavigationController class]])
    {
        NSArray *viewContrlls=[current viewControllers];
        MaterialViewController *tmp=[viewContrlls lastObject];
        if ([tmp isKindOfClass:[MaterialViewController class]])
        {
            [tmp reload:nil];
        }
        
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
//    UINavigationController *navi=(UINavigationController*)self.window.rootViewController;
//    if ([navi.visibleViewController isKindOfClass: [MuDocumentController class]])
//    {
//        if (!self.isReaderView)
//        {
//            return UIInterfaceOrientationMaskLandscape;
//        }
//        return UIInterfaceOrientationMaskAll;
//    }
    if (self.isReaderView)
    {
        return UIInterfaceOrientationMaskAll;
    }
    if (self.isPickerView)
    {
        return UIInterfaceOrientationMaskAll;
    }
    else return UIInterfaceOrientationMaskLandscape;
}
- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}
- (void)initShareSDK
{
    [ShareSDK registerApp:@"131bdd69bf874"
     
          activePlatforms:@[
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ),]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:@"1224772497"
                                           appSecret:@"cadab36d40e604388039e75a4b2a876c"
                                         redirectUri:@"http://www.mo-new.com"
                                            authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wx672fc803d70907e2"
                                       appSecret:@"2a8ea751b7b60d9e7be01fc12732ab53"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"1105268827"
                                      appKey:@"ctda2ZaEbSiKCNkJ"
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
     }];
}
@end
