//
//  ViewController.m
//  SmartBus
//
//  Created by hongyi liu on 16/2/23.
//  Copyright (c) 2016年 hongyi liu. All rights reserved.
//

#import "ViewController.h"
#import "LHYRoute.h"
#import "MBProgressHUD+HM.h"
#import <MapKit/MapKit.h>


@interface ViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,CLLocationManagerDelegate>
@property(nonatomic,strong)CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet UITextField *arrTimeField;
@property (weak, nonatomic) IBOutlet UITextField *orField;
@property (weak, nonatomic) IBOutlet UITextField *podirField;

@property (weak, nonatomic) IBOutlet UITextField *osField;

@property (weak, nonatomic) IBOutlet UITextField *drField;

@property (weak, nonatomic) IBOutlet UITextField *ptdirField;


@property (weak, nonatomic) IBOutlet UITextField *dsField;

@property (weak, nonatomic) IBOutlet UITextField *currentLocField;

@property (weak, nonatomic) IBOutlet UITextField *desLocField;

@property(nonatomic,strong)NSString *fid;
@property(nonatomic,strong)NSString *ostop;
@property(nonatomic,strong)NSString *dstop;
@property(nonatomic,strong)NSString *orn;
@property(nonatomic,strong)NSString *drn;
@property(nonatomic,strong)NSString *podir;
@property(nonatomic,strong)NSString *ptdir;


@property (nonatomic,weak) UIDatePicker *datePicker;

@property (nonatomic, weak) UIPickerView *pickerView;

@property (nonatomic, strong) NSMutableArray *routes;

@property(nonatomic,assign)NSInteger proIndex;

@property(nonatomic,strong)CLLocationManager *lM;

@property (weak, nonatomic) IBOutlet UILabel *expectedTimeLabel;


//data
@property(strong,nonatomic)NSDictionary *pickerDic;
@property(strong,nonatomic)NSArray *MArray;
@property(strong,nonatomic)NSArray *dirArray;
@property(strong,nonatomic)NSArray *stopArray;
@property(strong,nonatomic)NSArray *selectedArray;

@end

@implementation ViewController




-(CLLocationManager *)lM
{
    
    if (!_lM) {
        _lM = [[CLLocationManager alloc]init];
        _lM.delegate = self;
        _lM.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        [_lM requestWhenInUseAuthorization];
        
    }
    return _lM;
    
  
}

-(CLGeocoder *)geocoder
{
    if (!_geocoder) {
        self.geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}


- (IBAction)navigation:(id)sender {
    
    NSString *startStr = self.currentLocField.text;
    NSString *endStr = self.desLocField.text;
    if (startStr == nil||startStr.length == 0||endStr == nil|| endStr.length == 0) {
        NSLog(@"please input the start or end");
        return;
        
    }
    [self.geocoder geocodeAddressString:startStr completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count == 0) return;
        
        CLPlacemark *startCLPlacemark = [placemarks firstObject];
        
        [self.geocoder geocodeAddressString:endStr completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count == 0) return;
            
            CLPlacemark *endCLPlacemark = [placemarks firstObject];
            
            [self startDirectionsWithstartCLPlacemark:startCLPlacemark endCLPlacemark:endCLPlacemark];
            [self startNavigationWithCLPlacemark:startCLPlacemark  endCLPlacemark:endCLPlacemark];
        }];
    }];
}




-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *loc = [locations lastObject];
    //    self.lat = @(loc.coordinate.latitude).stringValue;
    //    self.lon = @(loc.coordinate.longitude).stringValue;
    //    NSLog(@"%@,%@",self.lat,self.lon);
    [self.geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil) {
            CLPlacemark *placemark = [placemarks firstObject];
            //placemark.locality
            NSLog(@"%@",placemark.name);
            NSLog(@"%@",placemark.locality);
            NSLog(@"%@",placemark.administrativeArea);
            self.currentLocField.text = [NSString stringWithFormat:@"%@ %@ %@",placemark.name,placemark.locality,placemark.administrativeArea];
        }
    }];
    
    [self.lM stopUpdatingLocation];
}

