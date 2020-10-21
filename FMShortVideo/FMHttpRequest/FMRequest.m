//
//  FMRequest.m
//  FMHttpRequest
//
//  Created by fm y on 2019/11/29.
//  Copyright © 2019 fm y. All rights reserved.
//

#import "FMRequest.h"

#define FMMethodNotImplemented() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                 userInfo:nil]; \

@implementation FMFileInfo

@end

@implementation FMRequest

- (instancetype)init {
    if(self = [super init]) {
        _method = FMHttpReuqestMethodPost;
        _dataFormat = FMRequestDataFormatJSON;
    }
    return self;
}

#pragma mark -
- (NSString *)requestMethod {
    switch (self.method) {
        case FMHttpReuqestMethodGet:
            return @"GET";
            break;
            
        case FMHttpReuqestMethodPost:
            return @"POST";
            break;
            
        case FMHttpReuqestMethodPut:
            return @"PUT";
            break;
            
        case FMHttpReuqestMethodDelete:
            return @"DELETE";
            break;
            
        default:
            break;
    }
}

#pragma mark -
+ (FMRequest * _Nonnull (^)(void))build {
    return ^ {
        return [[self alloc] init];
    };
}

- (FMRequest * _Nonnull (^)(NSString * _Nullable))reqBaseUrl {
    return ^FMRequest *(NSString *url) {
        self.baseUrl = url;
        return self;
    };
}

- (FMRequest * _Nonnull (^)(NSString * _Nullable))reqUrl {
    return ^FMRequest *(NSString *url) {
        self.path = url;
        return self;
    };
}

- (FMRequest * _Nonnull (^)(FMHttpReuqestMethod))reqMethod {
    return ^FMRequest *(FMHttpReuqestMethod method) {
        self.method = method;
        return self;
    };
}

- (FMRequest * _Nonnull (^)(NSDictionary * _Nullable))reqParams {
    return ^ (NSDictionary *params){
        self.params = params;
        return self;
    };
}

- (FMRequest * _Nonnull (^)(NSDictionary * _Nullable))reqHttpHeader {
    return ^ (NSDictionary *httpHeader) {
        self.httpHeader = httpHeader;
        return self;
    };
}

- (FMRequest * _Nonnull (^)(__unsafe_unretained Class _Nullable))resClass {
    return ^ (Class class) {
        self.responseClass = class;
        return self;
    };
}

- (FMRequest * _Nonnull (^)(NSData * _Nullable))resSampleData {
    return ^ (NSData *data) {
        self.sampleData = data;
        return self;
    };
}

- (FMRequest * _Nonnull (^)(FMRequestDataFormat))reqDataFormat {
    return ^ (FMRequestDataFormat format) {
        self.dataFormat = format;
        return self;
    };
}

- (FMRequest * _Nonnull (^)(NSArray<FMFileInfo *> * _Nullable))reqFileInfos {
    return ^ (NSArray<FMFileInfo *> * files) {
        self.uploadFileInfos = files;
        return self;
    };
}

#pragma mark -
- (NSString *)description {
    return [NSString stringWithFormat:@"url = %@, method = %lu, params = %@", self.baseUrl, (unsigned long)self.method, self.params];
}

@end
