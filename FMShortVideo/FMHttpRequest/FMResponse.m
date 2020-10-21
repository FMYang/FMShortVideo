//
//  FMResponse.m
//  FMHttpRequest
//
//  Created by fm y on 2019/11/29.
//  Copyright © 2019 fm y. All rights reserved.
//

#import "FMResponse.h"
#import "FMHttpConfig.h"

@implementation FMResponse

+ (FMResponse *)processResult:(NSURLResponse *)response
               responseObject:(id)responseObject
                      request:(FMRequest *)request
                        error:(NSError *)error {
    id parse = [FMHttpConfig shared].parse;
    id result;
    if(parse && request.responseClass) {
        // 存在JSON解析器和模型类，解析数据
        result = [parse mapJSON:responseObject cls:request.responseClass];
    } else {
        // 否则返回原始数据
        result = responseObject;
    }
    FMResponse *fmResponse = [[FMResponse alloc] init];
    fmResponse.request = request;
    fmResponse.data = result;
    fmResponse.response = response;
    fmResponse.responseObject = responseObject;
    return fmResponse;
}

@end
