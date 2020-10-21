//
//  AppDelegate.m
//  FMShortVideo
//
//  Created by yfm on 2020/10/20.
//

#import "AppDelegate.h"
#import "HomeVC.h"
#import <FMHttpRequest/FMHttpHeader.h>
#import "FMParse.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()
@property (nonatomic, assign) BOOL hasAuthNetwork;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 允许静音模式下播放音频
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [self initNetwork];
    [self initWindow];
    return YES;
}

- (void)initWindow {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    HomeVC *homeVC = [[HomeVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    nav.navigationBar.hidden = YES;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}
/*
 AFNetworkReachabilityStatusUnknown          = -1,
 AFNetworkReachabilityStatusNotReachable     = 0,
 AFNetworkReachabilityStatusReachableViaWWAN = 1,
 AFNetworkReachabilityStatusReachableViaWiFi = 2,
 */
- (void)initNetwork {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                if(!self.hasAuthNetwork) {
                    // 发送通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"networkAuthSuccess" object:nil];
                    
                    // 保存值，下次不在发送通知
                    self.hasAuthNetwork = YES;
                }
                break;
        }
    }];
    
    FMHttpConfig *config = [FMHttpConfig shared];
    config.plugins = @[[FMHttpLogger class]];
    config.parse = [[FMParse alloc] init];
    config.baseURL = @"https://api.apiopen.top";
    config.dataKey = @"result";
    config.publicRequestHeaders = @{@"User_Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.80 Safari/537.36"};
    config.dataFormat = FMRequestDataFormatJSON;
}

- (BOOL)hasAuthNetwork {
    BOOL hasAuth = [[[NSUserDefaults standardUserDefaults] objectForKey:@"hasAuthNetwork"] boolValue];
    return hasAuth;
}

- (void)setHasAuthNetwork:(BOOL)hasAuthNetwork {
    [[NSUserDefaults standardUserDefaults] setObject:@(hasAuthNetwork) forKey:@"hasAuthNetwork"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
