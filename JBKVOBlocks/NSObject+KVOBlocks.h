//
//  NSObject+KVOBlocks.h
//
//  Created by Jake Bromberg on 10/11/13.
//

typedef void (^JBKVOObservationBlock)(NSDictionary * _Nonnull change);

@interface NSObject (KVOBlocks)

- (nonnull void *)observeKeyPath:(nonnull NSString *)keypath changeBlock:(nonnull JBKVOObservationBlock)changeBlock;
- (void)removeObservation:(nonnull void *)token;

@end
