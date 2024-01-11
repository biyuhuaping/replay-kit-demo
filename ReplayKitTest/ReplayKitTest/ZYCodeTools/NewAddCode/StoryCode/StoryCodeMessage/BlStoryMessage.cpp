//
//  BlStoryMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//
#include "BlStoryMessage.h"

#include <assert.h>

NAMESPACE_ZY_BEGIN

BlStoryMessage::BlStoryMessage()
: zy::BlMessage()
{
}

BlStoryMessage::~BlStoryMessage()
{
    
}

int BlStoryMessage::subType() const
{
    return 0;
}

NAMESPACE_ZY_END
