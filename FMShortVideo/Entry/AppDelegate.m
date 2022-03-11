//
//  AppDelegate.m
//  FMShortVideo
//
//  Created by yfm on 2020/10/20.
//

#import "AppDelegate.h"
#import <FMHttpRequest/FMHttpHeader.h>
#import <AVFoundation/AVFoundation.h>
#import "HomeVC.h"
#import "FMParse.h"

@interface AppDelegate ()
@property (nonatomic, assign) BOOL hasAuthNetwork;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configAudioSession];
    [self initNetwork];
    [self initWindow];
    return YES;
}

- (void)configAudioSession {
    // 允许静音模式下播放音频
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
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

- (void)initNetwork {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"AFNetworkReachabilityStatusUnknown");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"AFNetworkReachabilityStatusNotReachable");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"AFNetworkReachabilityStatusReachableViaWWAN || AFNetworkReachabilityStatusReachableViaWiFi");
                if(!self.hasAuthNetwork) {
                    // 发送通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"networkAuthSuccess" object:nil];
                    
                    // 保存值，下次不在发送通知
                    self.hasAuthNetwork = YES;
                }
                break;
        }
    }];
    [manager startMonitoring];
    
    FMHttpConfig *config = [FMHttpConfig shared];
    config.plugins = @[[FMHttpLogger class]];
    config.parse = [[FMParse alloc] init];
    config.baseURL = @"https://nine.ifeng.com";
    config.dataKey = @"item";
//    config.publicRequestHeaders = @{@"User_Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.80 Safari/537.36"};
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
