#import "UBRHomeViewController.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const UBRUberEatsURL = @"https://www.ubereats.com/";
static NSString * const UBRUberRidesURL = @"https://m.uber.com/ul/";

@interface UBRHomeViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UISegmentedControl *sectionControl;
@property (nonatomic, strong) UITextField *locationField;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) NSArray *foods;
@property (nonatomic, strong) NSArray *rides;
@property (nonatomic, strong) NSDictionary *selectedPlace;
@end

@implementation UBRHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
    self.foods = @[
        @{ @"name": @"Pret A Manger", @"detail": @"Sandwiches · Coffee", @"note": @"Popular near you", @"photo": @"food-table.jpg" },
        @{ @"name": @"PizzaExpress", @"detail": @"Pizza · Italian", @"note": @"Comfort food favourites", @"photo": @"food-table.jpg" },
        @{ @"name": @"Five Guys", @"detail": @"Burgers · American", @"note": @"Made to order", @"photo": @"restaurant-exterior.jpg" },
        @{ @"name": @"Wagamama", @"detail": @"Japanese · Noodles", @"note": @"Fresh bowls and sides", @"photo": @"restaurant-exterior.jpg" },
        @{ @"name": @"Costa Coffee", @"detail": @"Coffee · Bakery", @"note": @"Coffee and light bites", @"photo": @"food-table.jpg" },
        @{ @"name": @"Nando's", @"detail": @"Chicken · Portuguese", @"note": @"Grilled chicken and sides", @"photo": @"restaurant-exterior.jpg" }
    ];
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
    [self.view addSubview:self.scrollView];
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 700)];
    [self.scrollView addSubview:self.contentView];

    UILabel *brand = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, self.view.bounds.size.width - 24, 32)];
    brand.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    brand.text = @"Uberide";
    brand.textAlignment = NSTextAlignmentCenter;
    brand.font = [UIFont systemFontOfSize:22.0];
    brand.textColor = [UIColor blackColor];
    [self.contentView addSubview:brand];

    self.sectionControl = [[UISegmentedControl alloc] initWithItems:@[@"Food", @"Rides"]];
    self.sectionControl.frame = CGRectMake(10, 48, self.view.bounds.size.width - 20, 34);
    self.sectionControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sectionControl.selectedSegmentIndex = 0;
    [self.sectionControl addTarget:self action:@selector(sectionChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.sectionControl];

    self.locationField = [[UITextField alloc] initWithFrame:CGRectMake(10, 92, self.view.bounds.size.width - 94, 36)];
    self.locationField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.locationField.placeholder = @"US or UK town, street or postcode";
    self.locationField.borderStyle = UITextBorderStyleRoundedRect;
    self.locationField.backgroundColor = [UIColor whiteColor];
    self.locationField.font = [UIFont systemFontOfSize:12.0];
    self.locationField.returnKeyType = UIReturnKeySearch;
    self.locationField.delegate = self;
    [self.contentView addSubview:self.locationField];

    UIButton *find = [self blueButtonWithTitle:@"FIND" frame:CGRectMake(self.view.bounds.size.width - 78, 92, 68, 36)];
    find.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [find addTarget:self action:@selector(findLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:find];

    UIButton *nearby = [self silverButtonWithTitle:@"USE MY LOCATION" frame:CGRectMake(10, 134, self.view.bounds.size.width - 20, 30)];
    nearby.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [nearby addTarget:self action:@selector(useMyLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:nearby];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 168, self.view.bounds.size.width - 24, 24)];
    self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.statusLabel.font = [UIFont systemFontOfSize:10.0];
    self.statusLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:self.statusLabel];

    UIButton *ai = [self blueButtonWithTitle:@"Uberide AI" frame:CGRectMake(self.view.bounds.size.width - 95, self.view.bounds.size.height - 48, 85, 32)];
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
    [self addHeading:@"Order Food" subtitle:@"Choose a place, then continue securely on Uber Eats."];
    CGFloat y = 230.0;
    for (NSDictionary *place in self.foods) {
        [self addPlace:place atY:y];
        y += 78.0;
    }
    self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, y + 18.0);
    self.scrollView.contentSize = self.contentView.bounds.size;
    self.statusLabel.text = @"Type a location or use your location.";
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
    heading.text = title; heading.font = [UIFont boldSystemFontOfSize:23.0]; heading.textColor = [UIColor blackColor];
    [self.contentView addSubview:heading];
    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(12, 220, self.view.bounds.size.width - 24, 18)];
    sub.tag = 900; sub.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    sub.text = subtitle; sub.font = [UIFont systemFontOfSize:10.0]; sub.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:sub];
}

