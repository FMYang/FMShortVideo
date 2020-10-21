//
//  FMParse.h
//  FMHttpRequest
//
//  Created by fm y on 2019/11/29.
//  Copyright © 2019 fm y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMHttpRequest/FMHttpParseDelegate.h>

NS_ASSUME_NONNULL_BEGIN

/// 默认解析器，符合FMHttpParseDelegate协议
@interface FMParse : NSObject <FMHttpParseDelegate>

@end

NS_ASSUME_NONNULL_END
