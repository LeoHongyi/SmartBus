//
//  LHYRoute.h
//  SmartBus
//
//  Created by hongyi liu on 16/2/23.
//  Copyright (c) 2016年 hongyi liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LHYRoute : NSObject
@property(nonatomic, strong) NSArray *stops;

@property(nonatomic, strong) NSString *route;

+ (instancetype)routeWithDict:(NSDictionary *)dict;
@end
