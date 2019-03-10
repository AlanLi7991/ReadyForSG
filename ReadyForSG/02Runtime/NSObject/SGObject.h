//
// Created by Elliot Li on 2019-03-07.
// Copyright (c) 2019 Alanli7991. All rights reserved.
//

#import <UIKit/UIKit.h>


//----------------------------------------------------------------------------//
#pragma mark - Object 和 Class的关系
//----------------------------------------------------------------------------//

/**
 *
 * typedef struct objc_class *Class;
 * Class是结构体 objc_class 指针
 *
 * Apple源代码：
 * https://opensource.apple.com/source/cctools/cctools-921/otool/print_objc.c.auto.html
 * Apple官方文档：
 * https://developer.apple.com/documentation/objectivec/objective-c_data_types?language=objc
 */

//----------------------------------------------------------------------------//
#pragma mark - objc_class的结构详情
//----------------------------------------------------------------------------//

/**
 * struct objc_class {
 // 指向另外一个Class，MetaClass
 Class _Nonnull isa;
 
 // 指向父类
 Class _Nullable super_class                              ;
 
 // 当前的Class名称，用户起的
 const char * _Nonnull name                               ;
 
 // 版本号
 long version                                             ;
 
 // 信息
 long info                                                ;
 
 // 当前结构体的大小
 long instance_size                                       ;
 
 // ivar代表 Instance Variable 实例的参数列表 也是个结构体
 struct objc_ivar_list * _Nullable ivars                  ;
 
 // 方法列表
 // 注意是个二级指针 两个星号
 struct objc_method_list * _Nullable * _Nullable methodLists;
 
 // 调用方法的缓存
 struct objc_cache * _Nonnull cache                       ;
 
 // 协议列表
 struct objc_protocol_list * _Nullable protocols          ;
 
 };
 */

//----------------------------------------------------------------------------//
#pragma mark - objc_ivar_list 结构详情
//----------------------------------------------------------------------------//

/**
 struct objc_ivar_list_t {
 // 记录了长度
 int32_t ivar_count;
 
 // 变量本身也是一个结构体
 // variable length structure
 struct objc_ivar_t ivar_list[1];
 };
 
 struct objc_ivar_t {
 // char * (32-bit pointer)
 uint32_t ivar_name
 // char * (32-bit pointer)
 uint32_t ivar_type;
 //
 int32_t ivar_offset;
 };
 
 */

//----------------------------------------------------------------------------//
#pragma mark - 方法列表的二级指针
//----------------------------------------------------------------------------//

/**
 *
 struct objc_method_list_t {
 uint32_t obsolete;
 
 // 保存有长度
 // struct objc_method_list (32-bit pointer)
 int32_t method_count;
 
 // 保存方法结构体
 // variable length structure
 struct objc_method_t method_list[1];
 };
 
 struct objc_method_t {

 //方法名
 // SEL, aka struct objc_selector * (32-bit pointer)
 uint32_t method_name;

 // 方法类型
 // char * (32-bit pointer)
 uint32_t method_types;
 
 // IMP, aka function pointer, (*IMP)(id, SEL, ...) (32-bit pointer)
 uint32_t method_imp;
 };
 
 */

//----------------------------------------------------------------------------//
#pragma mark - 考点 Cache的作用
//----------------------------------------------------------------------------//

/**
 * 官方文档：
 * https://developer.apple.com/documentation/objectivec/objective-c_runtime/objc_cache?language=objc
 *
 * 源代码：
 * https://opensource.apple.com/source/objc4/objc4-723/runtime/objc-runtime-new.h.auto.html
 *
 * 要点：
 * 1. 使用Mask完成了一个简单的Hash算法，加速寻址过程
 * 2. 使用Buckets 来完成
 *
 * 参考文档：
 * https://www.jianshu.com/p/5f59814cd8ba
 *
 *
 * 要点：
 * 1. 通过Selector字符串来算 index 公式 f(selector) = index
 * 2. 每次扩容的时候会清空缓存
 * 3. 调用父类的方法的时候会缓存到子类里，加快寻址
 *
 *
 *
 */


//----------------------------------------------------------------------------//
#pragma mark - 考点 isa_t指针
//----------------------------------------------------------------------------//

