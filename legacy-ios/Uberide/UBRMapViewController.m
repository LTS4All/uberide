#import "UBRMapViewController.h"
#import <MapLibre/MapLibre.h>

static NSString * const UBROpenFreeMapStyleURL = @"https://tiles.openfreemap.org/styles/liberty";

@interface UBRMapViewController () <MGLMapViewDelegate>
@property (nonatomic, strong) MGLMapView *mapView;
@property (nonatomic, strong) MGLPointAnnotation *driverAnnotation;
@end

@implementation UBRMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0.969 green:0.961 blue:0.937 alpha:1.0];
    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds
                                             styleURL:[NSURL URLWithString:UBROpenFreeMapStyleURL]];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 11.0;
    [self.view addSubview:self.mapView];
}

- (void)showDriverLatitude:(double)latitude longitude:(double)longitude {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.driverAnnotation == nil) {
            self.driverAnnotation = [[MGLPointAnnotation alloc] init];
            self.driverAnnotation.title = @"Authorized Uber driver location";
            [self.mapView addAnnotation:self.driverAnnotation];
        }

        self.driverAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        [self.mapView setCenterCoordinate:self.driverAnnotation.coordinate animated:YES];
    });
}

- (void)clearDriverLocation {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.driverAnnotation != nil) {
            [self.mapView removeAnnotation:self.driverAnnotation];
            self.driverAnnotation = nil;
        }
    });
}

- (MGLAnnotationView *)mapView:(MGLMapView *)mapView
             viewForAnnotation:(id<MGLAnnotation>)annotation {
    if (annotation != self.driverAnnotation) {
        return nil;
    }

    static NSString *reuseIdentifier = @"uberide-driver-pin";
    MGLAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (view == nil) {
        view = [[MGLAnnotationView alloc] initWithReuseIdentifier:reuseIdentifier];
        view.frame = CGRectMake(0, 0, 42, 42);
        view.backgroundColor = [UIColor colorWithRed:0.090 green:0.192 blue:0.173 alpha:1.0];
        view.layer.cornerRadius = 21.0;
        view.layer.borderWidth = 4.0;
        view.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return view;
}

@end
