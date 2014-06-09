//
//  JBKVOBlocksTests.m
//  JBKVOBlocksTests
//
//  Created by Jake Bromberg on 1/3/14.
//

#import <XCTest/XCTest.h>
#import "NSObject+KVOBlocks.h"
#import "JBKVOTestObject.h"

@interface JBKVOBlocksTests : XCTestCase

@property (nonatomic, strong) JBKVOTestObject *testObj;

@property (nonatomic, readonly) JBKVOObservationBlock failingBlock;
@property (nonatomic, readonly) JBKVOObservationBlock passingBlock;

@end


@implementation JBKVOBlocksTests

- (void)setUp
{
    [super setUp];

    self.testObj = [[JBKVOTestObject alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    
    self.testObj = nil;
}

- (void)testObservationBlockExecutes
{
    __block BOOL blockExecuted = NO;
    
    [self.testObj observeSelfWithKeyPath:@keypath(self.testObj, propertyA) changeBlock:^(NSDictionary *change) {
        blockExecuted = YES;
    }];

    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyA)];
    
    XCTAssertTrue(blockExecuted, @"Failed to execute observation block after property changed.");
}

- (void)testExpectedValues
{
    __block id const expectedValueA = @0;
    __block id const expectedValueB = @1;
    
    id changeBlockA = ^(NSDictionary *change) {
        XCTAssertEqualObjects(change[NSKeyValueChangeNewKey], expectedValueA);
    };

    id changeBlockB = ^(NSDictionary *change) {
        XCTAssertEqualObjects(change[NSKeyValueChangeOldKey], expectedValueA);
        XCTAssertEqualObjects(change[NSKeyValueChangeNewKey], expectedValueB);
    };
    
    [self.testObj observeSelfWithKeyPath:@keypath(self.testObj, propertyA) changeBlock:changeBlockA];
    
    [self.testObj setValue:expectedValueA forKeyPath:@keypath(self.testObj, propertyA)];
    
    [self.testObj observeSelfWithKeyPath:@keypath(self.testObj, propertyA) changeBlock:changeBlockB];
    
    [self.testObj setValue:expectedValueB forKeyPath:@keypath(self.testObj, propertyA)];
}

- (void)testProvidingTwoBlocksForSameObserverAndKeyPathClobbersFirstAddedBlock
{
    [self.testObj observeSelfWithKeyPath:@keypath(self.testObj, propertyA) changeBlock:self.failingBlock];
    [self.testObj observeSelfWithKeyPath:@keypath(self.testObj, propertyA) changeBlock:self.passingBlock];
    
    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyA)];
}

- (void)testRemovingAllBlocks
{
    [self.testObj observeSelfWithKeyPath:@keypath(self.testObj, propertyA) changeBlock:self.failingBlock];
    [self.testObj observeSelfWithKeyPath:@keypath(self.testObj, propertyB) changeBlock:self.failingBlock];
    
    [self.testObj removeBlockObservers];

    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyA)];
    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyB)];
}

- (void)testRemovingOneBlock
{
    [self.testObj observeSelfWithKeyPath:@keypath(self.testObj, propertyA) changeBlock:self.failingBlock];
    [self.testObj observeSelfWithKeyPath:@keypath(self.testObj, propertyB) changeBlock:self.passingBlock];
    
    [self.testObj removeBlockObserver:self.testObj forKeyPath:@keypath(self.testObj, propertyA)];
    
    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyA)];
    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyB)];
}

- (void)testObserveManyKeyPaths
{
    NSArray *const keypaths = @[@keypath(self.testObj, propertyA), @keypath(self.testObj, propertyB)];
    __block int timesExecuted = 0;
    
    [self.testObj observeSelfWithManyKeyPaths:keypaths changeBlock:^(NSDictionary *change) {
        timesExecuted++;
    }];
    
    for (NSString *keypath in keypaths) {
        [self.testObj setValue:@0 forKeyPath:keypath];
    }
    
    XCTAssert(timesExecuted == [keypaths count], @"Block should have executed %lu times, but only did %i times.", (unsigned long)[keypaths count], timesExecuted);
}

- (void)testRemoveObservationWithinObservationBlock
{
    [self.testObj observeSelfWithKeyPath:@keypath(self.testObj, propertyA) changeBlock:^(NSDictionary *change) {
        [self.testObj removeBlockObservers];
    }];
    
    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyA)];
}

- (void)testMutationWorksCorrectly
{
    __block int timesExecuted = 0;
    
    [self.testObj observeSelfWithKeyPath:@keypath(self.testObj, propertyA) changeBlock:^(NSDictionary *change) {
        if (timesExecuted++ == 0)
        {
            XCTAssertEqualObjects(change[NSKeyValueChangeOldKey], [NSNull null]);
            XCTAssertEqualObjects(change[NSKeyValueChangeNewKey], @0);
        } else {
            XCTAssertEqualObjects(change[NSKeyValueChangeOldKey], @0);
            XCTAssertEqualObjects(change[NSKeyValueChangeNewKey], @1);
        }
    }];
    
    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyA)];
}

#pragma mark - Properties

- (JBKVOObservationBlock)failingBlock
{
    return ^(NSDictionary *change) {
        XCTFail(@"Executed a failing block.");
    };
}

- (JBKVOObservationBlock)passingBlock
{
    return ^(NSDictionary *change) {
        NSLog(@"Executed a passing block.");
    };
}

@end
