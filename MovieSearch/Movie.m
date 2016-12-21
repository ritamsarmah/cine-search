//
//  Movie.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "Movie.h"

@implementation Movie

- (instancetype)initWithTitle:(NSString *)title overview:(NSString *)overview releaseDate:(NSString *)releaseDate rating:(NSNumber *)rating genres:(NSArray *)genres posterURL:(NSString *)posterURL backdropURL:(NSString *)backdropURL{
    self = [super init];
    
    if (self) {
        _title = title;
        _overview = overview;
        _releaseDate = releaseDate;
        _rating = rating;
        _genres = genres;
        _posterURL = posterURL;
        _backdropURL = backdropURL;
    }
    
    return self;
}

@end
