//
//  BlCCSMessagee.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlCCSMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlCCSMessage::BlCCSMessage()
: zy::BlMessage()
{
}

BlCCSMessage::~BlCCSMessage()
{
    
}

int BlCCSMessage::subType() const
{
    return 0;
}

NAMESPACE_ZY_END
