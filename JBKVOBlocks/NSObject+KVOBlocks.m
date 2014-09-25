//
//  NSObject+KVOBlocks.m
//
//  Created by Jake Bromberg on 10/11/13.
//

#import "NSObject+KVOBlocks.h"

@interface JBKVOProxy : NSObject

- (instancetype)initWithObservee:(id)observee keyPath:(NSString *)keyPath changeBlock:(JBKVOObservationBlock)block;

@property (nonatomic, weak) id observee;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) JBKVOObservationBlock block;

@end


@implementation JBKVOProxy

static const void *kvoCtx = &kvoCtx;

- (instancetype)initWithObservee:(id)observee keyPath:(NSString *)keyPath changeBlock:(JBKVOObservationBlock)block
{
    if (!(self = [super init])) return nil;
    
    _observee = observee;
    _keyPath = [keyPath copy];
    _block = [block copy];
    [_observee addObserver:self forKeyPath:_keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:&kvoCtx];
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != kvoCtx)
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

- (JBObservationToken *)observeKeyPath:(NSString *)keyPath changeBlock:(JBKVOObservationBlock)changeBlock
{
    JBObservationToken *token = [[JBObservationToken alloc] init];
    JBKVOProxy *proxy = [[JBKVOProxy alloc] initWithObservee:self keyPath:keyPath changeBlock:changeBlock];
    
    NSMapTable *tokenProxyMap = [self tokenProxyMap];
    [tokenProxyMap setObject:proxy forKey:token];
    
    return token;
}

- (void)removeObservation:(JBObservationToken *)token
{
    NSMapTable *tokenProxyMap = [self tokenProxyMap];
    [tokenProxyMap removeObjectForKey:token];
}

- (NSMapTable *)tokenProxyMap
{
    static NSMapTable *globalMap;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalMap = [NSMapTable weakToStrongObjectsMapTable];
    });
    
    NSMapTable *tokenProxyMap = [globalMap objectForKey:self];
    
    if (!tokenProxyMap)
    {
        tokenProxyMap = [NSMapTable strongToStrongObjectsMapTable];
        [globalMap setObject:tokenProxyMap forKey:self];
    }
    
    return tokenProxyMap;
}

@end
