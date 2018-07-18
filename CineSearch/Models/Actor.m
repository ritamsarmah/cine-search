//
//  Actor.m
//  CineSearch
//
//  Created by Ritam Sarmah on 12/31/17.
//  Copyright © 2017 Ritam Sarmah. All rights reserved.
//

#import "Actor.h"

@implementation Actor

- (instancetype)initWithName:(NSString *)name role:(NSString *)role profileURL:(NSString *)profileURL {
    self = [super init];
    
    if (self) {
        _name = name;
        _role = role;
        _profileURL = profileURL;
    }
    
    return self;
}

@end
