//
//  FMRequest.h
//  FMHttpRequest
//
//  Created by fm y on 2019/11/29.
//  Copyright © 2019 fm y. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FMRequestDataFormat) {
    /// 默认格式
    FMRequestDataFormatDefault,
    /// 使用HTTP格式序列化请求参数, eg: i=1&j=1
    FMRequestDataFormatHTTP,
    /// 使用JSON格式序列化请求参数，eg: {"i": 1, "j": 1}
    FMRequestDataFormatJSON,
    /// 使用PropertyList格式序列化请求参数，eg: plist文件
    FMRequestDataFormatPlist
};

typedef NS_ENUM(NSUInteger, FMHttpReuqestMethod) {
    FMHttpReuqestMethodGet,
    FMHttpReuqestMethodPost,
    FMHttpReuqestMethodPut,
    FMHttpReuqestMethodDelete
};

@interface FMFileInfo : NSObject

/// 文件二进制数据
@property (nonatomic, strong) NSData *data;

/// 表单字段名的字符串
@property (nonatomic, copy) NSString *name;

/// 文件名
@property (nonatomic, copy) NSString *fileName;

/// 文件扩展名 (For example, the MIME type for a JPEG image is image/jpeg.)
@property (nonatomic, copy) NSString *mimeType;

@end

@interface FMRequest : NSObject

/// 最终请求对象
@property (nonatomic, strong) NSMutableURLRequest *orignalRequest;

/// http请求方法
@property (nonatomic, assign) FMHttpReuqestMethod method;

/// 序列化类型
@property (nonatomic, assign) FMRequestDataFormat dataFormat;

/// 请求url
@property (nonatomic, copy) NSString *path;

/// 请求baseUrl
@property (nonatomic, copy) NSString *baseUrl;

/// 请求参数
@property (nonatomic, strong) NSDictionary *params;

/// 请求超时时间
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/// 请求头
@property (nonatomic, strong) NSDictionary *httpHeader;

/// 响应模型类，网络请求的JSON转成哪个模型
@property (nonatomic, assign) Class responseClass;

/// 插桩数据
@property (nonatomic, strong) NSData *sampleData;

/// 上传的文件数组
@property (nonatomic, strong) NSArray<FMFileInfo *> *uploadFileInfos;

/// 请求方法字符串，请求序列化的时候用到
- (NSString *)requestMethod;

#pragma mark - 链式调用

+ (FMRequest * (^)(void))build;
- (FMRequest * (^)(FMHttpReuqestMethod))reqMethod;
- (FMRequest * (^)(NSString * _Nullable))reqBaseUrl;
- (FMRequest * (^)(NSString * _Nullable))reqUrl;
- (FMRequest * (^)(NSDictionary * _Nullable))reqParams;
- (FMRequest * (^)(NSDictionary * _Nullable))reqHttpHeader;
- (FMRequest * (^)(Class _Nullable))resClass;
- (FMRequest * (^)(NSData * _Nullable))resSampleData;
- (FMRequest * (^)(FMRequestDataFormat))reqDataFormat;
- (FMRequest * (^)(NSArray<FMFileInfo *> * _Nullable))reqFileInfos;

@end

NS_ASSUME_NONNULL_END
