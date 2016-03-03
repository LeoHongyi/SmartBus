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


@end

@implementation LHYQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MBProgressHUD showMessage:@"query..."];
    self.fid = [[[UIDevice currentDevice]identifierForVendor] UUIDString];
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
            NSDictionary *dict = arr[arr.count-1];
            NSLog(@"%@",dict);
            self.p_next_delay.text = dict[@"p_next_delay"];
            self.poBusArrT.text = dict[@"poBusArrT"];
            self.podBusArrT.text = dict[@"podBusArrT"];
            
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
            NSString *param1 = [NSString stringWithFormat:@"p_hold_requset=%d&fid=%@",[self.p_hold_requset intValue],self.fid];
            request1.HTTPBody = [param1 dataUsingEncoding:NSUTF8StringEncoding];
            NSOperationQueue *queue = [NSOperationQueue currentQueue];
            [NSURLConnection sendAsynchronousRequest:request1 queue:queue completionHandler:^(NSURLResponse *response, NSData *data1, NSError *connectionError) {
                [MBProgressHUD hideHUD];
                NSString *str1 = [[NSString alloc]initWithData:data1 encoding:NSUTF8StringEncoding];
                NSLog(@"%d",[str1 intValue]);
                if ([str1 intValue] == 1) {
                    [MBProgressHUD showSuccess:@"update success"];
                }else{
                    [MBProgressHUD showError:@"error"];
                }
                
            }];
            
            
        }]];
        
        
        [self presentViewController:alert animated:YES completion:nil];
      
        
    });
                        

    

}

- (IBAction)request:(id)sender {
//    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"REQUEST" message:@"Do you want to hold request" preferredStyle:UIAlertControllerStyleActionSheet];
//    [alert addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//        
//    }]];
//    [alert addAction:[UIAlertAction actionWithTitle:@"REQUEST" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [MBProgressHUD showMessage:@"update..."];
//        NSURL *url1 = [NSURL URLWithString:@"http://localhost:8080/SmartBus/TestHold"];
//        NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:url1];
//        request1.timeoutInterval = 5;
//        request1.HTTPMethod = @"post";
//        NSLog(@"%@",self.fid);
//        self.p_hold_requset = @"1";
//        NSString *param1 = [NSString stringWithFormat:@"p_hold_requset=%d&fid=%@",[self.p_hold_requset intValue],self.fid];
//        request1.HTTPBody = [param1 dataUsingEncoding:NSUTF8StringEncoding];
//        NSOperationQueue *queue = [NSOperationQueue currentQueue];
//        [NSURLConnection sendAsynchronousRequest:request1 queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//            [MBProgressHUD hideHUD];
//            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"%d",[str intValue]);
//            if ([str intValue] == 1) {
//                [MBProgressHUD showSuccess:@"update success"];
//            }else{
//                [MBProgressHUD showError:@"error"];
//            }
//            
//        }];
//        
//        
//    }]];
//    
//    
//    [self presentViewController:alert animated:YES completion:nil];
    
}







@end
