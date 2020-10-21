//
//  FMHttpConfig.m
//  FMHttpRequest
//
//  Created by fm y on 2019/11/29.
//  Copyright © 2019 fm y. All rights reserved.
//

#import "FMHttpConfig.h"

@implementation FMHttpConfig

+ (instancetype)shared {
    static FMHttpConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/// 初始化，设置默认值
- (instancetype)init {
    self = [super init];
    if (self) {
        _dataFormat = FMRequestDataFormatJSON;
        _baseURL = @"";
        _dataKey = @"data";
        _codeKey = @"code";
        _messageKey = @"message";
        _successCodes = @[@"200"];
        _timeoutInterval = 30.0;
        _parse = nil;
        _publicRequestHeaders = @{};
    }
    return self;
}

@end
