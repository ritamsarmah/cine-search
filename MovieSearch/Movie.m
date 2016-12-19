//
//  Movie.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "Movie.h"

@implementation Movie

- (instancetype)initWithTitle:(NSString *)title overview:(NSString *)overview releaseDate:(NSString *)releaseDate rating:(NSNumber *)rating posterURL:(NSString *)posterURL {
    self = [super init];
    
    if (self) {
        _title = title;
        _overview = overview;
        _releaseDate = releaseDate;
        _rating = rating;
        _posterURL = posterURL;
    }
    
    return self;
}

@end
