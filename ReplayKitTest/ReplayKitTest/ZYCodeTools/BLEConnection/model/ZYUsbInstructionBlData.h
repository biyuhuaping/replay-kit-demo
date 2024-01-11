//
//  ZYUsbInstructionBlData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUsbData.h"
#import "ZYBlData.h"

@interface ZYUsbInstructionBlData : ZYUsbData

@property (nonatomic, readwrite, strong) ZYBlData* blData;

@end
