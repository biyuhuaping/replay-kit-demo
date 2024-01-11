//
//  BlWiFiMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLWIFIPHOTOMESSAGE_H__
#define __BLWIFIPHOTOMESSAGE_H__

#include "BlWiFiMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiPhotoMessage : public BlWiFiMessage
{
public:
    BlWiFiPhotoMessage();
    virtual ~BlWiFiPhotoMessage();
    
    virtual int subType() const;
    virtual int subPhotoType() const = 0;
};

NAMESPACE_ZY_END

#endif /* __BLWIFIPHOTOMESSAGE_H__ */
