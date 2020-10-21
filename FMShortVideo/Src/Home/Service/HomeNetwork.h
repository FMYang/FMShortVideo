//
//  HomeNetwork.h
//  FMShortVideo
//
//  Created by yfm on 2020/10/20.
//

#import <Foundation/Foundation.h>
#import <FMHttpRequest/FMHttpHeader.h>
#import "VideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeNetwork : NSObject

/// 获取视频列表
/// @param params 参数
/// @param success 成功回调
/// @param fail 失败回调
+ (void)fetchList:(NSDictionary *)params
          success:(FMSuccessBlock(NSArray<VideoModel *> *))success
             fail:(FMFailBlock)fail;

@end

NS_ASSUME_NONNULL_END
