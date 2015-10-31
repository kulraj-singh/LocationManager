//
//  LocationManager.m
//
//  Created by Kulraj Singh on 23/04/15.
//

#define LOCATION_SETTINGS 200

#import "LocationManager.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LocationManager ()<CLLocationManagerDelegate> {
    NSDate *_lastUpdateTime;
    CLLocationManager *_locationManager;
    AppDelegate *_appDelegate;
}

@end

@implementation LocationManager

- (id)init
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
    }
    return self;
}

- (void)fetchAlways
{
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    [_locationManager startUpdatingLocation];
}

- (void)startFetchingLocation
{
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
}

- (void)stopFetchingLocation
{
    [_locationManager stopUpdatingLocation];
}

#pragma mark - alert

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    [self showAlertWithTitle:title message:message cancelButtonTitle:nil otherButtonTitles:@[@"OK"] tag:0];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSArray *)otherButtonTitles tag:(NSInteger)tag
{
    _appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    //TODO: change the extraction of top view controller as per your app structure
    //or pass the view controller as a property. the delegate would usually be a view controller
    UINavigationController *nav = (UINavigationController*)_appDelegate.window.rootViewController;
    UIViewController *vc = (UIViewController*)nav.topViewController;
    
    UIAlertController *uiAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelTitle) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                 {
                                     [uiAlertController dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        [uiAlertController addAction:cancel];
    }
    
    for (NSString *buttonTitle in otherButtonTitles) {
        UIAlertAction* ok = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             {
                                 [uiAlertController dismissViewControllerAnimated:YES completion:nil];
                                 if (tag == LOCATION_SETTINGS) {
                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                 }
                                 
                             }];
        [uiAlertController addAction:ok];
    }
    
    [vc presentViewController:uiAlertController animated:YES completion:nil];
}

#pragma mark - location manager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            break;
        }
            
        case kCLAuthorizationStatusRestricted:
        {
            [self showAlertWithTitle:@"Access Restricted" message:@"You may not have permission for fetching the location"];
            [_locationManager stopUpdatingLocation];
            break;
        }
            
        case kCLAuthorizationStatusDenied:
        {
            [self showAlertWithTitle:@"Location Access Denied" message:@"Please allow access from location settings" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] tag:LOCATION_SETTINGS];
            [_locationManager stopUpdatingLocation];
            break;
        }
            
        default:
        {
            //permission granted
            [_locationManager stopUpdatingLocation];
            [_locationManager startUpdatingLocation];
            break;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    float latitude = [[NSUserDefaults standardUserDefaults]floatForKey:kLatitude];
    float longitude = [[NSUserDefaults standardUserDefaults]floatForKey:kLongitude];
    
    //check if we have some previously stored value
    if (latitude || longitude) {
        [self.delegate didUpdateToLocation:CLLocationCoordinate2DMake(latitude, longitude)];
    } else {
        [self showAlertWithTitle:@"Failed To Update Location" message:@"Please check your internet connection"];
        [self.delegate locationUpdateFailed];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    //store the location as well
    
    CLLocationCoordinate2D coordinate = location.coordinate;
    [[NSUserDefaults standardUserDefaults]setFloat:coordinate.latitude forKey:kLatitude];
    [[NSUserDefaults standardUserDefaults]setFloat:coordinate.longitude forKey:kLongitude];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self.delegate didUpdateToLocation:location.coordinate];
}

- (void)restartLocationFetch
{
    [_locationManager stopUpdatingLocation];
    [_locationManager startUpdatingLocation];
}

@end
