//
//  BaseMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BASEMESSAGE_H__
#define __BASEMESSAGE_H__

#include <stdio.h>
#include "common_macro.h"
#include "common_def.h"
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

NAMESPACE_ZY_BEGIN

class BaseMessage
{
public:
    BaseMessage();
    virtual ~BaseMessage();
    
protected:
    int m_byteLen;
};

NAMESPACE_ZY_END

#endif /* __BASEMESSAGE_H__ */
