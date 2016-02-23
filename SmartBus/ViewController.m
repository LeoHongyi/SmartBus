//
//  ViewController.m
//  SmartBus
//
//  Created by hongyi liu on 16/2/23.
//  Copyright (c) 2016年 hongyi liu. All rights reserved.
//

#import "ViewController.h"
#import "LHYRoute.h"

@interface ViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *arrTimeField;
@property (weak, nonatomic) IBOutlet UITextField *orField;
@property (weak, nonatomic) IBOutlet UITextField *osField;

@property (weak, nonatomic) IBOutlet UITextField *drField;

@property (weak, nonatomic) IBOutlet UITextField *dsField;

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
    }
    
    if (pickerView.tag == 20) {
        self.drField.text = r.route;
        self.dsField.text = r.stops[stopIndex];
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

@end
