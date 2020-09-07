//
//  BlWiFiPhotoMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiPhotoMessage.h"

NAMESPACE_ZY_BEGIN

BlWiFiPhotoMessage::BlWiFiPhotoMessage()
: zy::BlWiFiMessage()
{
}

BlWiFiPhotoMessage::~BlWiFiPhotoMessage()
{
    
}

int BlWiFiPhotoMessage::subType() const
{
    return ZYBIWiFiDeviceCmdPhoto;
}

NAMESPACE_ZY_END
