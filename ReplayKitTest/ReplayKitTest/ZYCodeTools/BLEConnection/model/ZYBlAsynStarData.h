//
//  ZYBlAsynStarData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlAsynStarData : ZYBlData

@property (nonatomic, readonly) NSUInteger cmdId;
@property (nonatomic, readwrite) NSUInteger code;
@property (nonatomic, readwrite) NSUInteger param;

@end