//-(NSMutableArray *)routes
//{
//    if (_routes == nil) {
//        _routes = [NSMutableArray array];
//        
//        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"routes.plist" ofType:nil];
//        NSArray *arr = [NSArray arrayWithContentsOfFile:filePath];
//        for (NSDictionary *dict in arr) {
//            LHYRoute *r = [LHYRoute routeWithDict:dict];
//            [_routes addObject:r];
//        }
//        
//    }
//    
//    return _routes;
//}
-(void)getPickerData{
    
    
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"routes.plist" ofType:nil];
    self.pickerDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.MArray = [self.pickerDic allKeys];
    self.selectedArray = [self.pickerDic objectForKey:[[self.pickerDic allKeys] objectAtIndex:0]];
    if (self.selectedArray.count > 0) {
        self.dirArray = [[self.selectedArray objectAtIndex:0] allKeys];
    }
    if (self.dirArray.count > 0) {
        self.stopArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.dirArray objectAtIndex:0]];
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arrTimeField.delegate = self;
    _orField.delegate = self;
    _drField.delegate = self;
    _dsField.delegate = self;
    _osField.delegate = self;
    _podirField.delegate = self;
    
    [self getPickerData];
    [self setUpArrTimeKeyboard];
    [self setUpORSKeyboards];
    [self setUpDRSkeyboards];
    
    
   
   
    
    
}




-(void)setUpArrTimeKeyboard
{
    UIDatePicker *picker = [[UIDatePicker alloc]init];
    _datePicker = picker;
   
    [picker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    
     _arrTimeField.inputView = picker;
    
    
}

-(void)setUpORSKeyboards
{
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.tag = 10;
   _pickerView = pickerView;
    
    _orField.inputView = pickerView;
    _osField.inputView = pickerView;
    _podirField.inputView = pickerView;
//    _drField.inputView = pickerView;
//    _dsField.inputView = pickerView;
   
 
}

-(void)setUpDRSkeyboards
{
    UIPickerView *pickerView1= [[UIPickerView alloc]init];
    
   _pickerView = pickerView1;
    pickerView1.dataSource = self;
    pickerView1.delegate = self;
    pickerView1.tag = 20;
    
    _drField.inputView = pickerView1;
    _dsField.inputView = pickerView1;
    
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.MArray.count;
    } else if (component == 1) {
        return self.dirArray.count;
    } else {
        return self.stopArray.count;
    }
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.MArray objectAtIndex:row];
    } else if (component == 1) {
        return [self.dirArray objectAtIndex:row];
    } else {
        return [self.stopArray objectAtIndex:row];
    }
    
    

}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.selectedArray = [self.pickerDic objectForKey:[self.MArray  objectAtIndex:row]];
        if (self.selectedArray.count > 0) {
            self.dirArray = [[self.selectedArray objectAtIndex:0] allKeys];
        } else {
            self.dirArray = nil;
        }
        if (self.dirArray.count > 0) {
            self.stopArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.dirArray objectAtIndex:0]];
        } else {
            self.stopArray = nil;
        }
    }
    [pickerView selectedRowInComponent:1];
    [pickerView reloadComponent:1];
    [pickerView selectedRowInComponent:2];
    
    
    if (component == 1) {
        if (self.selectedArray.count > 0 && self.dirArray.count > 0) {
            self.stopArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.dirArray objectAtIndex:row]];
        } else {
            self.stopArray = nil;
        }
        [pickerView selectRow:1 inComponent:2 animated:YES];
    }
    
    [pickerView reloadComponent:2];
   
    
    if (pickerView.tag == 10) {
        //NSLog(@"10");
     NSString *orStr = [self.MArray objectAtIndex:[pickerView selectedRowInComponent:0]];
        self.orField.text = orStr;
        self.podirField.text = [self.dirArray objectAtIndex:[pickerView selectedRowInComponent:1]];
        self.osField.text = [self.stopArray objectAtIndex:[pickerView selectedRowInComponent:2]];
        self.orn = self.orField.text;
        self.podir = self.podirField.text;
        self.ostop = self.osField.text;
        
       
    }
    if (pickerView.tag == 20) {
        self.drField.text =[self.MArray objectAtIndex:[pickerView selectedRowInComponent:0]];
        self.ptdirField.text = [self.dirArray objectAtIndex:[pickerView selectedRowInComponent:1]];
        self.dsField.text =[self.stopArray objectAtIndex:[pickerView selectedRowInComponent:2]];

        self.drn = self.drField.text;
        self.ptdir = self.ptdirField.text;
        self.dstop = self.dsField.text;
    }
    
    
    
}



/**
 #1 column: Route
 #2 column: stop
 */

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self dateChange:_datePicker];
    
    
}

