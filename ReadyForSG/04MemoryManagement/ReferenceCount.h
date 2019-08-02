//
//  ReferenceCount.h
//  ReadyForSG
//
//  Created by 三杜 on 2019/3/21.
//  Copyright © 2019年 Alanli7991. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReferenceCount : NSObject

- (void)taggedPointer;

@end

NS_ASSUME_NONNULL_END

//----------------------------------------------------------------------------//
#pragma mark - Tagged Pointer
//----------------------------------------------------------------------------//
/**
 * 1. Tagged Pointer专门用来存储小的对象，例如NSNumber、NSDate、NSString
 * 2. Tagged Pointer指针的值不再是地址了，而是真正的值。它的内存并不存在堆中，也不需要malloc和free
 * 3. Tagged Pointer内存上读取速度更快（3倍），创建更快（106倍）
 * 4. 引入Tagged Pointer的原因：iPhone5s之后，采用64位处理器，导致一些对象占用的内存会翻倍
 *              --------
 *              | tag  |
 *              --------
 *              | data |
 *              --------
 *
 * 文章：
 * 1. https://juejin.im/post/58fe0c6561ff4b006671e789
 * 2. https://www.jianshu.com/p/17817e6efaf5
 *
 * 考点：
 * 1. 实例对象的isa指针都指向class对象？错误的
 * 2. 两个NSNumber对象，存储double值，两个对象在内存上占用空间大小肯定一致。（错误的）
 * 3. 手动关闭Tagged Pointer：设置环境变量OBJC_DISABLE_TAGGED_POINTERS为YES
 */


//----------------------------------------------------------------------------//
#pragma mark - Non-Pointer isa
//----------------------------------------------------------------------------//
/**
 * 1. 现在的isa指针，不再单纯是一个指针了，而是一个联合体，里面存储了很多标志，如引用计数
 * 2. 如果对象启用了Non-pointer，那么将会对isa的其他变量赋值
 * 3. 不启动Non-pointer的条件：
 *    a. 包括swift代码
 *    b. sdk版本低于10.11
 *    c. runtime读取image时发现该image包含__objc_rawisa段
 *    d. 设置了OBJC_DISABLE_NONPOINTER_ISA=YES
 *    e. 某些不能使用Non-pointer的类，如GCD
 *    f. 父类关闭
 *
 * 4. 结构体
 union isa_t
 {
 isa_t() { }
 isa_t(uintptr_t value) : bits(value) { }
 
 Class cls;
 uintptr_t bits;
 
 #if SUPPORT_NONPOINTER_ISA
 
 // extra_rc must be the MSB-most field (so it matches carry/overflow flags)
 // indexed must be the LSB (fixme or get rid of it)
 // shiftcls must occupy the same bits that a real class pointer would
 // bits + RC_ONE is equivalent to extra_rc + 1
 // RC_HALF is the high bit of extra_rc (i.e. half of its range)
 
 // future expansion:
 // uintptr_t fast_rr : 1;     // no r/r overrides
 // uintptr_t lock : 2;        // lock for atomic property, @synch
 // uintptr_t extraBytes : 1;  // allocated with extra bytes
 
 # if __arm64__
 #   define ISA_MASK        0x00000001fffffff8ULL
 #   define ISA_MAGIC_MASK  0x000003fe00000001ULL
 #   define ISA_MAGIC_VALUE 0x000001a400000001ULL
 struct {
 uintptr_t indexed           : 1;
 uintptr_t has_assoc         : 1;
 uintptr_t has_cxx_dtor      : 1;
 uintptr_t shiftcls          : 30; // MACH_VM_MAX_ADDRESS 0x1a0000000
 uintptr_t magic             : 9;
 uintptr_t weakly_referenced : 1;
 uintptr_t deallocating      : 1;
 uintptr_t has_sidetable_rc  : 1;
 uintptr_t extra_rc          : 19;
 #       define RC_ONE   (1ULL<<45)
 #       define RC_HALF  (1ULL<<18)
 };
 
 # elif __x86_64__
 #   define ISA_MASK        0x00007ffffffffff8ULL
 #   define ISA_MAGIC_MASK  0x0000000000000001ULL
 #   define ISA_MAGIC_VALUE 0x0000000000000001ULL
 struct {
 uintptr_t indexed           : 1;
 uintptr_t has_assoc         : 1;
 uintptr_t has_cxx_dtor      : 1;
 uintptr_t shiftcls          : 44; // MACH_VM_MAX_ADDRESS 0x7fffffe00000
 uintptr_t weakly_referenced : 1;
 uintptr_t deallocating      : 1;
 uintptr_t has_sidetable_rc  : 1;
 uintptr_t extra_rc          : 14;
 #       define RC_ONE   (1ULL<<50)
 #       define RC_HALF  (1ULL<<13)
 };
 
 # else
 // Available bits in isa field are architecture-specific.
 #   error unknown architecture
 # endif
 
 // SUPPORT_NONPOINTER_ISA
 #endif
 
 };
 */


