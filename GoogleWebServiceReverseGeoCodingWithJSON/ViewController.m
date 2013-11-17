//
//  ViewController.m
//  Learning_JSON_Parsing
//
//  Created by philopian on 11/8/13.
//  Copyright (c) 2013 philopian. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) float currentLat;
@property (nonatomic) float currentLng;
@property (nonatomic) BOOL userEnableGPSUse;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Start the LocationManager
    [self setupLocationManager];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)setupLocationManager
{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([CLLocationManager locationServicesEnabled]) {
        // start the location manager
        [self.locationManager startUpdatingLocation];
        self.userEnableGPSUse = YES;
        
        //switch thru possible
        
    } else {
        
        // gps is disabled send a message
        self.userEnableGPSUse = NO;
        NSLog(@"Location Service is Disabled");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No GPS"
                                                       message:@"Cannot get your address because there is no GPS"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }
    
}



- (bool)hasInternet {
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.google.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                              timeoutInterval:5.0];
    BOOL connectedToInternet = NO;
    if ([NSURLConnection sendSynchronousRequest:request
                              returningResponse:nil
                                          error:nil]) {
        connectedToInternet = YES;
    }

    return connectedToInternet;
}



-(void)getJSONDataFromWebReverseGeocoding
{
    
    
    
    if ([self hasInternet]) {
        
        
        @try {
            dispatch_queue_t fetchedDataThread = dispatch_queue_create("fetchDataRGeocoding", NULL);
            
            // create WebService URL
            NSString *root = @"http://maps.googleapis.com/maps/api/geocode/json?latlng=";
            NSString *userLocation = [NSString stringWithFormat:@"%f,%f", _currentLat, _currentLng];
            NSString *endPiece= @"&sensor=false";
            NSString *urlString = [NSString stringWithFormat:@"%@%@%@",
                                   root,
                                   userLocation,
                                   endPiece];
            //NSLog(@"%@",urlString);
            NSURL *url = [NSURL URLWithString:urlString];
            
            // block object
            dispatch_async(fetchedDataThread, ^(void){
                // [NSThread sleepForTimeInterval:3];
                
                //parse out the json data
                NSError* error = nil;
                NSData *data = [[NSData alloc] initWithContentsOfURL:url];
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:0
                                                                           error:&error];
                
                if (jsonDict) {
                    NSMutableArray *address = [[NSMutableArray alloc]init];
                    for (id webServiceResult in [jsonDict objectForKey:@"results"]){
                        NSString *currentAddress = [webServiceResult objectForKey:@"formatted_address"];
                        
                        [address addObject:currentAddress];
                    }
                    if ([address count]>0) {
                        //NSLog(@"%@",[address objectAtIndex:0]);
                        NSString *addressResult = [NSString stringWithFormat:@"Current Address: \n%@",[address objectAtIndex:0] ];
                        
                        self.addressResult = addressResult;
                        
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            self.txtCurrentAddress.text = self.addressResult;
                        });
                    }
                    
                } else {
                    NSLog(@"%@",error);
                    NSString *addressResult = [NSString stringWithFormat:@"Current Address: \n Currently Unavailable"];
                    
                    self.addressResult = addressResult;
                }
                
            });
        }
        @finally {
            NSString *addressResult = [NSString stringWithFormat:@"Current Address: \n Currentlu Unavailable"];
            
            self.addressResult = addressResult;
        }
        
    } else {
        NSLog(@"No Internet connection!");
        
        NSString *addressResult = [NSString stringWithFormat:@"Current Address: \nNo Internet Connection Available"];
        
        self.addressResult = addressResult;
    }
 
}




- (IBAction)btnGetCurrentAddress:(id)sender
{

    if ([CLLocationManager locationServicesEnabled]) {
        
        // gps is enabled
        NSLog(@"Location Service is Enabled");
       
        // set lat/lng for current location
        self.currentLat = self.locationManager.location.coordinate.latitude;
        self.currentLng = self.locationManager.location.coordinate.longitude;
        
        // HTTP req & Parse Google WebService JSON
        [self getJSONDataFromWebReverseGeocoding];
        
        
    } else {
        // gps is disabled send a message
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No GPS"
                                                       message:@"Location Service is Disabled, cannot get address"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
        NSLog(@"Location Service is Disabled");
    }

}


@end





















