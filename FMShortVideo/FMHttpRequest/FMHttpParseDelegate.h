//
//  FMHttpParseDelegate.h
//  FMHttpRequest
//
//  Created by fm y on 2019/12/2.
//  Copyright © 2019 fm y. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FMHttpParseDelegate <NSObject>

@required

/// 解析response，JSON转model
/// @param keyValues JSON对象
/// @param cls 模型类
- (id)mapJSON:(id)keyValues cls:(Class)cls;

@end

NS_ASSUME_NONNULL_END
