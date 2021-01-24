//
//  FMHttpManager.m
//  FMHttpRequest
//
//  Created by fm y on 2019/11/29.
//  Copyright © 2019 fm y. All rights reserved.
//

#import "FMHttpManager.h"
#import "FMResponse.h"
#import "FMHttpLogger.h"
#import "FMHttpConfig.h"
#import "FMHttpPluginDelegate.h"

@interface FMHttpManager()

@property (nonatomic, strong, readwrite) AFURLSessionManager *manager;

@end

@implementation FMHttpManager

+ (FMHttpManager *)shared {
    static FMHttpManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FMHttpManager alloc] init];
    });
    return instance;
}

- (AFURLSessionManager *)manager {
    if(!_manager) {
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:nil];
    }
    return _manager;
}

+ (nullable NSURLSessionDataTask *)sendRequest:(FMRequest *)request
            success:(FMSuccessBlock(id))success
               fail:(FMFailBlock)fail {
    return [[self shared] sendRequest:request success:success fail:fail];
}

- (nullable NSURLSessionDataTask *)sendRequest:(FMRequest *)request
            success:(FMSuccessBlock(id))success
               fail:(FMFailBlock)fail {
    return [self dataTaskWithRequest:request success:success fail:fail];
}

- (nullable NSURLSessionDataTask *)dataTaskWithRequest:(FMRequest *)request
                    success:(FMSuccessBlock(id))success
                       fail:(FMFailBlock)fail {
    NSMutableURLRequest *urlRequest = [self serializerRequest:request];
    // 优先使用FMRequest设置的超时时间，如果未设置，则使用配置项的
    if(request.timeoutInterval > 0) {
        urlRequest.timeoutInterval = request.timeoutInterval;
    } else {
        urlRequest.timeoutInterval = [FMHttpConfig shared].timeoutInterval;
    }
    
    request.orignalRequest = urlRequest;
    
    // 插件willSend方法
    NSArray *plugins = [[FMHttpConfig shared] plugins];
    [plugins enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(willSend:)]) {
            [obj willSend:request];
        }
    }];
    
    NSLog(@"2、dataTaskWithRequest");
    // 网络状态判断
    if(![self networkReachable]) {
        FMError *error = [[FMError alloc] init];
        error.reason = FMErrorReasonNetworkLost;
        fail(error);
        return nil;
    }
    
    // mock数据处理
    if(request.sampleData) {
        FMResponse *fmResponse = [self requestCompletaion:request success:success fail:fail];
        // 插件didReceive方法
        NSArray<id<FMHttpPluginDelegate>> *plugins = [[FMHttpConfig shared] plugins];
        [plugins enumerateObjectsUsingBlock:^(id<FMHttpPluginDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj respondsToSelector:@selector(didReceive:responseObject:error:)]) {
                NSURLSessionTask *task = [self.manager.session dataTaskWithRequest:urlRequest];
                [obj didReceive:task responseObject:fmResponse error:nil];
            }
        }];
        
        return nil;
    }
    
    __block NSURLSessionDataTask *task = nil;
    task = [self.manager dataTaskWithRequest:urlRequest
                       uploadProgress:nil
                     downloadProgress:nil
                    completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        FMResponse *fmResponse = [self process:responseObject success:success fail:fail error:error response:response request:request];
        // 插件didReceive方法
        NSArray *plugins = [[FMHttpConfig shared] plugins];
        [plugins enumerateObjectsUsingBlock:^(id<FMHttpPluginDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj respondsToSelector:@selector(didReceive:responseObject:error:)]) {
                [obj didReceive:task responseObject:fmResponse error:error];
            }
        }];
    }];
    [task resume];
    return task;
}

