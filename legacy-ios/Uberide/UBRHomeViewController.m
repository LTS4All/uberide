#import "UBRHomeViewController.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const UBRUberEatsURL = @"https://www.ubereats.com/";
static NSString * const UBRUberRidesURL = @"https://m.uber.com/ul/";
static NSString * const UBROverpassURL = @"https://overpass-api.de/api/interpreter";

@interface UBRHomeViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UISegmentedControl *sectionControl;
@property (nonatomic, strong) UITextField *locationField;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSArray *foods;
@property (nonatomic, strong) NSArray *rides;
@property (nonatomic, strong) NSDictionary *selectedPlace;
@end

@implementation UBRHomeViewController

- (UIColor *)charcoal { return [UIColor colorWithRed:0.13 green:0.105 blue:0.09 alpha:1.0]; }
- (UIColor *)surface { return [UIColor colorWithRed:0.19 green:0.145 blue:0.12 alpha:1.0]; }
- (UIColor *)accent { return [UIColor colorWithRed:1.0 green:0.416 blue:0.224 alpha:1.0]; }
- (UIColor *)mutedText { return [UIColor colorWithRed:0.72 green:0.66 blue:0.61 alpha:1.0]; }

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [self charcoal];
    self.foods = @[];
    self.rides = @[
        @{ @"name": @"UberX", @"detail": @"Affordable everyday rides" },
        @{ @"name": @"Uber Comfort", @"detail": @"Extra legroom and comfort" },
        @{ @"name": @"UberXL", @"detail": @"Room for more passengers" }
    ];
    self.geocoder = [[CLGeocoder alloc] init];
    [self buildInterface];
    [self showFood];
}

- (void)buildInterface {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = [self charcoal];
    [self.view addSubview:self.scrollView];
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 700)];
    self.contentView.backgroundColor = [self charcoal];
    [self.scrollView addSubview:self.contentView];

    UILabel *brand = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, self.view.bounds.size.width - 24, 32)];
    brand.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    brand.text = @"Uberide";
    brand.textAlignment = NSTextAlignmentCenter;
    brand.font = [UIFont boldSystemFontOfSize:22.0];
    brand.textColor = [UIColor whiteColor];
    [self.contentView addSubview:brand];

    self.sectionControl = [[UISegmentedControl alloc] initWithItems:@[@"Food", @"Rides"]];
    self.sectionControl.frame = CGRectMake(10, 48, self.view.bounds.size.width - 20, 36);
    self.sectionControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sectionControl.selectedSegmentIndex = 0;
    self.sectionControl.tintColor = [self accent];
    [self.sectionControl addTarget:self action:@selector(sectionChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.sectionControl];

    self.locationField = [[UITextField alloc] initWithFrame:CGRectMake(10, 94, self.view.bounds.size.width - 94, 38)];
    self.locationField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.locationField.placeholder = @"Town, street or postcode";
    self.locationField.borderStyle = UITextBorderStyleNone;
    self.locationField.backgroundColor = [self surface];
    self.locationField.textColor = [UIColor whiteColor];
    self.locationField.tintColor = [self accent];
    self.locationField.layer.cornerRadius = 10.0;
    self.locationField.layer.shadowColor = [UIColor blackColor].CGColor;
    self.locationField.layer.shadowOpacity = 0.28;
    self.locationField.layer.shadowOffset = CGSizeMake(0, 2);
    self.locationField.layer.shadowRadius = 4.0;
    self.locationField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    self.locationField.leftViewMode = UITextFieldViewModeAlways;
    self.locationField.font = [UIFont systemFontOfSize:12.0];
    self.locationField.returnKeyType = UIReturnKeySearch;
    self.locationField.delegate = self;
    [self.contentView addSubview:self.locationField];

    UIButton *find = [self accentButtonWithTitle:@"FIND" frame:CGRectMake(self.view.bounds.size.width - 78, 94, 68, 38)];
    find.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [find addTarget:self action:@selector(findLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:find];

    UIButton *nearby = [self secondaryButtonWithTitle:@"USE MY LOCATION" frame:CGRectMake(10, 140, self.view.bounds.size.width - 20, 32)];
    nearby.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [nearby addTarget:self action:@selector(useMyLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:nearby];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 178, self.view.bounds.size.width - 24, 24)];
    self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.statusLabel.font = [UIFont systemFontOfSize:10.0];
    self.statusLabel.textColor = [self mutedText];
    [self.contentView addSubview:self.statusLabel];

    UIButton *ai = [self accentButtonWithTitle:@"Uberide AI" frame:CGRectMake(self.view.bounds.size.width - 95, self.view.bounds.size.height - 48, 85, 32)];
    ai.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [ai addTarget:self action:@selector(openAI:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ai];
}

- (void)sectionChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) { [self showFood]; } else { [self showRides]; }
}

