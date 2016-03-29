//
//  LHYQueryViewController.m
//  SmartBus
//
//  Created by hongyi liu on 16/3/3.
//  Copyright (c) 2016年 hongyi liu. All rights reserved.
//

#import "LHYQueryViewController.h"
#import "MBProgressHUD+HM.h"
@interface LHYQueryViewController ()
@property(nonatomic,strong)NSString *fid;
@property(nonatomic,strong)NSString *p_hold_requset;
@property (weak, nonatomic) IBOutlet UILabel *p_next_delay;
@property (weak, nonatomic) IBOutlet UILabel *poBusArrT;

@property (weak, nonatomic) IBOutlet UILabel *podBusArrT;
@property (weak, nonatomic) IBOutlet UIButton *request;

@property (weak, nonatomic) IBOutlet UILabel *hold_success;
@property (assign,nonatomic) int mainInt;
@property (nonatomic, strong) dispatch_source_t timer;
@property (weak, nonatomic) IBOutlet UILabel *warningField;



@end

@implementation LHYQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //self.timer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(sendRequestToGetData:) userInfo:nil repeats:YES];
    //self.mainInt = 5;
    //[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sendRequestToGetData];
        
    });

    

}


-(void)sendRequestToGetData
{
    //self.mainInt -= 1;
    [MBProgressHUD showMessage:@"query..."];
    //self.fid = [[[UIDevice currentDevice]identifierForVendor] UUIDString];
    self.fid = @"238a11fd7ca11bd";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        NSURL *url = [NSURL URLWithString:@"http://localhost:8080/SmartBus/TestQuery"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.timeoutInterval = 5;
        request.HTTPMethod = @"post";
        NSString *param1 = [NSString stringWithFormat:@"fid=%@",self.fid];
        request.HTTPBody = [param1 dataUsingEncoding:NSUTF8StringEncoding];
        NSOperationQueue *queue = [NSOperationQueue currentQueue];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data1, NSError *connectionError) {
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data1 options:kNilOptions error:nil];
           // NSLog(@"%lu",(unsigned long)arr.count);
//            NSLog(@"%lu",(unsigned long)arr.count);
            NSLog(@"%@",arr[0]);
            NSDictionary *dict = arr[0];
            NSLog(@"%@",dict[@"warn"]);
            if (dict[@"warn"] == NULL) {
                 self.poBusArrT.text = dict[@"Connecting Bus Schedule Arrival Time at Transfer Stop"];
                 self.podBusArrT.text = dict[@"First Bus Schedule Arrival Time at Transfer Stop"];
            }else{
                self.warningField.text = dict[@"warn"];
            }
            
                        //if (dict[@"Connecting Bus Schedule Arrival Time at Transfer Stop"] == NULL) {
               // self.warningField.text = arr[0];
            //}
           // self.poBusArrT.text = dict[@"Connecting Bus Schedule Arrival Time at Transfer Stop"];
           //self.podBusArrT.text = dict[@"First Bus Schedule Arrival Time at Transfer Stop"];
          
           // NSLog(@"%@",dict[@"podBusArrT"]);
            
        }];
        self.request.enabled = YES;
        //        self.request.backgroundColor = [UIColor redColor];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"REQUEST" message:@"Do you want to hold request" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"REQUEST" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [MBProgressHUD showMessage:@"update..."];
            NSURL *url1 = [NSURL URLWithString:@"http://localhost:8080/SmartBus/TestHold"];
            NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:url1];
            request1.timeoutInterval = 5;
            request1.HTTPMethod = @"post";
            NSLog(@"%@",self.fid);
            self.p_hold_requset = @"1";
            //
            
            NSString *param1 = [NSString stringWithFormat:@"p_hold_requset=%d&fid=%@",[self.p_hold_requset intValue],self.fid];
            request1.HTTPBody = [param1 dataUsingEncoding:NSUTF8StringEncoding];
            NSOperationQueue *queue = [NSOperationQueue mainQueue];
            [NSURLConnection sendAsynchronousRequest:request1 queue:queue completionHandler:^(NSURLResponse *response, NSData *data1, NSError *connectionError) {
                [MBProgressHUD hideHUD];
                NSString *str1 = [[NSString alloc]initWithData:data1 encoding:NSUTF8StringEncoding];
                NSLog(@"%d",[str1 intValue]);
                if ([str1 intValue] == 1) {
                    [MBProgressHUD showSuccess:@"update success"];
                    
                    [MBProgressHUD showMessage:@"Holding Query...."];
                    NSURL *url2 = [NSURL URLWithString:@"http://localhost:8080/SmartBus/TestHoldQuery"];
                    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:url2];
                    request2.timeoutInterval = 5;
                    request2.HTTPMethod = @"post";
                    NSString *param2 = [NSString stringWithFormat:@"fid=%@",self.fid];
                    request2.HTTPBody = [param2 dataUsingEncoding:NSUTF8StringEncoding];
                    NSOperationQueue *queue = [NSOperationQueue mainQueue];
                    [NSURLConnection sendAsynchronousRequest:request2 queue:queue completionHandler:^(NSURLResponse *response, NSData *data2, NSError *connectionError) {
                        [MBProgressHUD hideHUD];
                        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data2 options:kNilOptions error:nil];
                        NSLog(@"%@",arr);
                        NSDictionary *dict = arr[arr.count-1];
                        NSLog(@"%@",dict);
                        self.hold_success.text = dict[@"p_hold_success"];
                        
                    }];
                   
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, mainQueue);
                    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC));
                    uint64_t interval = (uint64_t)(20.0 * NSEC_PER_SEC);
                    dispatch_source_set_timer(self.timer, start, interval, 0);
                    dispatch_source_set_event_handler(self.timer, ^{
                        
                        NSLog(@"----");
                        NSURL *url3 = [NSURL URLWithString:@"http://localhost:8080/SmartBus/TestRoute"];
                        NSMutableURLRequest *request3 = [NSMutableURLRequest requestWithURL:url3];
                        request3.timeoutInterval = 5;
                        request3.HTTPMethod = @"post";
                        NSString *param2 = [NSString stringWithFormat:@"fid=%@",self.fid];
                        request3.HTTPBody = [param2 dataUsingEncoding:NSUTF8StringEncoding];
                        NSOperationQueue *queue = [NSOperationQueue mainQueue];
                        [NSURLConnection sendAsynchronousRequest:request3 queue:queue completionHandler:^(NSURLResponse *response, NSData *data3, NSError *connectionError) {
                            
                            NSString *str3 = [[NSString alloc]initWithData:data3 encoding:NSUTF8StringEncoding];
                            if ([str3  isEqual: @"arrive"]) {
                                
                                dispatch_cancel(self.timer);
                                self.timer = nil;
                                
                                [MBProgressHUD showMessage:str3];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [MBProgressHUD hideHUD];
                                });
                            } else {
                               [MBProgressHUD showMessage:str3];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [MBProgressHUD hideHUD];
                                });
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                            }
                            
                        }];
                       
                    });
                    dispatch_resume(self.timer);
                    
                    
                }else{
                    [MBProgressHUD showError:@"error"];
                }
                
            }];
            
            
        }]];
        
        
        
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
    });
//    if(self.mainInt == 0){
//        [self.timer invalidate];
//    }
    
    

}

- (IBAction)request:(id)sender {

    
}







@end
