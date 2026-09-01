#import "UBRHomeViewController.h"

static NSString * const UBRUberEatsURL = @"https://www.ubereats.com/";
static NSString * const UBRUberRidesURL = @"https://m.uber.com/ul/";

@interface UBRHomeViewController ()
@property (nonatomic, strong) UISegmentedControl *sectionControl;
@property (nonatomic, strong) UIStackView *contentStack;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation UBRHomeViewController

- (void)openUberFromButton:(UIButton *)sender {
    NSString *urlString = sender.accessibilityHint;
    if (urlString.length > 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildInterface];
    [self showFood];
}

- (void)buildInterface {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];

    self.contentStack = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.contentStack.axis = UILayoutConstraintAxisVertical;
    self.contentStack.spacing = 12.0;
    self.contentStack.alignment = UIStackViewAlignmentFill;
    self.contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentStack];
    [NSLayoutConstraint activateConstraints:@[
        [self.contentStack.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:8.0],
        [self.contentStack.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-18.0],
        [self.contentStack.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:10.0],
        [self.contentStack.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-10.0],
        [self.contentStack.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20.0]
    ]];

    UIStackView *top = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self smallIconButtonWithTitle:@"⌾"],
        [self labelWithText:@"Uberide" size:20 weight:UIFontWeightRegular],
        [self smallIconButtonWithTitle:@"☰"]
    ]];
    top.axis = UILayoutConstraintAxisHorizontal;
    top.alignment = UIStackViewAlignmentCenter;
    top.distribution = UIStackViewDistributionEqualSpacing;
    [self.contentStack addArrangedSubview:top];

    self.sectionControl = [[UISegmentedControl alloc] initWithItems:@[@"Food", @"Rides"]];
    self.sectionControl.selectedSegmentIndex = 0;
    [self.sectionControl addTarget:self action:@selector(sectionChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentStack addArrangedSubview:self.sectionControl];
}

- (void)sectionChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self showFood];
    } else {
        [self showRides];
    }
}

- (void)clearContent {
    while (self.contentStack.arrangedSubviews.count > 2) {
        UIView *view = self.contentStack.arrangedSubviews.lastObject;
        [self.contentStack removeArrangedSubview:view];
        [view removeFromSuperview];
    }
}

- (void)showFood {
    [self clearContent];
    [self.contentStack addArrangedSubview:[self labelWithText:@"Order food" size:24 weight:UIFontWeightBold]];
    [self.contentStack addArrangedSubview:[self labelWithText:@"Real restaurants, then checkout on Uber Eats." size:12 weight:UIFontWeightRegular]];
    [self.contentStack addArrangedSubview:[self searchFieldWithPlaceholder:@"Search restaurants or cuisine"]];

    NSArray *places = @[
        @[@"Pret A Manger", @"Sandwiches · Coffee", @"Popular near you"],
        @[@"PizzaExpress", @"Pizza · Italian", @"Comfort food favourites"],
        @[@"Five Guys", @"Burgers · American", @"Made to order"],
        @[@"Wagamama", @"Japanese · Noodles", @"Fresh bowls and sides"]
    ];
    for (NSArray *place in places) {
        [self.contentStack addArrangedSubview:[self placeRow:place]];
    }
    [self.contentStack addArrangedSubview:[self webButtonWithTitle:@"Open Uber Eats" URL:UBRUberEatsURL]];
}

- (void)showRides {
    [self clearContent];
    [self.contentStack addArrangedSubview:[self labelWithText:@"Request a ride" size:24 weight:UIFontWeightBold]];
    [self.contentStack addArrangedSubview:[self labelWithText:@"Choose an Uber-style ride, then continue on Uber." size:12 weight:UIFontWeightRegular]];
    [self.contentStack addArrangedSubview:[self searchFieldWithPlaceholder:@"Search ride type"]];

    NSArray *rides = @[
        @[@"UberX", @"Affordable everyday rides"],
        @[@"Uber Comfort", @"Extra legroom and comfort"],
        @[@"UberXL", @"Room for more passengers"]
    ];
    for (NSArray *ride in rides) {
        [self.contentStack addArrangedSubview:[self rideRow:ride]];
    }
    [self.contentStack addArrangedSubview:[self webButtonWithTitle:@"Open Uber" URL:UBRUberRidesURL]];
}

- (UILabel *)labelWithText:(NSString *)text size:(CGFloat)size weight:(CGFloat)weight {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.textColor = [UIColor colorWithWhite:0.07 alpha:1.0];
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.numberOfLines = 0;
    return label;
}

- (UIButton *)smallIconButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:20.0];
    return button;
}

- (UITextField *)searchFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectZero];
    field.placeholder = placeholder;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.font = [UIFont systemFontOfSize:13.0];
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    field.heightAnchor.constraintEqualToConstant:40.0].active = YES;
    return field;
}

- (UIView *)placeRow:(NSArray *)place {
    return [self rowWithTitle:place[0] detail:place[1] note:place[2] buttonTitle:@"BUY" URL:UBRUberEatsURL dark:NO];
}

- (UIView *)rideRow:(NSArray *)ride {
    return [self rowWithTitle:ride[0] detail:ride[1] note:@"Continue securely on Uber" buttonTitle:@"GO" URL:UBRUberRidesURL dark:YES];
}

- (UIView *)rowWithTitle:(NSString *)title detail:(NSString *)detail note:(NSString *)note buttonTitle:(NSString *)buttonTitle URL:(NSString *)url dark:(BOOL)dark {
    UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
    container.layer.borderColor = [UIColor colorWithWhite:0.80 alpha:1.0].CGColor;
    container.layer.borderWidth = 1.0;
    container.layer.cornerRadius = 4.0;
    container.heightAnchor.constraintEqualToConstant:76.0].active = YES;

    UILabel *titleLabel = [self labelWithText:title size:14 weight:UIFontWeightBold];
    UILabel *detailLabel = [self labelWithText:detail size:11 weight:UIFontWeightRegular];
    UILabel *noteLabel = [self labelWithText:note size:10 weight:UIFontWeightRegular];
    noteLabel.textColor = [UIColor grayColor];
    UIStackView *copy = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, detailLabel, noteLabel]];
    copy.axis = UILayoutConstraintAxisVertical;
    copy.spacing = 2.0;
    copy.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *action = [self webButtonWithTitle:buttonTitle URL:url];
    action.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:copy];
    [container addSubview:action];
    [NSLayoutConstraint activateConstraints:@[
        [copy.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:10.0],
        [copy.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
        [action.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-9.0],
        [action.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
        [action.widthAnchor constraintEqualToConstant:47.0],
        [action.heightAnchor constraintEqualToConstant:34.0],
        [copy.trailingAnchor constraintLessThanOrEqualToAnchor:action.leadingAnchor constant:-8.0]
    ]];
    return container;
}

- (UIButton *)webButtonWithTitle:(NSString *)title URL:(NSString *)url {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithWhite:0.08 alpha:1.0];
    button.layer.cornerRadius = 3.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:11.0];
    button.accessibilityHint = url;
    [button addTarget:self action:@selector(openUberFromButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
