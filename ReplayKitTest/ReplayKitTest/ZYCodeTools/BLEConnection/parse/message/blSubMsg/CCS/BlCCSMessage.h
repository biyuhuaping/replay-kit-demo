//
//  BlWiFiErrorMessage.hpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLCCSMESSAGE_H__
#define __BLCCSMESSAGE_H__

#include "BlMessage.h"

NAMESPACE_ZY_BEGIN

class BlCCSMessage : public BlMessage
{
public:
    BlCCSMessage();
    virtual ~BlCCSMessage();
    
    virtual int subType() const;
};

NAMESPACE_ZY_END

#endif /* __BLCCSMESSAGE_H__ */
