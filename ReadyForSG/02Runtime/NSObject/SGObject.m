//
// Created by Elliot Li on 2019-03-07.
// Copyright (c) 2019 Alanli7991. All rights reserved.
//

#import "SGObject.h"


@implementation SGObject {

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

struct objc_method_list_t {
    uint32_t obsolete;		/* struct objc_method_list * (32-bit pointer) */
    int32_t method_count;
    struct objc_method_t method_list[1];      /* variable length structure */
};


@end