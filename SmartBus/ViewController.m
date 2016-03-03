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


@interface ViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *arrTimeField;
@property (weak, nonatomic) IBOutlet UITextField *orField;
@property (weak, nonatomic) IBOutlet UITextField *osField;

@property (weak, nonatomic) IBOutlet UITextField *drField;

@property (weak, nonatomic) IBOutlet UITextField *dsField;

@property(nonatomic,strong)NSString *fid;
@property(nonatomic,strong)NSString *ostop;
@property(nonatomic,strong)NSString *dstop;
@property(nonatomic,strong)NSString *orn;
@property(nonatomic,strong)NSString *drn;


@property (nonatomic,weak) UIDatePicker *datePicker;

@property (nonatomic, weak) UIPickerView *pickerView;

@property (nonatomic, strong) NSMutableArray *routes;

@property(nonatomic,assign)NSInteger proIndex;
@end

@implementation ViewController

-(NSMutableArray *)routes
{
    if (_routes == nil) {
        _routes = [NSMutableArray array];
        
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"routes.plist" ofType:nil];
        NSArray *arr = [NSArray arrayWithContentsOfFile:filePath];
        for (NSDictionary *dict in arr) {
            LHYRoute *r = [LHYRoute routeWithDict:dict];
            [_routes addObject:r];
        }
        
    }
    
    return _routes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arrTimeField.delegate = self;
    _orField.delegate = self;
    _drField.delegate = self;
    _dsField.delegate = self;
    _osField.delegate = self;
    
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
   // _pickerView = pickerView;
    
    _orField.inputView = pickerView;
    _osField.inputView = pickerView;
//    _drField.inputView = pickerView;
//    _dsField.inputView = pickerView;
   
 
}

-(void)setUpDRSkeyboards
{
    UIPickerView *pickerView1= [[UIPickerView alloc]init];
    
   // _pickerView = pickerView1;
    pickerView1.dataSource = self;
    pickerView1.delegate = self;
    pickerView1.tag = 20;
    
    _drField.inputView = pickerView1;
    _dsField.inputView = pickerView1;
    
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.routes.count;
    }else{
        NSInteger index = [pickerView selectedRowInComponent:0];
        
        LHYRoute *r = self.routes[index];
        
        return r.stops.count;
    }
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        LHYRoute *r = self.routes[row];
        return r.route;
    }else{
        NSInteger index = [pickerView selectedRowInComponent:0];
        
        LHYRoute *r = self.routes[index];
        
        return r.stops[row];
    }
    
    

}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        [pickerView reloadComponent:1];
    }
    
    NSInteger index = [pickerView selectedRowInComponent:0];
    
    LHYRoute *r = self.routes[index];
    
    NSInteger stopIndex = [pickerView selectedRowInComponent:1];
    
    if (pickerView.tag == 10) {
        self.orField.text = r.route;
        self.osField.text = r.stops[stopIndex];
        self.ostop = r.stops[stopIndex];
        self.orn = r.route;
    }
    
    if (pickerView.tag == 20) {
        self.drField.text = r.route;
        self.dsField.text = r.stops[stopIndex];
        self.dstop = r.stops[stopIndex];
        self.drn = r.route;
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
    NSString *param = [NSString stringWithFormat:@"fid=%@&ostop=%@&dstop=%@&orn=%@&drn=%@",self.fid,self.ostop,self.dstop,self.orn,self.drn];
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




@end
