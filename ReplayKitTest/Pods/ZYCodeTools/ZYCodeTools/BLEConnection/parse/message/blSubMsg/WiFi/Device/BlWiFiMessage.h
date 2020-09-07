//
//  BlWiFiErrorMessage.hpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLWIFIMESSAGE_H__
#define __BLWIFIMESSAGE_H__

#include "BlMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiMessage : public BlMessage
{
public:
    BlWiFiMessage();
    virtual ~BlWiFiMessage();
    
    virtual int subType() const;
};

NAMESPACE_ZY_END

#endif /* __BLWIFIMESSAGE_H__ */
