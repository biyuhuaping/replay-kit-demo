//
//  ZYBlHandleData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlHandleData : ZYBlData

@property (nonatomic, readonly) NSUInteger cmdId;
@property (nonatomic, readwrite) NSUInteger cmdCode;
@property (nonatomic, readwrite) NSUInteger cmdArg;

@end
