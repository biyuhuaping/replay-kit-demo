//
//  common_def.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __common_def_h__
#define __common_def_h__

#include "common_macro.h"

typedef unsigned char BYTE;
typedef unsigned char uint8;
typedef unsigned short uint16;
typedef short int int16;
typedef unsigned int uint32;

typedef enum {
    SCCContentTypeAdr = 0x01,
    SCCContentTypeData = 0x01 << 1,
    SCCContentTypeCrc = 0x01 << 2,
    
    SCCContentTypeShort = SCCContentTypeAdr | SCCContentTypeData,
    SCCContentTypeFull = SCCContentTypeShort | SCCContentTypeCrc,
    
} SCCContentType;

#define SAFE_RELEASE_PRT(ptr) if ((ptr) != NULL) {delete (ptr); (ptr) = NULL;}

#include "blMsgdef.h"

#endif /* __common_def_h__ */