/**
 *
 * 官方文档：
 * 源码：
 * https://opensource.apple.com/source/objc4/objc4-723/runtime/objc-private.h.auto.html
 *
 * 参考：
 * https://juejin.im/post/5b238de251882574b409451e
 *
 * 要点：
 *
 * 1. 删除了冗余信息的 isa_t 其实就是一个union的结构体
 * 2. union 在于用 64bit来储存 arm64 和 x86不同的结构
 * 3. 有个关键的宏是 ISA_MASK 用来快速提取 shiftcls 位域
 *
 union isa_t
 {
 # if __arm64__
 
 struct {
 uintptr_t nonpointer        : 1;
 uintptr_t has_assoc         : 1;
 uintptr_t has_cxx_dtor      : 1;
 uintptr_t shiftcls          : 33; // MACH_VM_MAX_ADDRESS 0x1000000000
 uintptr_t magic             : 6;
 uintptr_t weakly_referenced : 1;
 uintptr_t deallocating      : 1;
 uintptr_t has_sidetable_rc  : 1;
 uintptr_t extra_rc          : 19;
 };
 
 # elif __x86_64__
 struct {
 uintptr_t nonpointer        : 1;
 uintptr_t has_assoc         : 1;
 uintptr_t has_cxx_dtor      : 1;
 uintptr_t shiftcls          : 44; // MACH_VM_MAX_ADDRESS 0x7fffffe00000
 uintptr_t magic             : 6;
 uintptr_t weakly_referenced : 1;
 uintptr_t deallocating      : 1;
 uintptr_t has_sidetable_rc  : 1;
 uintptr_t extra_rc          : 8;
 };
 *
 *
 * 结构分析：
 *
 struct {
 // 0代表普通的指针，存储着Class，Meta-Class对象的内存地址。
 // 1代表优化后的使用位域存储更多的信息。
 uintptr_t nonpointer        : 1;
 
 // 是否有设置过关联对象，如果没有，释放时会更快
 uintptr_t has_assoc         : 1;
 
 // 是否有C++析构函数，如果没有，释放时会更快
 uintptr_t has_cxx_dtor      : 1;
 
 // 存储着Class、Meta-Class对象的内存地址信息
 uintptr_t shiftcls          : 33;
 
 // 用于在调试时分辨对象是否未完成初始化
 uintptr_t magic             : 6;
 
 // 是否有被弱引用指向过。
 uintptr_t weakly_referenced : 1;
 
 // 对象是否正在释放
 uintptr_t deallocating      : 1;
 
 // 引用计数器是否过大无法存储在isa中
 // 如果为1，那么引用计数会存储在一个叫SideTable的类的属性中
 uintptr_t has_sidetable_rc  : 1;
 
 // 里面存储的值是引用计数器减1
 uintptr_t extra_rc          : 19;
 };
 *
 */

//----------------------------------------------------------------------------//
#pragma mark - 考点 has_assoc Runtime中的 Associate对象在哪
//----------------------------------------------------------------------------//

/**
 * 参考文章:
 * http://blog.leichunfeng.com/blog/2015/06/26/objective-c-associated-objects-implementation-principle/
 * https://nshipster.com/associated-objects/
 *
 * 要点:
 * 1. 关联对象被存储在什么地方，是不是存放在被关联对象本身的内存中？
 * 2. 关联对象的五种关联策略有什么区别，有什么坑？
 * 3. 关联对象的生命周期是怎样的，什么时候被释放，什么时候被移除？
 *
 * 回答:
 * 1. 关联对象与被关联对象本身的存储并没有直接的关系，它是存储在单独的哈希表中的
 * 2. 关联对象的五种关联策略与属性的限定符非常类似
 *    在绝大多数情况下，我们都会使用 OBJC_ASSOCIATION_RETAIN_NONATOMIC 的关联策略，这可以保证我们持有关联对象；
 * 3. 关联对象的释放时机与移除时机并不总是一致
 *    比如实验中用关联策略 OBJC_ASSOCIATION_ASSIGN 进行关联的对象
 *    很早就已经被释放了，但是并没有被移除，而再使用这个关联对象时就会造成 Crash 。
 *
 * 如何储存:
 * 1. 存在 AssociationsManager 顶级的对象，维护了一个从 spinlock_t 锁到 AssociationsHashMap 哈希表的单例键值对映射；
 * 2. AssociationsHashMap 是一个无序的哈希表，维护了从[对象地址]到 [ObjectAssociationMap] 的映射；
 * 3. ObjectAssociationMap 是一个 C++ 中的 map ，维护了从 [key] 到 [ObjcAssociation] 的映射，即关联记录；
 * 4. ObjcAssociation 是一个 C++ 的类，表示一个具体的关联结构，主要包括两个实例变量，_policy 表示关联策略，_value 表示关联对象。
 */



//----------------------------------------------------------------------------//
#pragma mark - 考点 SEL是什么
//----------------------------------------------------------------------------//

/**
 *
 * 头文件：
 * typedef struct objc_selector *SEL;
 *
 * 结构：
 * 这个结构是猜的，Apple没有开放源码出来
 *
 struct objc_selector
 {
 void *sel_id;
 const char *sel_types;
 };
 
 *
 * 参考文章：
 * https://stackoverflow.com/questions/28581489/what-is-the-objc-selector-implementation/28581632#28581632
 * https://blog.csdn.net/jeffasd/article/details/52084639
 */

@interface SGObject : NSObject

- (void)test;

@end
