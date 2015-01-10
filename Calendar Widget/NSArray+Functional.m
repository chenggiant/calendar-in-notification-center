//
//  NSArray+Functional.m
//  Yummy
//
//  Created by Stephen Darlington on 12/12/2014.
//  Copyright (c) 2014 Wandle Software Limited. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (NSArray*)wsl_map:(id(^)(id))mapfn {
    NSMutableArray* returnArray = [[NSMutableArray alloc] initWithArray:self];
    
    [returnArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        returnArray[idx] = mapfn(obj);
    }];
    
    return returnArray;
}

@end