- (void)addPlace:(NSDictionary *)place atY:(CGFloat)y {
    UIView *card = [self cardAtY:y];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 62, 62)];
    image.image = [UIImage imageNamed:place[@"photo"]]; image.contentMode = UIViewContentModeScaleAspectFill; image.clipsToBounds = YES; image.layer.cornerRadius = 7.0;
    [card addSubview:image];
    UIButton *info = [UIButton buttonWithType:UIButtonTypeCustom]; info.frame = CGRectMake(76, 5, card.bounds.size.width - 143, 67); info.tag = 901; info.accessibilityValue = place[@"name"];
    info.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft; info.titleLabel.numberOfLines = 3;
    [info setTitle:[NSString stringWithFormat:@"%@\n%@\n%@", place[@"name"], place[@"detail"], place[@"note"]] forState:UIControlStateNormal];
    [info setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; info.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [info addTarget:self action:@selector(placeInfo:) forControlEvents:UIControlEventTouchUpInside]; [card addSubview:info];
    UIButton *buy = [self blueButtonWithTitle:@"BUY" frame:CGRectMake(card.bounds.size.width - 60, 22, 52, 34)]; buy.accessibilityHint = UBRUberEatsURL; buy.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [buy addTarget:self action:@selector(openWebFromButton:) forControlEvents:UIControlEventTouchUpInside]; [card addSubview:buy];
}

- (void)addRide:(NSDictionary *)ride atY:(CGFloat)y {
    UIView *card = [self cardAtY:y];
    UILabel *icon = [[UILabel alloc] initWithFrame:CGRectMake(9, 12, 48, 48)]; icon.text = @"U"; icon.textAlignment = NSTextAlignmentCenter; icon.font = [UIFont boldSystemFontOfSize:22.0]; icon.textColor = [UIColor whiteColor]; icon.backgroundColor = [UIColor darkGrayColor]; icon.layer.cornerRadius = 24.0; icon.clipsToBounds = YES; [card addSubview:icon];
    UILabel *copy = [[UILabel alloc] initWithFrame:CGRectMake(72, 12, card.bounds.size.width - 142, 52)]; copy.autoresizingMask = UIViewAutoresizingFlexibleWidth; copy.numberOfLines = 3; copy.text = [NSString stringWithFormat:@"%@\n%@\nContinue securely on Uber", ride[@"name"], ride[@"detail"]]; copy.font = [UIFont systemFontOfSize:11.0]; copy.textColor = [UIColor blackColor]; [card addSubview:copy];
    UIButton *go = [self blueButtonWithTitle:@"GO" frame:CGRectMake(card.bounds.size.width - 60, 22, 52, 34)]; go.accessibilityHint = UBRUberRidesURL; go.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin; [go addTarget:self action:@selector(openWebFromButton:) forControlEvents:UIControlEventTouchUpInside]; [card addSubview:go];
}

- (UIView *)cardAtY:(CGFloat)y {
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(10, y, self.view.bounds.size.width - 20, 76)]; card.tag = 900; card.autoresizingMask = UIViewAutoresizingFlexibleWidth; card.backgroundColor = [UIColor whiteColor]; card.layer.cornerRadius = 10.0; card.layer.borderColor = [UIColor colorWithWhite:0.72 alpha:1.0].CGColor; card.layer.borderWidth = 1.0; card.layer.shadowColor = [UIColor blackColor].CGColor; card.layer.shadowOpacity = 0.15; card.layer.shadowOffset = CGSizeMake(0, 1); [self.contentView addSubview:card]; return card;
}

- (UIButton *)blueButtonWithTitle:(NSString *)title frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom]; button.frame = frame; button.layer.cornerRadius = 7.0; button.clipsToBounds = YES; button.backgroundColor = [UIColor colorWithRed:0.08 green:0.35 blue:0.63 alpha:1.0]; [button setTitle:title forState:UIControlStateNormal]; [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; button.titleLabel.font = [UIFont boldSystemFontOfSize:11.0]; return button;
}