- (void)removeRows {
    NSArray *subviews = [self.contentView.subviews copy];
    for (UIView *view in subviews) {
        if (view.tag == 900) { [view removeFromSuperview]; }
    }
}

- (void)showFood {
    [self removeRows];
    [self addHeading:@"Order Food" subtitle:@"Live restaurants, cafes, fast food and pubs near you."];
    CGFloat y = 230.0;
    for (NSDictionary *place in self.foods) {
        [self addPlace:place atY:y];
        y += 78.0;
    }
    self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, MAX(y + 18.0, self.view.bounds.size.height));
    self.scrollView.contentSize = self.contentView.bounds.size;
    if (!self.foods.count && !self.statusLabel.text.length) { self.statusLabel.text = @"Type a location or use your location to find places."; }
}

- (void)showRides {
    [self removeRows];
    [self addHeading:@"Rides" subtitle:@"Choose an Uber-style ride, then continue on Uber."];
    CGFloat y = 230.0;
    for (NSDictionary *ride in self.rides) {
        [self addRide:ride atY:y];
        y += 78.0;
    }
    self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, y + 18.0);
    self.scrollView.contentSize = self.contentView.bounds.size;
    self.statusLabel.text = @"Select a ride type.";
}

- (void)addHeading:(NSString *)title subtitle:(NSString *)subtitle {
    UILabel *heading = [[UILabel alloc] initWithFrame:CGRectMake(12, 194, self.view.bounds.size.width - 24, 28)];
    heading.tag = 900; heading.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    heading.text = title; heading.font = [UIFont boldSystemFontOfSize:23.0]; heading.textColor = [UIColor whiteColor];
    [self.contentView addSubview:heading];
    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(12, 220, self.view.bounds.size.width - 24, 18)];
    sub.tag = 900; sub.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    sub.text = subtitle; sub.font = [UIFont systemFontOfSize:10.0]; sub.textColor = [self mutedText];
    [self.contentView addSubview:sub];
}

- (void)addPlace:(NSDictionary *)place atY:(CGFloat)y {
    UIView *card = [self cardAtY:y];
    UILabel *category = [[UILabel alloc] initWithFrame:CGRectMake(7, 7, 62, 62)];
    category.text = place[@"icon"] ?: @"R";
    category.textAlignment = NSTextAlignmentCenter;
    category.font = [UIFont boldSystemFontOfSize:22.0];
    category.textColor = [UIColor whiteColor];
    category.backgroundColor = [self accent];
    category.layer.cornerRadius = 11.0;
    category.clipsToBounds = YES;
    [card addSubview:category];
    UIButton *info = [UIButton buttonWithType:UIButtonTypeCustom]; info.frame = CGRectMake(76, 5, card.bounds.size.width - 143, 67); info.tag = 901; info.accessibilityValue = place[@"name"];
    info.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft; info.titleLabel.numberOfLines = 3;
    [info setTitle:[NSString stringWithFormat:@"%@\n%@\n%@", place[@"name"], place[@"detail"], place[@"note"]] forState:UIControlStateNormal];
    [info setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; info.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [info addTarget:self action:@selector(placeInfo:) forControlEvents:UIControlEventTouchUpInside]; [card addSubview:info];
    UIButton *buy = [self accentButtonWithTitle:@"BUY" frame:CGRectMake(card.bounds.size.width - 60, 22, 52, 34)]; buy.accessibilityHint = UBRUberEatsURL; buy.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [buy addTarget:self action:@selector(openWebFromButton:) forControlEvents:UIControlEventTouchUpInside]; [card addSubview:buy];
}

- (void)addRide:(NSDictionary *)ride atY:(CGFloat)y {
    UIView *card = [self cardAtY:y];
    UILabel *icon = [[UILabel alloc] initWithFrame:CGRectMake(9, 12, 48, 48)]; icon.text = @"U"; icon.textAlignment = NSTextAlignmentCenter; icon.font = [UIFont boldSystemFontOfSize:22.0]; icon.textColor = [UIColor whiteColor]; icon.backgroundColor = [self accent]; icon.layer.cornerRadius = 24.0; icon.clipsToBounds = YES; [card addSubview:icon];
    UILabel *copy = [[UILabel alloc] initWithFrame:CGRectMake(72, 12, card.bounds.size.width - 142, 52)]; copy.autoresizingMask = UIViewAutoresizingFlexibleWidth; copy.numberOfLines = 3; copy.text = [NSString stringWithFormat:@"%@\n%@\nContinue securely on Uber", ride[@"name"], ride[@"detail"]]; copy.font = [UIFont systemFontOfSize:11.0]; copy.textColor = [UIColor whiteColor]; [card addSubview:copy];
    UIButton *go = [self accentButtonWithTitle:@"GO" frame:CGRectMake(card.bounds.size.width - 60, 22, 52, 34)]; go.accessibilityHint = UBRUberRidesURL; go.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin; [go addTarget:self action:@selector(openWebFromButton:) forControlEvents:UIControlEventTouchUpInside]; [card addSubview:go];
}

- (UIView *)cardAtY:(CGFloat)y {
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(10, y, self.view.bounds.size.width - 20, 76)]; card.tag = 900; card.autoresizingMask = UIViewAutoresizingFlexibleWidth; card.backgroundColor = [self surface]; card.layer.cornerRadius = 12.0; card.layer.shadowColor = [UIColor blackColor].CGColor; card.layer.shadowOpacity = 0.32; card.layer.shadowOffset = CGSizeMake(0, 3); card.layer.shadowRadius = 5.0; [self.contentView addSubview:card]; return card;
}