// 请求参数序列化 FMRequest -> NSURLRequest
// 构造请求对象
- (NSMutableURLRequest *)serializerRequest:(FMRequest *)request {
    NSError *serializationError = nil;
    
    NSURL *baseURL = [self baseUrl:request];
    
    // 添加公共请求参数
    NSDictionary *params = [self addPublicParams:request.params];
    
    // 构造请求对象
    NSString *requestUrl = [[NSURL URLWithString:request.path relativeToURL:baseURL] absoluteString];
    NSMutableURLRequest *urlRequest = [[self requestSerializer:request] requestWithMethod:[request requestMethod]
                                                         URLString:requestUrl
                                                        parameters:params error:&serializationError];

    /// 添加请求头
    [self addHttpHeader:urlRequest fmRequest:request];
    
    return urlRequest;
}

- (NSURL *)baseUrl:(FMRequest *)request {
    NSURL *baseURL;
    // 优先使用FMRequest设置的baseURL，如果为设置，则使用默认配置的URL
    if(request.baseUrl.length > 0) {
        baseURL = [NSURL URLWithString:request.baseUrl];
    } else if([FMHttpConfig shared].baseURL.length > 0) {
        baseURL = [NSURL URLWithString:[FMHttpConfig shared].baseURL];
    } else {
        @throw @"未设置服务器服务器地址";
    }
    return baseURL;
}

/// 添加请求头
- (void)addHttpHeader:(NSMutableURLRequest *)request fmRequest:(FMRequest *)fmRequest {
    NSDictionary *publicReqeustHeader = [FMHttpConfig shared].publicRequestHeaders;
    NSDictionary *requestHttpHeader = fmRequest.httpHeader;
    
    // 添加公共请求头
    if(publicReqeustHeader && publicReqeustHeader.allValues.count > 0) {
        [publicReqeustHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if(key && obj) {
                [request setValue:obj forHTTPHeaderField:key];
            }
        }];
    }
    
    // 添加特定的请求头
    if(requestHttpHeader && requestHttpHeader.allValues.count > 0) {
        [requestHttpHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if(key && obj) {
                [request setValue:obj forHTTPHeaderField:key];
            }
        }];
    }
}

/// 添加公共参数
- (NSDictionary *)addPublicParams:(NSDictionary *)params {
    NSDictionary *publicParams = [FMHttpConfig shared].publicParams;
    if(!publicParams || publicParams.allKeys.count == 0) { return params; }
    NSMutableDictionary *newParams = [params mutableCopy];
    [newParams addEntriesFromDictionary:publicParams];
    return newParams;
}

// 处理mock数据
- (FMResponse *)requestCompletaion:(FMRequest *)request success:(FMSuccessBlock(id))success fail:(FMFailBlock)fail {
    id responseObject = request.sampleData;
    NSError *error;
    if(responseObject) {
        return [self process:responseObject success:success fail:fail error:nil response:nil request:request];
    } else {
        FMError *fmError = [FMError processError:error];
        fmError.code = @"-1";
        fmError.message = @"数据错误";
        fmError.data = responseObject;
        fmError.reason = FMErrorReasonDataIsNil;
        fail(fmError);
    }
    return nil;
}

