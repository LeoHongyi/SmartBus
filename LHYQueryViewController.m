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
        self.request.backgroundColor = [UIColor redColor];
        
        
    });
                        

    

}

- (IBAction)holdRequest:(id)sender {
    
    
}






@end
