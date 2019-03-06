//
//  ReadyForWX.h
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/6.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//-----------------------------------------------------------------------------
//MARK: OC 引用Swift文件
// 1. 这里不能使用 #import "ReadyForSG-Swift.h"
// 2. 因为 Bridging-Header里加载了ReadyForWX.h 导致头文件循环编译无法通过
// 3. 这里应该使用 @class 声明 Swift的类
// 4. 并且在 .m 里使用 "ReadyForSG-Swift.h"
//-----------------------------------------------------------------------------

@class SGSampleRune;
@class SGSampleRunes;

@interface ReadyForWX : UIViewController


+ (SGSampleRune *)rune;
+ (SGSampleRunes *)runes;

@end

NS_ASSUME_NONNULL_END