- (UIButton *)accentButtonWithTitle:(NSString *)title frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom]; button.frame = frame; button.layer.cornerRadius = 9.0; button.clipsToBounds = YES; button.backgroundColor = [self accent]; [button setTitle:title forState:UIControlStateNormal]; [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; button.titleLabel.font = [UIFont boldSystemFontOfSize:11.0]; return button;
}

- (UIButton *)secondaryButtonWithTitle:(NSString *)title frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom]; button.frame = frame; button.layer.cornerRadius = 9.0; button.clipsToBounds = YES; button.backgroundColor = [self surface]; [button setTitle:title forState:UIControlStateNormal]; [button setTitleColor:[self mutedText] forState:UIControlStateNormal]; button.titleLabel.font = [UIFont boldSystemFontOfSize:10.0]; return button;
}

- (void)placeInfo:(UIButton *)sender {
    for (NSDictionary *place in self.foods) { if ([place[@"name"] isEqualToString:sender.accessibilityValue]) { self.selectedPlace = place; break; } }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.selectedPlace[@"name"] message:[NSString stringWithFormat:@"Location: %@\nCategory: %@\nReviews: OpenStreetMap place data does not provide review scores.", self.locationField.text.length ? self.locationField.text : @"Location not supplied", self.selectedPlace[@"detail"]] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"X" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Directions" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [self openDirections]; }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Uber Eats" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [self openOfficialPage:UBRUberEatsURL]; }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)findLocation:(UIButton *)sender {
    [self.locationField resignFirstResponder];
    if (!self.locationField.text.length) { self.statusLabel.text = @"Type a town, street, or postcode first."; return; }
    NSString *query = [self.locationField.text copy];
    self.statusLabel.text = [NSString stringWithFormat:@"Finding places near %@...", query];
    [self.geocoder geocodeAddressString:query completionHandler:^(NSArray *placemarks, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !placemarks.count) { self.statusLabel.text = @"Location not found. Try another place."; return; }
            CLPlacemark *place = [placemarks firstObject];
            CLLocation *location = place.location;
            self.lastLocation = location;
            self.statusLabel.text = [NSString stringWithFormat:@"Loading live places near %@...", query];
            [self loadOverpassPlacesNear:location];
        });
    }];
}

