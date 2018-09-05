//
//  MovieID.h
//  CineSearch
//
//  Created by Ritam Sarmah on 1/13/17.
//  Copyright © 2017 Ritam Sarmah. All rights reserved.
//

#import <Realm/Realm.h>

@interface MovieID : RLMObject

@property (nonatomic) NSInteger value;

- (instancetype)initWithInteger:(NSInteger)movieID;


@end
