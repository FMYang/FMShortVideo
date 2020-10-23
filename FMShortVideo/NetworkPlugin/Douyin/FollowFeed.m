//
//  FollowFeed.m
//  FMShortVideo
//
//  Created by yfm on 2020/10/23.
//

#import "FollowFeed.h"
#import <MJExtension/MJExtension.h>

@implementation FollowFeed
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"data": [FeedList class]};
}

@end

@implementation FeedList


@end

@implementation Aweme

@end

@implementation Video

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"play_addr": [PlayAddr class]};
}

@end

@implementation PlayAddr

@end
