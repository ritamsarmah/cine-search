//
//  MovieID.m
//  CineSearch
//
//  Created by Ritam Sarmah on 1/13/17.
//  Copyright © 2017 Ritam Sarmah. All rights reserved.
//

#import "MovieID.h"

@implementation MovieID

- (instancetype)initWithID:(NSInteger)movieID {
    self = [super init];
    
    if (self) {
        _movieID = movieID;
    }
    
    return self;
}

+ (NSString *)primaryKey {
    return @"movieID";
}

@end