// 处理回调数据
- (FMResponse *)process:(id)responseObject success:(FMSuccessBlock(id))success fail:(FMFailBlock)fail error:(NSError *)error response:(NSURLResponse *)response request:(FMRequest *)request {
    /*
     responseObject应该遵送restAPi规范，与服务端约定好格式{"code":0, "message":"", "data":{}}
     */
    NSString *codeKey = [FMHttpConfig shared].codeKey;
    NSString *messageKey = [FMHttpConfig shared].messageKey;
    NSString *dataKey = [FMHttpConfig shared].dataKey;
    NSArray<NSString *> *successCodes = [FMHttpConfig shared].successCodes;
    
    // 业务状态码NSString类型接收
    NSString *responseCode = @"";
    if([responseObject[codeKey] isKindOfClass:[NSString class]]) {
        responseCode = responseObject[codeKey];
    } else if([responseObject[codeKey] isKindOfClass:[NSNumber class]]) {
        responseCode = [NSString stringWithFormat:@"%ld", (long)[responseObject[codeKey] integerValue]];
    }
    NSString *message = responseObject[messageKey];
    id data = responseObject[dataKey];

    FMResponse *fmResponse = nil;
    FMError *fmError = nil;
    
    NSLog(@"httpCode = %ld", ((NSHTTPURLResponse *)response).statusCode);

    if(error) {
        // http请求失败处理
        fmError = [FMError processError:error];
        fmError.code = responseCode;
        fmError.message = message;
        fmError.data = data;
        fmError.reason = FMErrorReasonServiceError;

        if([error.domain isEqualToString:NSURLErrorDomain]) {
            if(error.code == NSURLErrorTimedOut) {
                // timeout
                fmError.reason = FMErrorReasonTimeout;
            }
        }
        
        fail(fmError);
    } else {
        // http请求成功，业务逻辑处理
        // 业务请求成功，响应的code与服务的成功状态码对比
        BOOL bussinessSuccess = NO;
        if([successCodes containsObject:responseCode]) {
            bussinessSuccess = YES;
        }
        
        if(bussinessSuccess) {
            fmResponse = [FMResponse processResult:response responseObject:data request:request error:error];
            fmResponse.code = responseCode;
            fmResponse.message = message;
            success(fmResponse.data, fmResponse);
        } else {
            // 业务失败处理，走错误回调
            fmError = [FMError processError:error];
            fmError.code = responseCode;
            fmError.message = message;
            fmError.data = data;
            fail(fmError);
        }
    }
    
    return fmResponse;
}

- (AFHTTPRequestSerializer *)requestSerializer:(FMRequest *)request {
    FMRequestDataFormat format = FMHttpConfig.shared.dataFormat;
    if(request.dataFormat != FMRequestDataFormatDefault) {
        format = request.dataFormat;
    }
    switch (format) {
        case FMRequestDataFormatDefault:
        case FMRequestDataFormatHTTP:
            return [AFHTTPRequestSerializer serializer];
            break;
            
        case FMRequestDataFormatJSON:
            return [AFJSONRequestSerializer serializer];
            break;
            
        case FMRequestDataFormatPlist:
            return [AFPropertyListRequestSerializer serializer];
            break;
    }
}

// 结果校验
- (BOOL)validObject:(id)responseObject {
    return [NSJSONSerialization isValidJSONObject:responseObject];
}

#pragma mark - 网络检测
- (BOOL)networkReachable {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

#pragma mark -
+ (NSURLSessionDataTask *)uploadFile:(FMRequest *)request
          progress:(void (^)(NSProgress * _Nonnull))uploadProgress
           success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nonnull))success
           failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    NSError *serializationError = nil;
    NSURL *baseUrl = [FMHttpManager.shared baseUrl:request];
    
    void (^bodyBlock)(id <AFMultipartFormData> formData) = ^(id <AFMultipartFormData> formData) {
        NSArray<FMFileInfo *> *files = request.uploadFileInfos;
        for(FMFileInfo *info in files) {
            [formData appendPartWithFileData:info.data name:info.name fileName:info.fileName mimeType:info.mimeType];
        }
    };
    
    // multipartFormRequestWithMethod最后会调用requestByFinalizingMultipartFormData
    // 设置contentType为"multipart/form-data; boundary="
    NSMutableURLRequest *uploadRequest = [[FMHttpManager.shared requestSerializer:request] multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:request.path relativeToURL:baseUrl] absoluteString] parameters:request.params constructingBodyWithBlock:bodyBlock error:&serializationError];
    
    [FMHttpManager.shared addHttpHeader:uploadRequest fmRequest:request];
    
    if(serializationError) {
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        return nil;
    }

    __block NSURLSessionDataTask *task = [FMHttpManager.shared.manager uploadTaskWithStreamedRequest:uploadRequest progress:uploadProgress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(task, error);
            }
        } else {
            if (success) {
                success(task, responseObject);
            }
        }
    }];

    [task resume];

    return task;
}

@end
