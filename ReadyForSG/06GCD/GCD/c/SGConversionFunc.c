//
//  SGConversionFunc.c
//  ReadyForSG
//
//  Created by vince on 2019/3/29.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#include "SGConversionFunc.h"

float AddCFunction(float (callback) (float x, float y)) {
    return callback(1.1, 2.2);
}