//----------------------------------------------------------------------------//
#pragma mark - Side Table 是什么
//----------------------------------------------------------------------------//
/**
 * 1. SideTable 结构体
 namespace {
 
 #if TARGET_OS_EMBEDDED
 #   define SIDE_TABLE_STRIPE 8
 #else
 #   define SIDE_TABLE_STRIPE 64
 #endif
 
 // should be a multiple of cache line size (64)
 #define SIDE_TABLE_SIZE 128
 
 // The order of these bits is important.
 #define SIDE_TABLE_WEAKLY_REFERENCED (1UL<<0)
 #define SIDE_TABLE_DEALLOCATING      (1UL<<1)  // MSB-ward of weak bit
 #define SIDE_TABLE_RC_ONE            (1UL<<2)  // MSB-ward of deallocating bit
 #define SIDE_TABLE_RC_PINNED         (1UL<<(WORD_BITS-1))
 
 #define SIDE_TABLE_RC_SHIFT 2
 #define SIDE_TABLE_FLAG_MASK (SIDE_TABLE_RC_ONE-1)
 
 // RefcountMap disguises its pointers because we
 // don't want the table to act as a root for `leaks`.
 typedef objc::DenseMap<DisguisedPtr<objc_object>,size_t,true> RefcountMap;
 
 class SideTable {
 private:
 static uint8_t table_buf[SIDE_TABLE_STRIPE * SIDE_TABLE_SIZE];
 
 public:
 spinlock_t slock;
 RefcountMap refcnts;
 weak_table_t weak_table;
 
 SideTable() : slock(SPINLOCK_INITIALIZER)
 {
 memset(&weak_table, 0, sizeof(weak_table));
 }
 
 ~SideTable()
 {
 // never delete side_table in case other threads retain during exit
 assert(0);
 }
 
 static SideTable *tableForPointer(const void *p)
 {
 #     if SIDE_TABLE_STRIPE == 1
 return (SideTable *)table_buf;
 #     else
 uintptr_t a = (uintptr_t)p;
 int index = ((a >> 4) ^ (a >> 9)) & (SIDE_TABLE_STRIPE - 1);
 return (SideTable *)&table_buf[index * SIDE_TABLE_SIZE];
 #     endif
 }
 
 static void init() {
 // use placement new instead of static ctor to avoid dtor at exit
 for (int i = 0; i < SIDE_TABLE_STRIPE; i++) {
 new (&table_buf[i * SIDE_TABLE_SIZE]) SideTable;
 }
 }
 };
 
 STATIC_ASSERT(sizeof(SideTable) <= SIDE_TABLE_SIZE);
 __attribute__((aligned(SIDE_TABLE_SIZE))) uint8_t
 SideTable::table_buf[SIDE_TABLE_STRIPE * SIDE_TABLE_SIZE];
 
 // anonymous namespace
 };

 * 2. 概念：苹果使用SideTable来记录一个对象的weak引用和引用次数，所以它包含一个weak表和引用计数表
 * 3. 使用SideTable中的引用计数表的条件：
 *    a. 不是Tagger Pointer
 *    b. 启用了Non-pointer后，对象的引用次数超过255
 *    c. 没有启动Non-pointer
 * 4. 获取retainCount：
 *    a. 记录在表中的引用次数，是实际的引用次数减1
 *    b. 记录引用次数的内存，最后一个bit（SIDE_TABLE_WEAKLY_REFERENCED）用于表示该对象是否有
 *       过weak对象，如果没有，在析构时可以更快
 *    c. 记录引用次数的内存，倒数第二个bit（SIDE_TABLE_DEALLOCATING）表示是否正在析构
 *    d. 因此获取引用计数时，内存右移两位
 *    e. 获取方法实现
 uintptr_t
 objc_object::sidetable_retainCount()
 {
 SideTable *table = SideTable::tableForPointer(this);
 
 size_t refcnt_result = 1;
 
 spinlock_lock(&table->slock);
 RefcountMap::iterator it = table->refcnts.find(this);
 if (it != table->refcnts.end()) {
 // this is valid for SIDE_TABLE_RC_PINNED too
 refcnt_result += it->second >> SIDE_TABLE_RC_SHIFT;//SIDE_TABLE_RC_SHIFT = 2
 }
 spinlock_unlock(&table->slock);
 return refcnt_result;
 }
 
 
 * 5. release：
 *   a. 记录引用计数次数时，先查看当前引用计数是否为0（0实际上代表了引用计数次数为1）。若为0，
 *      将对象标记为正在析构，并发送dealloc消息
 *   b. 实现
 bool
 objc_object::sidetable_release(bool performDealloc)
 {
 #if SUPPORT_NONPOINTER_ISA
 assert(!isa.indexed);
 #endif
 SideTable *table = SideTable::tableForPointer(this);
 
 bool do_dealloc = false;
 
 if (spinlock_trylock(&table->slock)) {
 RefcountMap::iterator it = table->refcnts.find(this);
 if (it == table->refcnts.end()) {
 do_dealloc = true;
 table->refcnts[this] = SIDE_TABLE_DEALLOCATING;
 } else if (it->second < SIDE_TABLE_DEALLOCATING) {
 // SIDE_TABLE_WEAKLY_REFERENCED may be set. Don't change it.
 do_dealloc = true;
 it->second |= SIDE_TABLE_DEALLOCATING;
 } else if (! (it->second & SIDE_TABLE_RC_PINNED)) {
 it->second -= SIDE_TABLE_RC_ONE;
 }
 spinlock_unlock(&table->slock);
 if (do_dealloc  &&  performDealloc) {
 ((void(*)(objc_object *, SEL))objc_msgSend)(this, SEL_dealloc);
 }
 return do_dealloc;
 }
 
 return sidetable_release_slow(table, performDealloc);
 }
 */

//----------------------------------------------------------------------------//
#pragma mark - calloc() and malloc()
//----------------------------------------------------------------------------//
/**
 * 1. calloc()相当于malloc()之后memset为0
 * 2. OC对象创建使用的是calloc()
 *
 */

//----------------------------------------------------------------------------//
#pragma mark - OC对象内存销毁
//----------------------------------------------------------------------------//
/**
 * https://blog.csdn.net/bravegogo/article/details/50965864?utm_source=blogxgwz1
 * 1. 调用-release：引用计数为零
 *    a. 对象正在被销毁
 *    b. 不能有新的weak引用，否则weak引用指向nil
 *    c. 调用【self dealloc】
 * 2. 父类从底到顶依次调用dealloc
 * 3. NSObject调用dealloc：实际就是调用objc_dispose()方法
 * 4. objc_dispose()
 *    a. c++的实例变量iVars调用destructors
 *    b. 为ARC状态下的OC实例变量iVars调用release
 *    c. 解除所有使用 runtime Associate方法关联的对象
 *    d. 解除所有 __weak 引用
 *    e. 调用free()
 */
