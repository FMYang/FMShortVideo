//
//  FMError.h
//  FMHttpRequest
//
//  Created by yfm on 2019/12/8.
//  Copyright © 2019 fm y. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FMErrorReason) {
    /// 没有网络
    FMErrorReasonNetworkLost,
    /// 服务器返回的数据为nil
    FMErrorReasonDataIsNil,
    /// 服务器错误
    FMErrorReasonServiceError,
    /// 客户端错误
    FMErrorReasonClientError,
    /// 请求超时
    FMErrorReasonTimeout
};

NS_ASSUME_NONNULL_BEGIN

@interface FMError : NSObject

@property (nonatomic, strong) NSError *error;

@property (nonatomic, assign) FMErrorReason reason;

@property (nonatomic, copy) NSString *code;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, strong) id data;

+ (FMError *)processError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
