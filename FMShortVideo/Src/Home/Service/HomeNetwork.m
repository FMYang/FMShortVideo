//
//  HomeNetwork.m
//  FMShortVideo
//
//  Created by yfm on 2020/10/20.
//

#import "HomeNetwork.h"

@implementation HomeNetwork

//+ (void)fetchList:(NSDictionary *)params success:(FMSuccessBlock(NSArray<VideoModel *> *))success fail:(FMFailBlock)fail {
//    FMRequest *request = FMRequest.build()
//    .reqMethod(FMHttpReuqestMethodGet)
//    .reqUrl(@"/vappRecomlist")
//    .reqParams(params)
//    .resClass(VideoModel.class)
//    .reqDataFormat(FMRequestDataFormatDefault);
//
//    [FMHttpManager sendRequest:request success:success fail:fail];
//}

+ (void)fetchList:(NSDictionary *)params success:(nonnull void (^)(NSArray<VideoModel *> * _Nonnull))success fail:(dispatch_block_t)fail {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    [manager GET:@"https://nine.ifeng.com/vappRecomlist" parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *result = responseObject[0][@"item"];
        NSMutableArray<VideoModel *> *items = @[].mutableCopy;
        for(NSDictionary *dic in result) {
            VideoModel *model = [[VideoModel alloc] init];
            model.author = dic[@"subscribe"][@"catename"];
            model.title = dic[@"title"];
            model.thumbnail = dic[@"thumbnail"];
            model.videoPlayUrl = dic[@"phvideo"][@"videoPlayUrl"];
            [items addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            success(items);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error %@", error);
        fail();
    }];
}

@end
