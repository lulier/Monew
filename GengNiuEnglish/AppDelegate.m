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

@interface AppDelegate ()

@end
static NSString* const appKey=@"1041a2bf48e78";
static NSString* const appSecret=@"2c2ca1b896f428d3d258743bf50076d9";
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
    [SMSSDK registerApp:appKey withSecret:appSecret];
    
    // Override point for customization after application launch.
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([self.window.rootViewController.presentedViewController isKindOfClass: [ReaderViewController class]])
    {
        if (!self.isReaderView)
        {
            return UIInterfaceOrientationMaskLandscape;
        }
        return UIInterfaceOrientationMaskAll;
    }
    else return UIInterfaceOrientationMaskLandscape;
}
@end
