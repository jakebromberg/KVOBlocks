//
//  NSObject+KVOBlocks.h
//
//  Created by Jake Bromberg on 10/11/13.
//

#import <Foundation/Foundation.h>

@interface NSObject (KVOBlocks)

typedef void (^JBKVOObservationBlock)(NSDictionary *change);

- (void)observeKeyPath:(NSString *)keyPath changeBlock:(JBKVOObservationBlock)block;
- (void)observeManyKeyPaths:(NSArray *)keyPaths changeBlock:(JBKVOObservationBlock)block;
- (void)addBlockObserver:(id)observer forKeyPath:(NSString *)keyPath changeBlock:(JBKVOObservationBlock)block;
- (void)addBlockObserver:(id)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options changeBlock:(JBKVOObservationBlock)block;

- (void)removeBlockObservers;
- (void)removeBlockObserver:(id)observer forKeyPath:(NSString *)keyPath;
- (void)removeBlockObserver:(id)observer;

@end
