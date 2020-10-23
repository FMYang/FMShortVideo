//
//  FollowFeed.h
//  FMShortVideo
//
//  Created by yfm on 2020/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FeedList;
@class Aweme;
@class Video;
@class PlayAddr;

@interface FollowFeed : NSObject

@property (nonatomic, strong) NSArray<FeedList *> *data;

@end

@interface FeedList : NSObject

@property (nonatomic, copy) NSString *feed_type;
@property (nonatomic, strong) Aweme *aweme;

@end

@interface Aweme : NSObject

@property (nonatomic, strong) Video *video;

@end

@interface Video : NSObject

@property (nonatomic, strong) PlayAddr *play_addr;

@end

@interface PlayAddr : NSObject

@property (nonatomic, copy) NSString *uri;
@property (nonatomic, strong) NSArray *url_list;

@end

NS_ASSUME_NONNULL_END
