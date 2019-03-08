//
// Created by Elliot Li on 2019-03-07.
// Copyright (c) 2019 Alanli7991. All rights reserved.
//

#import "SGObject.h"


@implementation SGObject

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@"resolveInstanceMethod:");
    if (sel == @selector(test)) {
        return NO;
    }
    return [super resolveInstanceMethod:sel];
}


- (IMP)methodForSelector:(SEL)aSelector {
    NSLog(@"methodForSelector:");
    return [super methodForSelector:aSelector];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"doesNotRecognizeSelector:");
    return;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"forwardingTargetForSelector:");
    if (aSelector == @selector(test)) {
        return nil;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"forwardInvocation:");
    [super forwardInvocation:anInvocation];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSLog(@"methodSignatureForSelector:");
    if (aSelector == @selector(test)) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}


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
@end
