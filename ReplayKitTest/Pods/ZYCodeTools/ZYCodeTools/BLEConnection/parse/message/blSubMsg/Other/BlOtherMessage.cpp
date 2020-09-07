//
//  BlOtherMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherMessage::BlOtherMessage()
: zy::BlMessage()
{
}

BlOtherMessage::~BlOtherMessage()
{
    
}

int BlOtherMessage::subType() const
{
    return 0;
}

NAMESPACE_ZY_END
