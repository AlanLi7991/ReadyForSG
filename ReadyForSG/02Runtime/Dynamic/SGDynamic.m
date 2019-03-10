//
//  SGDynamic.m
//  ReadyForSG
//
//  Created by Zhuojia on 2019/3/10.
//  Copyright © 2019 Alanli7991. All rights reserved.
//

#import "SGDynamic.h"

//----------------------------------------------------------------------------//
#pragma mark - "dynamic" 的用法
//----------------------------------------------------------------------------//

/**
 * 参考：
 * https://stackoverflow.com/questions/1160498/synthesize-vs-dynamic-what-are-the-differences
 *
 * 要点：
 * 就是为了编译时通过，告诉编辑器这个东西我可以在运行时实现（比如通过父类去查找）
 *
 * 补充:
 *
 * 因为现在 synthesize Xcode6 之后会默认帮 property 声明了， 所以dynamic 用的也少了
 */

@implementation SGDynamic

@synthesize obj;

@end

@implementation SGSubDynamic

@dynamic obj;

@end
