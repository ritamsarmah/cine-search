//
//  MovieSingleton.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "MovieSingleton.h"

@implementation MovieSingleton

@synthesize database;

+ (instancetype)sharedManager {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        database = [[MovieSearch alloc] init];
    }
    return self;
}

@end
