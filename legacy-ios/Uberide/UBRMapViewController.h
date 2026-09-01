#import <UIKit/UIKit.h>

@class MGLMapView;

NS_ASSUME_NONNULL_BEGIN

@interface UBRMapViewController : UIViewController

- (void)showDriverLatitude:(double)latitude longitude:(double)longitude;
- (void)clearDriverLocation;

@end

NS_ASSUME_NONNULL_END
