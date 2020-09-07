//
//  BlHDLMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/9/4.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//
#ifndef __BlHDLMessage_H__
#define __BlHDLMessage_H__

#include "BlMessage.h"

NAMESPACE_ZY_BEGIN

class BlHDLMessage : public BlMessage
{
public:
    BlHDLMessage();
    virtual ~BlHDLMessage();
    
    virtual int subType() const;
};

NAMESPACE_ZY_END

#endif /* __BlHDLMessage_H__ */
