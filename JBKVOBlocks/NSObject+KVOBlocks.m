//
//  NSObject+KVOBlocks.m
//
//  Created by Jake Bromberg on 10/11/13.
//

#import "NSObject+KVOBlocks.h"

@interface JBKVOProxy : NSObject

- (instancetype)initWithObserver:(id)observer;

- (void)addObservationBlock:(JBKVOObservationBlock)block forKeyPath:(NSString *)keypath options:(NSKeyValueObservingOptions)options;
- (void)removeAllObservationBlocks;
- (void)removeObservationBlockForKeyPath:(NSString *)keypath;

@property (nonatomic, retain) NSMutableSet *keyPaths;
@property (nonatomic, assign) id observer;

@end


@implementation JBKVOProxy

- (instancetype)initWithObserver:(id)observer
{
    self = [super init];
    
    if (!self)
        return nil;
    
	self.keyPaths = [NSMutableSet set];
    self.observer = observer;
    
    return self;
}

- (void)addObservationBlock:(JBKVOObservationBlock)block forKeyPath:(NSString *)keypath options:(NSKeyValueObservingOptions)options
{
    if ([self.keyPaths containsObject:keypath])
    {
        [self removeObservationBlockForKeyPath:keypath];
    }
    
	[self.keyPaths addObject:keypath];
    [self.observer addObserver:self forKeyPath:keypath options:options context:(__bridge void *)(block)];
}

- (void)removeAllObservationBlocks
{
	for (NSString *keypath in self.keyPaths) {
		[self.observer removeObserver:self forKeyPath:keypath];
	}
	
	[self.keyPaths removeAllObjects];
}

- (void)removeObservationBlockForKeyPath:(NSString *)keypath
{
    [self.observer removeObserver:self forKeyPath:keypath];
	[self.keyPaths removeObject:keypath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	@try {
		JBKVOObservationBlock block = (__bridge JBKVOObservationBlock) context;
		block(change);
	}
	@catch (NSException *exception) {
		NSLog(@"%@", exception);
	}
}

- (void)dealloc
{
    [self removeAllObservationBlocks];
    self.keyPaths = nil;
}

@end


@implementation NSObject (KVOBlocks)

- (void)observeManyKeyPaths:(NSArray *)keyPaths changeBlock:(JBKVOObservationBlock)block
{
	for (NSString *keyPath in keyPaths) {
		[self observeKeyPath:keyPath changeBlock:block];
	}
}

- (void)observeKeyPath:(NSString *)keyPath changeBlock:(JBKVOObservationBlock)block
{
	[self addBlockObserver:self forKeyPath:keyPath changeBlock:block];
}

- (void)addBlockObserver:(id)observer forKeyPath:(NSString *)keyPath changeBlock:(JBKVOObservationBlock)block
{
	NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
	[self addBlockObserver:observer forKeyPath:keyPath options:options changeBlock:block];
}

- (void)addBlockObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options changeBlock:(JBKVOObservationBlock)block
{
    JBKVOProxy *proxy = [[self observerProxyMap] objectForKey:observer];
    
    if (!proxy)
    {
        proxy = [[JBKVOProxy alloc] initWithObserver:observer];
		[[self observerProxyMap] setObject:proxy forKey:observer];
    }
    
    [proxy addObservationBlock:block forKeyPath:keyPath options:options];
}

- (void)removeBlockObservers
{
    [self.observerProxyMap removeAllObjects];
}

- (void)removeBlockObserver:(NSObject *)observer
{
	id observerValue = [NSValue valueWithPointer:&observer];
    
	[[self observerProxyMap] removeObjectForKey:observerValue];
}

- (void)removeBlockObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    JBKVOProxy *proxy = [self.observerProxyMap objectForKey:observer];
    [proxy removeObservationBlockForKeyPath:keyPath];
}

- (NSMapTable *)observerProxyMap
{
	NSMapTable *observerProxyMap = [[self observerMap] objectForKey:self];
	
	if (!observerProxyMap) {
		observerProxyMap = [NSMapTable weakToStrongObjectsMapTable];
		[[self observerMap] setObject:observerProxyMap forKey:self];
	}
	
    return observerProxyMap;
}

- (NSMapTable *)observerMap
{
    static NSMapTable __strong *_observerMap;

    if (!_observerMap)
        _observerMap = [NSMapTable strongToStrongObjectsMapTable];
    
    return _observerMap;
}

@end
