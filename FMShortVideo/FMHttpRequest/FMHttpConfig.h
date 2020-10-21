//
//  FMHttpConfig.h
//  FMHttpRequest
//
//  Created by fm y on 2019/11/29.
//  Copyright © 2019 fm y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMHttpPluginDelegate.h"
#import "FMHttpParseDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMHttpConfig : NSObject

+ (instancetype)shared;

/// 服务器地址
@property (nonatomic, copy) NSString *baseURL;

/// 数据对应的key，默认为"data"
@property (nonatomic, copy) NSString *dataKey;

/// 状态码对应的key，默认为"code"
@property (nonatomic, copy) NSString *codeKey;

/// message对应的key，默认为"message"
@property (nonatomic, copy) NSString *messageKey;

/// 成功业务状态码，默认为"200"
@property (nonatomic, copy) NSArray<NSString *> *successCodes;

/// 超时时间，默认30秒
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/// 公共请求头，默认为@{}
@property (nonatomic, strong, nullable) NSDictionary *publicRequestHeaders;

/// 公共请求参数
@property (nonatomic, strong, nullable) NSDictionary *publicParams;

/// 请求参数，编码格式
@property (nonatomic, assign) FMRequestDataFormat dataFormat;

// json转model的解析器
@property (nonatomic, strong, nullable) id<FMHttpParseDelegate> parse;

/// 插件
@property (nonatomic, strong, nullable) NSArray<id<FMHttpPluginDelegate>> *plugins;

@end

NS_ASSUME_NONNULL_END
