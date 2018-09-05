//
//  Movie.m
//  CineSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "Movie.h"

@implementation Movie

- (instancetype)initWithTitle:(NSString *)title overview:(NSString *)overview releaseDate:(NSString *)releaseDate runtime:(NSString *)runtime certification:(NSString*)certification rating:(NSNumber *)rating genres:(NSArray *)genres posterURL:(NSString *)posterURL backdropURL:(NSString *)backdropURL idNumber:(NSNumber *)idNumber{
    self = [super init];
    
    if (self) {
        _title = title;
        _overview = overview;
        _releaseDate = releaseDate;
        _runtime = runtime;
        _certification = certification;
        _rating = rating;
        _genres = genres;
        _posterURL = posterURL;
        _backdropURL = backdropURL;
        _idNumber = idNumber;
    }
    
    return self;
}

- (MovieID *)getMovieID {
    return [[MovieID alloc] initWithID:self.idNumber.integerValue];
}

@end
