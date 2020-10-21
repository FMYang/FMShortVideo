//
//  FMError.m
//  FMHttpRequest
//
//  Created by yfm on 2019/12/8.
//  Copyright © 2019 fm y. All rights reserved.
//

#import "FMError.h"

@implementation FMError

+ (FMError *)processError:(NSError *)error {
    FMError *fmError = [[FMError alloc] init];
    fmError.error = error;
    return fmError;
}

@end
