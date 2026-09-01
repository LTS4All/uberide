#import "UBRUberAPIClient.h"
#import <CoreLocation/CoreLocation.h>

static NSString * const UBRUberAPIBaseURL = @"https://api.uber.com/v1";

@implementation UBRUberAPIClient

- (NSURL *)authorizationURLWithClientID:(NSString *)clientID
                           redirectURI:(NSString *)redirectURI {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://login.uber.com/oauth/v2/authorize"];
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"client_id" value:clientID],
        [NSURLQueryItem queryItemWithName:@"response_type" value:@"code"],
        [NSURLQueryItem queryItemWithName:@"scope" value:@"request"],
        [NSURLQueryItem queryItemWithName:@"redirect_uri" value:redirectURI]
    ];
    return components.URL;
}

- (void)requestDetailsForRequestID:(NSString *)requestID
                        completion:(UBRUberRequestCompletion)completion {
    if (self.accessToken.length == 0) {
        NSError *error = [NSError errorWithDomain:@"Uberide.UberAPI"
                                             code:401
                                         userInfo:@{NSLocalizedDescriptionKey: @"An Uber OAuth access token is required."}];
        completion(nil, error);
        return;
    }

    NSString *path = [NSString stringWithFormat:@"%@/requests/%@", UBRUberAPIBaseURL, requestID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, error); });
            return;
        }

        NSError *jsonError = nil;
        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (![payload isKindOfClass:[NSDictionary class]]) {
            NSError *shapeError = [NSError errorWithDomain:@"Uberide.UberAPI"
                                                       code:500
                                                   userInfo:@{NSLocalizedDescriptionKey: @"Uber returned an unexpected response."}];
            dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, jsonError ?: shapeError); });
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{ completion(payload, nil); });
    }] resume];
}

- (void)driverLocationForRequestID:(NSString *)requestID
                        completion:(UBRUberLocationCompletion)completion {
    [self requestDetailsForRequestID:requestID completion:^(NSDictionary *response, NSError *error) {
        if (error != nil) {
            completion(kCLLocationCoordinate2DInvalid, NO, error);
            return;
        }

        NSDictionary *vehicle = [response[@"vehicle"] isKindOfClass:[NSDictionary class]] ? response[@"vehicle"] : nil;
        NSDictionary *location = [vehicle[@"location"] isKindOfClass:[NSDictionary class]] ? vehicle[@"location"] : nil;
        NSNumber *latitude = location[@"latitude"];
        NSNumber *longitude = location[@"longitude"];
        if (![latitude isKindOfClass:[NSNumber class]] || ![longitude isKindOfClass:[NSNumber class]]) {
            completion(kCLLocationCoordinate2DInvalid, NO, nil);
            return;
        }

        completion(CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue), YES, nil);
    }];
}

@end
