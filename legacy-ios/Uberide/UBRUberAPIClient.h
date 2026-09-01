#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^UBRUberRequestCompletion)(NSDictionary * _Nullable response, NSError * _Nullable error);
typedef void (^UBRUberLocationCompletion)(CLLocationCoordinate2D coordinate, BOOL available, NSError * _Nullable error);

@interface UBRUberAPIClient : NSObject

@property (nonatomic, copy, nullable) NSString *accessToken;

- (NSURL *)authorizationURLWithClientID:(NSString *)clientID
                           redirectURI:(NSString *)redirectURI;

- (void)requestDetailsForRequestID:(NSString *)requestID
                        completion:(UBRUberRequestCompletion)completion;

- (void)driverLocationForRequestID:(NSString *)requestID
                        completion:(UBRUberLocationCompletion)completion;

@end

NS_ASSUME_NONNULL_END
