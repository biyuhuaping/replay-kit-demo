//
//  ZYBlData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYControlData.h"

@interface ZYBlData : ZYControlData

@property (nonatomic, readwrite) NSUInteger headCode;
@property (nonatomic, readwrite) NSUInteger lenght;
@property (nonatomic, readwrite) NSUInteger address;
@property (nonatomic, readwrite) NSUInteger command;
@property (nonatomic, readwrite) NSUInteger status;

@property (nonatomic, readwrite) NSData* content;

-(NSDictionary*) toDictionary;

@end
