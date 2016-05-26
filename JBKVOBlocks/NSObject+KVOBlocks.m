//
//  NSObject+KVOBlocks.m
//
//  Created by Jake Bromberg on 10/11/13.
//

#import "NSObject+KVOBlocks.h"
#import <objc/runtime.h>

@interface JBKVOProxy : NSObject

- (instancetype)initWithObservee:(id)observee keyPath:(NSString *)keyPath changeBlock:(JBKVOObservationBlock)block;

@property (nonatomic, assign) id observee;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) JBKVOObservationBlock block;

@end


@implementation JBKVOProxy

- (instancetype)initWithObservee:(id)observee keyPath:(NSString *)keyPath changeBlock:(JBKVOObservationBlock)block
{
    if (!(self = [super init])) return nil;
    
    _observee = observee;
    _keyPath = [keyPath copy];
    _block = block;
    [observee addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:(void *)self];
    objc_setAssociatedObject(_observee, (__bridge void *)(self), self, OBJC_ASSOCIATION_RETAIN);
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != ((__bridge void *)self))
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    else if ([keyPath isEqualToString:self.keyPath])
    {
        self.block(change);
    }
}

- (void)dealloc
{
    [_observee removeObserver:self forKeyPath:_keyPath];
}

@end


@implementation NSObject (KVOBlocks)

- (void *)observeKeyPath:(NSString *)keyPath changeBlock:(JBKVOObservationBlock)changeBlock
{
    return (__bridge void *) [[JBKVOProxy alloc] initWithObservee:self keyPath:keyPath changeBlock:changeBlock];
}

- (void)removeObservation:(void *)token
{
    objc_setAssociatedObject(self, token, nil, OBJC_ASSOCIATION_ASSIGN);
}

@end
