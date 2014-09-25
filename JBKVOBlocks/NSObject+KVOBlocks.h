//
//  NSObject+KVOBlocks.h
//
//  Created by Jake Bromberg on 10/11/13.
//

#import "JBObservationToken.h"

typedef void (^JBKVOObservationBlock)(NSDictionary *change);

@interface NSObject (KVOBlocks)

- (JBObservationToken *)observeKeyPath:(NSString *)keypath changeBlock:(JBKVOObservationBlock)changeBlock;
- (void)removeObservation:(JBObservationToken *)token;

@end
