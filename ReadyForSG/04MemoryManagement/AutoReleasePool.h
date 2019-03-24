//
//  AutoReleasePool.h
//  ReadyForSG
//
//  Created by 三杜 on 2019/3/21.
//  Copyright © 2019年 Alanli7991. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AutoReleasePool : NSObject

@end

NS_ASSUME_NONNULL_END
//----------------------------------------------------------------------------//
#pragma mark - Auto Release Pool Page
//----------------------------------------------------------------------------//
/**
 * 1. @autoreleasepool{}实际上就是在某个作用阈创建一个变量，
 *    变量的构造函数调用了一个Push函数，析构函数调用了一个Pop函数。
 * 2. auto release是通过AutoreleasePoolPage来实现Push和Pop的。
 * 3. AutoreleasePoolPage是一个双向链表，和线程一一对应。
 * 4. AutoreleasePoolPage结构
 *    a. id* next：栈指针，指向最新入栈的对象
 *    b. AutoreleasePoolPage *child, parent：链表的父节点和子节点
 *    c. pthread_t const thread：绑定的线程
 * 5. 嵌套使用：通过插入哨兵对象实现嵌套使用
 */

//----------------------------------------------------------------------------//
#pragma mark - Auto Release Pool C++ Impl
//----------------------------------------------------------------------------//
/**
 *   { __AtAutoreleasePool __autoreleasepool;
     NSLog((NSString *)&__NSConstantStringImpl__var_folders_kb_06b822gn59df4d1zt99361xw0000gn_T_main_d39a79_mi_0);
 }
 
 
 struct __AtAutoreleasePool {
 __AtAutoreleasePool() {atautoreleasepoolobj = objc_autoreleasePoolPush();}
 ~__AtAutoreleasePool() {objc_autoreleasePoolPop(atautoreleasepoolobj);}
 void * atautoreleasepoolobj;
 };
 
 */
