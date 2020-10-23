//
//  DouyinService.m
//  FMShortVideo
//
//  Created by yfm on 2020/10/22.
//

#import "DouyinService.h"
#import "JQKProtobufResponseSerializer.h"
#import "DouyinFeedMin.pbobjc.h"

@implementation DouyinService

+ (void)getDouyinRecommendList {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    JQKProtobufResponseSerializer *protobufResponseSerializer = [JQKProtobufResponseSerializer serializerWithMessageClass:[Feed class]];
    manager.responseSerializer = protobufResponseSerializer;


    // 推荐视频
    NSString *url = @"https://api100-core-c-lf.amemv.com/aweme/v2/feed/?tma_jssdk_version=1.81.0.3&ac=WIFI&is_vcd=1&max_cursor=0&gps_access=3&cached_item_num=0&volume=0.00&user_id=1103561502231902&pull_type=1&count=6&min_cursor=0&action_mask=-1&latitude=22.60487210433714&aweme_ids=&sp=60&address_book_access=1&type=0&last_ad_show_interval=6811&longitude=114.0569995146835&feed_style=0&mac_address=02%3A00%3A00%3A00%3A00%3A00&live_auto_enter=0&filter_warn=0&action_mask_detail=%7B%226886277739301571851%22%3A129%2C%226886020588645649677%22%3A128%2C%226885983820894440707%22%3A128%2C%226885265243774192903%22%3A0%2C%226835920128618564868%22%3A128%2C%226833270841623547140%22%3A128%7D&is_order_flow=0&";
    
    // 用户视频
//    NSString *url = @"https://api3-normal-c-lf.amemv.com/aweme/v1/music/aweme/?tma_jssdk_version=1.81.0.3&ac=WIFI&is_vcd=1&cursor=0&music_id=6886284340351830797&count=18&pull_type=2&is_order_flow=0&type=6&user_avatar_shrink=96_96&video_cover_shrink=248_330&";
        
    NSDictionary *header = @{@"sdk-version": @"2",
                             @"passport-sdk-version": @"5.12.1",
                             @"x-Tt-Token": @"002038581c80f44ef2958415cd64df15c588d2a8127dfe2424c9b3f28062dd24881ddfc9d60f48765f07080861f726654727",
                             @"User-Agent": @"Aweme 12.9.0 rv:129015 (iPhone; iOS 14.0.1; zh_CN) Cronet",
                             @"X-SS-DP": @"1128",
                             @"x-tt-trace-id": @"00-54854ef70a10552b952bbb0a664a0468-54854ef70a10552b-01",
                             @"Accept-Encoding": @"gzip, deflate, br",
                             @"Cookie":@"d_ticket=b51345fa4038454c65b85a13bfaec57ea801d",
                             @"Cookie":@"multi_sids=1103561502231902%3A2038581c80f44ef2958415cd64df15c5",
                             @"Cookie":@"odin_tt=540777bcde4bf2052c3050d095dfd76a37f657455b95bbfe07600591c51dbc94c7ba521d21dc693176cbd9979294aed27f3edfb527356032ff6e375313548a49",
                             @"Cookie":@"sessionid=2038581c80f44ef2958415cd64df15c5",
                             @"Cookie":@"sessionid_ss=2038581c80f44ef2958415cd64df15c5",
                             @"Cookie":@"sid_guard=2038581c80f44ef2958415cd64df15c5%7C1602655987%7C5184000%7CSun%2C+13-Dec-2020+06%3A13%3A07+GMT",
                             @"Cookie":@"sid_tt=2038581c80f44ef2958415cd64df15c5",
                             @"Cookie":@"uid_tt=04cf8316288ef318bdac9661cf03a27c",
                             @"Cookie":@"uid_tt_ss=04cf8316288ef318bdac9661cf03a27c",
                             @"Cookie":@"install_id=4380078136113799",
                             @"Cookie":@"ttreq=1$bedc98d44f3f65ff6919318f2534f7580539664c",
                             @"X-Khronos": @"1603440822",
                             @"X-Gorgon": @"840200370000ac664633d72b53003933f32c7e63b0c3996943d0",
                             @"x-common-params-v2":@"channel=App%20Store&version_code=12.9.0&app_name=aweme&vid=BAC81642-7169-43A6-88D1-0C970AF904A0&app_version=12.9.0&mcc_mnc=&device_id=70148396331&aid=1128&screen_width=828&openudid=a2075339ef3c376f288d66414f2c3660a09554bd&os_api=18&os_version=14.0.1&device_platform=iphone&build_number=129015&device_type=iPhone12,1&iid=4380078136113799&idfa=008E78A1-ACF5-4584-A89C-8505914ADCD9&js_sdk_version=1.81.0.3&cdid=2A949315-316C-404F-8711-44836091CFD4"};
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = [NSURL URLWithString:url];
    [request setValue:@"application/x-protobuf" forHTTPHeaderField:@"Content-Type"];
    for(NSString *key in header.allKeys) {
        [request setValue:header[key] forHTTPHeaderField:key];
    }

    [[manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error) {
            NSLog(@"请求失败 %@", error);
        } else {
            Feed *feed = responseObject;
//            NSLog(@"成功 %f", feed.statusCode);
//            NSLog(@"视频数量 %d 播放地址 %@", feed.awemeListArray.count, feed.awemeListArray[0].video.playAddr.URLListArray[0]);
        }
    }] resume];
}


@end
