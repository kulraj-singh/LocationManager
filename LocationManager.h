//
//  LocationManager.h
//
//  Created by Kulraj Singh on 23/04/15.
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
