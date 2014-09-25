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
    
    [self.testObj observeKeyPath:@keypath(self.testObj, propertyA) changeBlock:^(NSDictionary *change)
    {
        blockExecuted = YES;
    }];

    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyA)];
    
    XCTAssertTrue(blockExecuted, @"Failed to execute observation block after property changed.");
}

- (void)testOneKeyPathMultipleBlocks
{
    __block NSUInteger timesExecuted = 0;
    
    JBKVOObservationBlock changeBlock = ^(id change)
    {
        timesExecuted++;
    };
    
    [self.testObj observeKeyPath:@keypath(self.testObj, propertyA) changeBlock:changeBlock];
    [self.testObj observeKeyPath:@keypath(self.testObj, propertyA) changeBlock:changeBlock];
    
    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyA)];
    XCTAssertEqual(timesExecuted, 2);
}

- (void)testRemovingOneBlock
{
    JBObservationToken *tokenA = [self.testObj observeKeyPath:@keypath(self.testObj, propertyA) changeBlock:self.failingBlock];
    [self.testObj observeKeyPath:@keypath(self.testObj, propertyB) changeBlock:self.passingBlock];
    
    [self.testObj removeObservation:tokenA];
    
    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyA)];
    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyB)];
}

- (void)testObserveManyKeyPaths
{
    __block NSUInteger timesExecuted = 0;
    
    JBKVOObservationBlock changeBlock = ^(id change)
    {
        timesExecuted++;
    };
    
    [self.testObj observeKeyPath:@keypath(self.testObj, propertyA) changeBlock:changeBlock];
    [self.testObj observeKeyPath:@keypath(self.testObj, propertyB) changeBlock:changeBlock];
    
    self.testObj.propertyA = @0;
    self.testObj.propertyB = @0;
    
    XCTAssertEqual(timesExecuted, 2);
}

- (void)testRemoveObservationWithinObservationBlock
{
    __block NSNumber *expectedValue = @1;
    
    __block JBObservationToken *token = [self.testObj observeKeyPath:@keypath(self.testObj, propertyA) changeBlock:^(NSDictionary *change)
    {
        [self.testObj removeObservation:token];
        expectedValue = change[NSKeyValueChangeNewKey];
    }];
    
    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyA)];
    [self.testObj setValue:@1 forKeyPath:@keypath(self.testObj, propertyA)];
    
    XCTAssertEqualObjects(expectedValue, @0);
}

- (void)testMutationWorksCorrectly
{
    __block int timesExecuted = 0;
    
    [self.testObj observeKeyPath:@keypath(self.testObj, propertyA) changeBlock:^(NSDictionary *change)
     {
        if (timesExecuted++ == 0)
        {
            XCTAssertEqualObjects(change[NSKeyValueChangeOldKey], [NSNull null]);
            XCTAssertEqualObjects(change[NSKeyValueChangeNewKey], @0);
        }
        else
        {
            XCTAssertEqualObjects(change[NSKeyValueChangeOldKey], @0);
            XCTAssertEqualObjects(change[NSKeyValueChangeNewKey], @1);
        }
    }];
    
    [self.testObj setValue:@0 forKeyPath:@keypath(self.testObj, propertyA)];
}

#pragma mark - Properties

- (JBKVOObservationBlock)failingBlock
{
    return ^(NSDictionary *change)
    {
        XCTFail(@"Executed a failing block.");
    };
}

- (JBKVOObservationBlock)passingBlock
{
    return ^(NSDictionary *change)
    {
        NSLog(@"Executed a passing block.");
    };
}

@end
