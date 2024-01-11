//
//  BlWiFiScanMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiMessage::BlWiFiMessage()
: zy::BlMessage()
{
}

BlWiFiMessage::~BlWiFiMessage()
{
    
}

int BlWiFiMessage::subType() const
{
    return 0;
}

NAMESPACE_ZY_END
