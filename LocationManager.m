//
//  LocationManager.m
//  Twyst News App
//
//  Created by Kulraj Singh on 23/04/15.
//  Copyright (c) 2015 Mobiloitte Inc. All rights reserved.
//

#import "LocationManager.h"
#import <UIKit/UIKit.h>

#define kLatitude @"latitude"
#define kLongitude @"longitude"

#define ShowAlert(myTitle, myMessage) [[[UIAlertView alloc] initWithTitle:myTitle message:myMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show]

@interface LocationManager ()<CLLocationManagerDelegate, UIAlertViewDelegate> {
    CLLocationManager *_locationManager;
}

@end

@implementation LocationManager

- (void)startFetchingLocation
{
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
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
            ShowAlert(@"Access Restricted", @"You may not have permission for fetching the location");
            [_locationManager stopUpdatingLocation];
            break;
        }
            
        case kCLAuthorizationStatusDenied:
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Location Access Denied" message:@"Please allow access from location settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alertView show];
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
        ShowAlert(@"Failed To Update Location", @"Please check your internet connection");
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

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //go to settings
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
