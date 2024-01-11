//
//  BlHDLMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2019/9/4.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#include "BlHDLMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlHDLMessage::BlHDLMessage()
: zy::BlMessage()
{
}

BlHDLMessage::~BlHDLMessage()
{
    
}

int BlHDLMessage::subType() const
{
    return 0;
}

NAMESPACE_ZY_END
