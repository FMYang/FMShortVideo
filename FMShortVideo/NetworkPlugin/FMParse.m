//
//  FMParse.m
//  FMHttpRequest
//
//  Created by fm y on 2019/11/29.
//  Copyright © 2019 fm y. All rights reserved.
//

#import "FMParse.h"
#import <MJExtension/MJExtension.h>

@implementation FMParse

- (id)mapJSON:(id)keyValues cls:(Class)cls {
    if([keyValues isKindOfClass:[NSDictionary class]]) {
        return [cls mj_objectWithKeyValues:keyValues];
    } else if([keyValues isKindOfClass:[NSArray class]]) {
        return [cls mj_objectArrayWithKeyValuesArray:keyValues];
    } else {
        return keyValues;
    }
}

@end
