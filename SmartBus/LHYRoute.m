//
//  LHYRoute.m
//  SmartBus
//
//  Created by hongyi liu on 16/2/23.
//  Copyright (c) 2016年 hongyi liu. All rights reserved.
//

#import "LHYRoute.h"

@implementation LHYRoute

+(instancetype)routeWithDict:(NSDictionary *)dict
{
    LHYRoute *r = [[self alloc]init];
    
    [r setValuesForKeysWithDictionary:dict];
    
    return r;
    
}
@end
