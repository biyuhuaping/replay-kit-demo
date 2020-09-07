//
//  ZYBlData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlData ()

@property (nonatomic, readwrite, assign) void* message;
@property (nonatomic, readwrite) BOOL free;
-(void) setRawData:(void*)data freeWhenDone:(BOOL)free;
@end

#define SAFE_CAST(cls) \
cls* castTo##cls(void* superPt) \
{ \
    cls* value = dynamic_cast<cls*>((BlMessage*)superPt);\
    assert(value != NULL);\
    return value;\
}

#define CAST_MESSAGE(cls) cls* message = castTo##cls(self.message);
