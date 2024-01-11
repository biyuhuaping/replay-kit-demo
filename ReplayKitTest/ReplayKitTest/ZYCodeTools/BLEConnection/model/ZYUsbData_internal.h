//
//  ZYBlData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUsbData.h"

@interface ZYUsbData ()

@property (nonatomic, readwrite, assign) void* message;

@end

#define SAFE_CAST_USB(cls) \
cls* castTo##cls(void* superPt) \
{ \
    cls* value = dynamic_cast<cls*>((UsbMessage*)superPt);\
    assert(value != NULL);\
    return value;\
}

#define CAST_MESSAGE_USB(cls) cls* message = castTo##cls(self.message);