-(void)dateChange:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *formatedDateStr = [dateFormatter stringFromDate:datePicker.date];
    
    _arrTimeField.text = formatedDateStr;
}

//exit keyboard
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.lM startUpdatingLocation];
    [self.view endEditing:YES];
}

- (IBAction)request:(id)sender {
      self.fid = [[[UIDevice currentDevice]identifierForVendor] UUIDString];
      [MBProgressHUD showMessage:@"input...."];
//http://localhost:8080/SmartBus/TestInput
//    NSLog(@"%@,%@,%@,%@,%@",self.fid,self.ostop,self.dstop,self.orn,self.drn);
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/SmartBus/TestInput"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 5;
    request.HTTPMethod = @"post";
    NSString *param = [NSString stringWithFormat:@"fid=%@&ostop=%@&poDir=%@&ptDir=%@&dstop=%@&orn=%@&drn=%@",self.fid,self.ostop,self.podir,self.ptdir,self.dstop,self.orn,self.drn];
    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [MBProgressHUD hideHUD];
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%d",[str intValue]);
        if ([str intValue] == 1) {
            [MBProgressHUD showSuccess:@"input success"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self performSegueWithIdentifier:@"Input2Query" sender:nil];
            });
           
            
//            [MBProgressHUD showMessage:@"query..."];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [MBProgressHUD hideHUD];
//                
//                NSURL *url1 = [NSURL URLWithString:@"http://localhost:8080/SmartBus/TestQuery"];
//                NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:url1];
//                request1.timeoutInterval = 5;
//                request1.HTTPMethod = @"post";
//                NSString *param1 = [NSString stringWithFormat:@"fid=%@",self.fid];
//                request1.HTTPBody = [param1 dataUsingEncoding:NSUTF8StringEncoding];
//                NSOperationQueue *queue1 = [NSOperationQueue currentQueue];
//                [NSURLConnection sendAsynchronousRequest:request1 queue:queue1 completionHandler:^(NSURLResponse *response, NSData *data1, NSError *connectionError) {
//                    NSDictionary *dict1 = [NSJSONSerialization JSONObjectWithData:data1 options:kNilOptions error:nil];
//                    NSLog(@"%@",dict1);
//                    
//                    
//                }];
//                
//            });
           
        }else{
            [MBProgressHUD showError:@"error"];
        }
        
    }];
    
    //[MBProgressHUD showMessage:@"query..."];
   // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       // [MBProgressHUD hideHUD];
        // NSLog(@"hello");
    
    
        
        
//    });
    
}


-(void)startDirectionsWithstartCLPlacemark:(CLPlacemark *)startCLPlacemark endCLPlacemark:(CLPlacemark *)endCLPlacemark
{
    MKPlacemark *startPlacemark = [[MKPlacemark alloc]initWithPlacemark:startCLPlacemark];
    MKMapItem *startItem = [[MKMapItem alloc]initWithPlacemark:startPlacemark];
    
    MKPlacemark *endPlacemark = [[MKPlacemark alloc]initWithPlacemark:endCLPlacemark];
    MKMapItem *endItem = [[MKMapItem alloc]initWithPlacemark:endPlacemark];
    
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    
    request.source = startItem;
    
    request.destination = endItem;
    
    
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    
    [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
        
       // NSLog(@"%f",response.expectedTravelTime);
        
        NSString *expected = [NSString stringWithFormat:@"%@ sec",@(response.expectedTravelTime).stringValue];
        self.expectedTimeLabel.text = expected;
    }];
    
    
    
    

}


-(void)startNavigationWithCLPlacemark:(CLPlacemark *)startCLPlacemark endCLPlacemark:(CLPlacemark *)endCLPlacemark
{
    MKPlacemark *startPlacemark = [[MKPlacemark alloc]initWithPlacemark:startCLPlacemark];
    MKMapItem *startItem = [[MKMapItem alloc]initWithPlacemark:startPlacemark];

    MKPlacemark *endPlacemark = [[MKPlacemark alloc]initWithPlacemark:endCLPlacemark];
    MKMapItem *endItem = [[MKMapItem alloc]initWithPlacemark:endPlacemark];


    NSArray *items = @[startItem,endItem];

    NSMutableDictionary *md = [NSMutableDictionary dictionary];

    md[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeDriving;
    md[MKLaunchOptionsMapTypeKey] = @(MKMapTypeHybrid);

    [MKMapItem openMapsWithItems:items launchOptions:md];
}



@end
