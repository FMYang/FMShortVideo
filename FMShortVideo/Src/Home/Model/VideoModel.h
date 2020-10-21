//
//  VideoModel.h
//  FMHttpRequest
//
//  Created by fm y on 2019/12/2.
//  Copyright © 2019 fm y. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
 {
     comment = 7;
     down = 3;
     forward = 0;
     header = "http://wimg.spriteapp.cn/profile/large/2019/07/04/5d1d6abb0f9cc_mini.jpg";
     images = "<null>";
     name = "\U680b\U680b";
     passtime = "2019-12-02 02:50:02";
     sid = 29953978;
     text = "\U6709\U4e9b\U4eba\U5916\U8868\U5149\U9c9c\U4eae\U4e3d...";
     thumbnail = "http://wimg.spriteapp.cn/picture/2019/1127/5dde20e70a077_wpd.jpg";
     "top_comments_content" = "<null>";
     "top_comments_header" = "<null>";
     "top_comments_name" = "<null>";
     "top_comments_uid" = "<null>";
     "top_comments_voiceuri" = "<null>";
     type = video;
     uid = 23125935;
     up = 64;
     video = "http://uvideo.spriteapp.cn/video/2019/1127/5dde20e70a077_wpd.mp4";
 }
 */

@interface VideoModel : NSObject
@property (nonatomic, assign) int comment;
@property (nonatomic, assign) int down;
@property (nonatomic, assign) int forward;
@property (nonatomic, copy) NSString *header;
@property (nonatomic, copy) NSString *images;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *passtime;
@property (nonatomic, assign) long sid;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *video;
@end

NS_ASSUME_NONNULL_END
