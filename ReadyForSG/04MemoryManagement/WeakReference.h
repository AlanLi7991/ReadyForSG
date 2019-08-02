//
//  WeakReference.h
//  ReadyForSG
//
//  Created by 三杜 on 2019/3/21.
//  Copyright © 2019年 Alanli7991. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeakReference : NSObject

@end

NS_ASSUME_NONNULL_END
//----------------------------------------------------------------------------//
#pragma mark - Weak Reference 如何实现
//----------------------------------------------------------------------------//
/**
 * 1. 生命周期：
 *    a. objc_initWeak()
 *    b. objc_storeWeak()
 *    c. clearDeallocating()
 * 2. weak属性实现原理
 *    Runtime维护了一张weak表，用于存储指向某个对象的所有weak指针。
 *    a. 初始化时，runtime调用objc_initWeak()函数，初始化一个新的
 *       weak指针指向对象
 *    b. 添加引用时，objc_initWeak()会调用objc_storeWeak()，更新
 *       指针指向，删除旧指向（若有），创建对应弱引用表
 *    c. 释放时，调用clearDeallocating函数。该函数首先根据对象地址，
 *       获取所有weak指针地址的数组，遍历数组设置其中数据为nil，最后
 *       将记录从表中删除，并清理对象的记录
 * 3. weak引用指向的对象被释放时，weak指针处理过程
 *    a. 调用objc_release
 *    b. 因为引用计数为0，执行dealloc
 *    c. 在dealloc中，执行了_objc_rootDealloc
 *    d. 在_objc_rootDealloc中，调用了object_dispose
 *    e. 调用objc_destructInstance
 *    f. 调用objc_clear_deallocating
 *       I. 获取weak表中以废弃对象的地址为键值的记录
 *       II. 将包含在记录中的所有附有weak修饰符变量的地址，赋值为nil
 *       III. 将weak表中该记录删除
 *       IV. 从引用计数表中删除废弃对象的地址为键值的记录
 */
