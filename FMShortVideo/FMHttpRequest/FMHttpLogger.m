//
//  FMHttpLogger.m
//  FMHttpRequest
//
//  Created by fm y on 2019/12/2.
//  Copyright © 2019 fm y. All rights reserved.
//

#import "FMHttpLogger.h"

@implementation FMHttpLogger

+ (void)didReceive:(nullable NSURLSessionTask *)task responseObject:(FMResponse *)response error:(NSError *)error {
    NSURLRequest *_request = task.originalRequest;
    NSHTTPURLResponse *_response = (NSHTTPURLResponse *)task.response;
    NSString *httpMethod = _request.HTTPMethod;
    NSString *url = _request.URL.absoluteString;
    NSInteger code = (response.request.sampleData != nil) ? 200 : _response.statusCode;
    NSDictionary *httpHeader = _request.allHTTPHeaderFields;
    NSString *params = [[NSString alloc] initWithData:_request.HTTPBody encoding:NSUTF8StringEncoding];
    NSError *parseError;
    NSData *responseData = nil;
    id responseObject = response.responseObject;
    @try {
         responseData = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:&parseError];
    } @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    }
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSMutableString *output = [NSMutableString string];
    [output appendString:@"\n===================== BEGIN =====================\n"];
    [output appendFormat:@"url:\n %@\n\r", url];
    [output appendFormat:@"params:\n %@\n\r", params];
    [output appendFormat:@"method: \n%@\n\r", httpMethod];
    [output appendFormat:@"stateCode: \n%ld\n\r", (long)code];
    [output appendFormat:@"httpHeader: \n%@\n\r", httpHeader];
    if(error) {
        [output appendFormat:@"error: \n%@\n\r", error];
    } else {
        [output appendFormat:@"data: \n%@\n\r", responseString];
    }
    [output appendString:@"====================== END ======================"];
    
    NSLog(@"%@", output);
}

@end
