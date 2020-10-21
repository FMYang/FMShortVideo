//
//  HomeNetwork.m
//  FMShortVideo
//
//  Created by yfm on 2020/10/20.
//

#import "HomeNetwork.h"

@implementation HomeNetwork

+ (void)fetchList:(NSDictionary *)params success:(FMSuccessBlock(NSArray<VideoModel *> *))success fail:(FMFailBlock)fail {
    FMRequest *request = FMRequest.build()
    .reqMethod(FMHttpReuqestMethodGet)
    .reqUrl(@"/getJoke")
    .reqParams(params)
    .resClass(VideoModel.class)
    .reqDataFormat(FMRequestDataFormatDefault);
    
    [FMHttpManager sendRequest:request success:success fail:fail];
}

@end