- (void)useMyLocation:(UIButton *)sender {
    self.statusLabel.text = @"Requesting your location...";
    self.locationManager = [[CLLocationManager alloc] init]; self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization]; [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [manager stopUpdatingLocation]; CLLocation *location = [locations lastObject]; self.lastLocation = location;
    self.locationField.text = @"Current location"; self.statusLabel.text = @"Loading live places near you..."; [self loadOverpassPlacesNear:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error { self.statusLabel.text = @"Location unavailable. Type a place instead."; }
- (BOOL)textFieldShouldReturn:(UITextField *)textField { [self findLocation:nil]; return YES; }

- (void)loadOverpassPlacesNear:(CLLocation *)location {
    NSString *query = [NSString stringWithFormat:@"[out:json][timeout:20];(nwr(around:5000,%.7f,%.7f)[amenity~\"restaurant|cafe|fast_food|pub\"];);out center;", location.coordinate.latitude, location.coordinate.longitude];
    NSString *encoded = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UBROverpassURL]];
    request.HTTPMethod = @"POST"; request.HTTPBody = [[NSString stringWithFormat:@"data=%@", encoded] dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"Uberide/1.0 (iOS 9.3.5)" forHTTPHeaderField:@"User-Agent"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) { dispatch_async(dispatch_get_main_queue(), ^{ self.statusLabel.text = @"Live places unavailable. Try again shortly."; }); return; }
        NSError *jsonError = nil; NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        NSArray *elements = json[@"elements"]; NSMutableArray *results = [NSMutableArray array];
        for (NSDictionary *element in elements) {
            NSDictionary *tags = element[@"tags"]; NSString *name = tags[@"name"];
            if (!name.length) { continue; }
            NSString *amenity = tags[@"amenity"] ?: @"place";
            NSString *cuisine = tags[@"cuisine"];
            NSString *detail = cuisine.length ? [NSString stringWithFormat:@"%@ · %@", amenity, cuisine] : amenity;
            NSString *icon = @"R";
            if ([amenity isEqualToString:@"cafe"]) { icon = @"C"; }
            else if ([amenity isEqualToString:@"fast_food"]) { icon = @"F"; }
            else if ([amenity isEqualToString:@"pub"]) { icon = @"P"; }
            NSString *cuisineLower = [cuisine lowercaseString];
            if ([cuisineLower rangeOfString:@"indian"].location != NSNotFound) { icon = @"I"; }
            else if ([cuisineLower rangeOfString:@"pizza"].location != NSNotFound) { icon = @"Z"; }
            NSString *street = tags[@"addr:street"]; NSString *house = tags[@"addr:housenumber"];
            NSString *note = street.length ? [NSString stringWithFormat:@"%@%@", house.length ? [house stringByAppendingString:@" "] : @"", street] : @"Live OpenStreetMap result";
            [results addObject:@{ @"name": name, @"detail": detail, @"note": note, @"icon": icon }];
            if (results.count >= 100) { break; }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (jsonError || !results.count) { self.statusLabel.text = @"No named places found nearby. Try another location."; return; }
            self.foods = results; self.statusLabel.text = [NSString stringWithFormat:@"Showing %lu live places near you.", (unsigned long)results.count];
            if (self.sectionControl.selectedSegmentIndex == 0) { [self showFood]; }
        });
    }];
    [task resume];
}

- (void)openAI:(UIButton *)sender {
    NSString *place = self.selectedPlace[@"name"] ?: @"no selected place";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Uberide AI" message:[NSString stringWithFormat:@"Ask about %@, directions, reviews, or ordering. Answers use loaded OpenStreetMap place facts.", place] preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) { field.placeholder = @"Ask a question"; }];
    [alert addAction:[UIAlertAction actionWithTitle:@"X" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ask" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { UIAlertController *answer = [UIAlertController alertControllerWithTitle:@"Uberide AI" message:[NSString stringWithFormat:@"%@ is a live OpenStreetMap result. Use Directions for navigation or Uber Eats to continue an order. Review scores are not supplied by Overpass.", place] preferredStyle:UIAlertControllerStyleAlert]; [answer addAction:[UIAlertAction actionWithTitle:@"X" style:UIAlertActionStyleCancel handler:nil]]; [self presentViewController:answer animated:YES completion:nil]; }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openDirections { NSString *destination = [NSString stringWithFormat:@"%@, %@", self.selectedPlace[@"name"] ?: @"food", self.locationField.text ?: @""]; [self openOfficialPage:[NSString stringWithFormat:@"https://www.google.com/maps/dir/?api=1&destination=%@", [destination stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]]; }
- (void)openWebFromButton:(UIButton *)sender { [self openOfficialPage:sender.accessibilityHint]; }

- (void)openOfficialPage:(NSString *)urlString {
    NSString *surfURL = [NSString stringWithFormat:@"surf-https://%@", [urlString substringFromIndex:[@"https://" length]]];
    NSURL *surfAddress = [NSURL URLWithString:surfURL];
    if ([[UIApplication sharedApplication] canOpenURL:surfAddress] && [[UIApplication sharedApplication] openURL:surfAddress]) {
        return;
    }
    UIViewController *controller = [[UIViewController alloc] init]; controller.view.backgroundColor = [self charcoal];
    UIButton *close = [self secondaryButtonWithTitle:@"X" frame:CGRectMake(8, 24, 38, 32)]; [close addTarget:self action:@selector(closeWeb:) forControlEvents:UIControlEventTouchUpInside]; [controller.view addSubview:close];
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, controller.view.bounds.size.width, controller.view.bounds.size.height - 64)]; web.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; web.delegate = self; [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]]; [controller.view addSubview:web]; [self presentViewController:controller animated:YES completion:nil];
}
- (void)closeWeb:(UIButton *)sender { [self dismissViewControllerAnimated:YES completion:nil]; }

@end
