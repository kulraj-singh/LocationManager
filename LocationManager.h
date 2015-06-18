//
//  LocationManager.h
//  Twyst News App
//
//  Created by Kulraj Singh on 23/04/15.
//  Copyright (c) 2015 Mobiloitte Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

@required

- (void)didUpdateToLocation:(CLLocationCoordinate2D)location;
- (void)locationUpdateFailed;

@end

@interface LocationManager : NSObject

@property (strong, nonatomic) id<LocationManagerDelegate> delegate;

- (void)startFetchingLocation;

@end
