//
//  ZYStarData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYControlData.h"

@interface ZYStarData : ZYControlData

@property (nonatomic, readwrite) NSUInteger code;
@property (nonatomic, readwrite) NSUInteger param;

-(instancetype) initWithCodeAndParam:(NSUInteger)code param:(NSUInteger)param;

@end