- (UIButton *)silverButtonWithTitle:(NSString *)title frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom]; button.frame = frame; button.layer.cornerRadius = 7.0; button.clipsToBounds = YES; button.backgroundColor = [UIColor colorWithWhite:0.72 alpha:1.0]; [button setTitle:title forState:UIControlStateNormal]; [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; button.titleLabel.font = [UIFont boldSystemFontOfSize:10.0]; return button;
}

- (void)placeInfo:(UIButton *)sender {
    for (NSDictionary *place in self.foods) { if ([place[@"name"] isEqualToString:sender.accessibilityValue]) { self.selectedPlace = place; break; } }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.selectedPlace[@"name"] message:[NSString stringWithFormat:@"Location: %@\nCategory: %@\nReviews: Not provided by the place data source.", self.locationField.text.length ? self.locationField.text : @"Location not supplied", self.selectedPlace[@"detail"]] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Directions" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [self openDirections]; }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Uber Eats" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [self openOfficialPage:UBRUberEatsURL]; }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)findLocation:(UIButton *)sender { [self.locationField resignFirstResponder]; if (!self.locationField.text.length) { self.statusLabel.text = @"Type a town, street, or postcode first."; return; } self.statusLabel.text = [NSString stringWithFormat:@"Finding places near %@...", self.locationField.text]; [self.geocoder geocodeAddressString:self.locationField.text completionHandler:^(NSArray *placemarks, NSError *error) { dispatch_async(dispatch_get_main_queue(), ^{ self.statusLabel.text = error || !placemarks.count ? @"Location not found. Try another place." : [NSString stringWithFormat:@"Location found: %@", self.locationField.text]; }); }]; }

- (void)useMyLocation:(UIButton *)sender { self.statusLabel.text = @"Requesting your location..."; self.locationManager = [[CLLocationManager alloc] init]; self.locationManager.delegate = self; [self.locationManager requestWhenInUseAuthorization]; [self.locationManager startUpdatingLocation]; }

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations { [manager stopUpdatingLocation]; CLLocation *location = locations.lastObject; self.locationField.text = @"Current location"; self.statusLabel.text = [NSString stringWithFormat:@"Location ready: %.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude]; }
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error { self.statusLabel.text = @"Location unavailable. Type a place instead."; }
- (BOOL)textFieldShouldReturn:(UITextField *)textField { [self findLocation:nil]; return YES; }

- (void)openAI:(UIButton *)sender {
    NSString *place = self.selectedPlace[@"name"] ?: @"no selected place";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Uberide AI" message:[NSString stringWithFormat:@"Ask about %@, directions, reviews, or ordering. Answers use only loaded place facts.", place] preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) { field.placeholder = @"Ask a question"; }];
    [alert addAction:[UIAlertAction actionWithTitle:@"X" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ask" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { UIAlertController *answer = [UIAlertController alertControllerWithTitle:@"Uberide AI" message:[NSString stringWithFormat:@"%@ is listed in Uberide. For ordering, use the Uber Eats button; for travel, use Directions. Review scores are not supplied.", place] preferredStyle:UIAlertControllerStyleAlert]; [answer addAction:[UIAlertAction actionWithTitle:@"X" style:UIAlertActionStyleCancel handler:nil]]; [self presentViewController:answer animated:YES completion:nil]; }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openDirections { NSString *destination = [NSString stringWithFormat:@"%@, %@", self.selectedPlace[@"name"] ?: @"food", self.locationField.text ?: @""]; [self openOfficialPage:[NSString stringWithFormat:@"https://www.google.com/maps/dir/?api=1&destination=%@", [destination stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]; }
- (void)openWebFromButton:(UIButton *)sender { [self openOfficialPage:sender.accessibilityHint]; }

- (void)openOfficialPage:(NSString *)urlString {
    UIViewController *controller = [[UIViewController alloc] init]; controller.view.backgroundColor = [UIColor whiteColor];
    UIButton *close = [self silverButtonWithTitle:@"X" frame:CGRectMake(8, 24, 38, 32)]; [close addTarget:self action:@selector(closeWeb:) forControlEvents:UIControlEventTouchUpInside]; [controller.view addSubview:close];
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, controller.view.bounds.size.width, controller.view.bounds.size.height - 64)]; web.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; web.delegate = self; [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]]; [controller.view addSubview:web]; [self presentViewController:controller animated:YES completion:nil];
}
- (void)closeWeb:(UIButton *)sender { [self dismissViewControllerAnimated:YES completion:nil]; }

@end
