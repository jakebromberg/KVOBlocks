//
//  NSObject+KVOBlocks.h
//
//  Created by Jake Bromberg on 10/11/13.
//

NS_ASSUME_NONNULL_BEGIN

typedef void (^JBKVOObservationBlock)(NSDictionary * change);

@interface NSObject (KVOBlocks)

- (nonnull void *)observeKeyPath:(NSString *)keypath changeBlock:(JBKVOObservationBlock)changeBlock;
- (void)removeObservation:(void *)token;

@end

NS_ASSUME_NONNULL_END