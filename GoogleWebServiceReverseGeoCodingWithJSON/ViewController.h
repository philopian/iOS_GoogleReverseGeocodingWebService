//
//  ViewController.h
//  Learning_JSON_Parsing
//
//  Created by philopian on 11/8/13.
//  Copyright (c) 2013 philopian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController 
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSString *addressResult;
@property (weak, nonatomic) IBOutlet UITextView *txtCurrentAddress;
- (IBAction)btnGetCurrentAddress:(id)sender;
@end
