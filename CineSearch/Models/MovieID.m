//
//  MovieID.m
//  CineSearch
//
//  Created by Ritam Sarmah on 1/13/17.
//  Copyright © 2017 Ritam Sarmah. All rights reserved.
//

#import "MovieID.h"

@implementation MovieID

- (instancetype)initWithInteger:(NSInteger)value {
    self = [super init];
    
    if (self) {
        _value = value;
    }
    
    return self;
}

+ (NSString *)primaryKey {
    return @"value";
}

@end
