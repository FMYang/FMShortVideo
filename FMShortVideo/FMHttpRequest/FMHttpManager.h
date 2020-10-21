//
//  FMHttpManager.h
//  FMHttpRequest
//
//  Created by fm y on 2019/11/29.
//  Copyright © 2019 fm y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "FMRequest.h"
#import "FMResponse.h"
#import "FMHttpParseDelegate.h"
#import "FMError.h"

#define FMSuccessBlock(type) void (^)(type result, FMResponse *response)

NS_ASSUME_NONNULL_BEGIN

typedef void(^FMFailBlock)(FMError *error);

@interface FMHttpManager : NSObject

@property (nonatomic, strong, readonly) AFURLSessionManager *manager;

/// 单例
+ (FMHttpManager *)shared;

/// 发起网络请求
/// @param request 请求对象
/// @param success 成功
/// @param fail 失败
+ (nullable NSURLSessionDataTask *)sendRequest:(FMRequest *)request
                                       success:(FMSuccessBlock(id))success
                                          fail:(FMFailBlock)fail;

/// 上传文件
/// @param request 请求对象
/// @param uploadProgress 上传进度回调
/// @param success 成功回调
/// @param failure 失败回调
+ (nullable NSURLSessionDataTask *)uploadFile:(FMRequest *)request
                                     progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

//+ (void)downloadFile:(FMRequest *)request;

@end

NS_ASSUME_NONNULL_END
