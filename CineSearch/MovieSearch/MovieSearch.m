//
//  MovieSearch.m
//  CineSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "MovieSearch.h"
#import "Constants.h"

@implementation MovieSearch

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _genres = @{ @28 : @"Action",
                     @12 : @"Adventure",
                     @16 : @"Animation",
                     @35 : @"Comedy",
                     @80 : @"Crime",
                     @99 : @"Documentary",
                     @18 : @"Drama",
                     @10751 : @"Family",
                     @14 : @"Fantasy",
                     @36 : @"History",
                     @27 : @"Horror",
                     @10402 : @"Music",
                     @9648 : @"Mystery",
                     @10749 : @"Romance",
                     @878 : @"Sci-Fi",
                     @10770 : @"TV Movie",
                     @53 : @"Thriller",
                     @10752 : @"War",
                     @37 : @"Western"
                     };
        
    }
    
    return self;
}

# pragma mark - JSON Handling

/// Converts JSON data into list of movies
- (NSMutableArray *)moviesFromData:(NSData *)data {
    if (data) {
        // Create JSON object from data
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) { NSLog(@"%@", jsonError.description); }
        
        // Create array of movies
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *movies = [NSMutableArray array];
            NSDictionary *results = [json objectForKey:@"results"];
            for (id movie in results) {
                [movies addObject:[self movieForJSON:movie isOnlyMovie:NO]];
            }
            return movies;
        } else {
            NSLog(@"Not a valid dictionary");
        }
    } else {
        NSLog(@"Data is empty");
    }
    return nil;
}


/// Creates Movie object from dictionary
- (Movie *)movieForJSON:(NSDictionary *)movieData isOnlyMovie:(BOOL)isOnlyMovie {
    NSString *title = [movieData objectForKey:@"title"];
    NSString *overview = [movieData objectForKey:@"overview"];
    NSString *releaseDate = [self formatDate:[movieData objectForKey:@"release_date"]];
    NSNumber *rating = [NSNumber numberWithDouble:[[movieData objectForKey:@"vote_average"] doubleValue]];
    NSString *poster = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movieData objectForKey:@"poster_path"]];
    NSString *backdrop = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movieData objectForKey:@"backdrop_path"]];
    NSNumber *idNumber = [NSNumber numberWithInt: (int)[[movieData objectForKey:@"id"] integerValue]];
    NSMutableArray *movieGenres = [[NSMutableArray alloc] init];
    
    NSString *runtime = @"N/A";
    if ([movieData objectForKey:@"runtime"] != [NSNull null]) {
        NSNumber *runtimeMinutes = [NSNumber numberWithInteger:[[movieData objectForKey:@"runtime"] integerValue]];
        runtime = [self formatRuntime:runtimeMinutes.intValue];
    }
    
    // Get genres
    if (isOnlyMovie) {
        NSArray *genreResults = [NSArray arrayWithArray:[movieData objectForKey:@"genres"]];
        for (id genre in genreResults) {
            if (self.genres[[genre objectForKey:@"id"]] != nil) {
                [movieGenres addObject:self.genres[[genre objectForKey:@"id"]]];
            }
        }
    } else {
        NSArray *genreNumbers = [NSArray arrayWithArray:[movieData objectForKey:@"genre_ids"]];
        for (NSNumber *genreID in genreNumbers) {
            if (self.genres[genreID] != nil) {
                [movieGenres addObject:self.genres[genreID]];
            }
        }
    }
    
    // Get certification
    NSDictionary *releaseDateResults = [[movieData objectForKey:@"release_dates"] objectForKey:@"results"];
    NSString *certification = @"";
    for (NSDictionary* result in releaseDateResults) {
        NSString *location = [result objectForKey:@"iso_3166_1"];
        if ([location isEqualToString:@"US"]) {
            NSDictionary *releaseDates = [result objectForKey:@"release_dates"];
            for (NSDictionary* release in releaseDates) {
                NSString *releaseCert = [release objectForKey:@"certification"];
                if ([certification isEqualToString:@""] && ![releaseCert isEqualToString:@""]) {
                    certification = releaseCert;
                }
            }
            break;
        }
    }
    if ([certification isEqualToString:@""]) {
        certification = @"NR";
    }
    
    Movie *newMovie = [[Movie alloc] initWithTitle:title
                                          overview:overview
                                       releaseDate:releaseDate
                                           runtime:runtime
                                     certification:certification
                                            rating:rating
                                            genres:movieGenres
                                         posterURL:poster
                                       backdropURL:backdrop
                                          idNumber:idNumber];
    return newMovie;
}


# pragma mark - tMDB API Requests

# pragma mark Movie Lists

/* Returns mutable array of movies */
- (void)getMoviesForQuery:(NSString *)query completion:(void (^)(NSMutableArray*))completion{
    
    // Reformat search query for request
    NSCharacterSet *illegal = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_ñé "] invertedSet];
    NSString* newQuery = [[[query componentsSeparatedByCharactersInSet:illegal] componentsJoinedByString:@""] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *stringURL = [NSString stringWithFormat:@"https://api.themoviedb.org/3/search/movie?query=%@&api_key=%@", newQuery, key];

    [[NSURLSession.sharedSession dataTaskWithRequest:[self getRequestWithStringURL:stringURL]
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        @try {
            completion([self moviesFromData:data]);
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
            completion(nil);
        }
    }] resume];
}

/* Returns array of movie IDs in theaters for US */
- (void)getNowPlaying:(void (^)(NSMutableArray *))completion {
    NSString *stringURL = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/now_playing?api_key=%@&region=US", key];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:[self getRequestWithStringURL:stringURL]
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        @try {
            completion([self moviesFromData:data]);
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
            completion(nil);
        }
    }] resume];
}

/* Returns array of movie IDs in theaters for US */
- (void)getPopular:(void (^)(NSMutableArray *))completion {
    NSString *stringURL = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/popular?api_key=%@&region=US", key];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:[self getRequestWithStringURL:stringURL]
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        @try {
            completion([self moviesFromData:data]);
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
            completion(nil);
        }
    }] resume];
}

# pragma mark Data Requests for MovieID

/* Returns movie data for ID */
- (void)getMovieForID:(MovieID *)movieID completion:(void (^)(Movie *))completion {
    NSInteger idNumber = movieID.value;
    NSString *stringURL = [NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%lu?api_key=%@&append_to_response=release_dates", idNumber, key];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:[self getRequestWithStringURL:stringURL]
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSError *jsonError = nil;
            id movie = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) { NSLog(@"Error retrieving movie"); }
        
            if ([movie isKindOfClass:[NSDictionary class]]) {
                completion([self movieForJSON:movie isOnlyMovie:YES]);
            }
        
            else {
                NSLog(@"Not valid dictionary");
            }
        } else {
            completion(nil);
        }
    }] resume];
}

/* Returns trailer video for ID */
- (void)getTrailerForID:(MovieID *)movieID completion:(void (^)(NSString *))completion {
    NSInteger idNumber = movieID.value;
    NSString *stringURL = [NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%lu/videos?api_key=%@", idNumber, key];

    [[NSURLSession.sharedSession dataTaskWithRequest:[self getRequestWithStringURL:stringURL]
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError = nil;
        id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) { NSLog(@"Error retrieving trailer data"); }
        
        if ([results isKindOfClass:[NSDictionary class]]) {
            NSDictionary *videoResults = [results objectForKey:@"results"];
            for (id video in videoResults) {
                if ([[video objectForKey:@"type"] isEqualToString:@"Trailer"]) {
                    completion([video objectForKey:@"key"]);
                    return;
                }
            }
            completion(nil);
        }
        else {
            NSLog(@"Not valid dictionary");
        }
    }] resume];
}

- (void)getCastForID:(MovieID *)movieID completion:(void (^)(NSArray *))completion {
    NSInteger idNumber = movieID.value;
    NSString *stringURL = [NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%lu/credits?api_key=%@", idNumber, key];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:[self getRequestWithStringURL:stringURL]
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSError *jsonError = nil;
            id credits = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) { NSLog(@"Error retrieving credits"); }
            
            if ([credits isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *castArray = [[NSMutableArray alloc] init];
                for (id member in [credits objectForKey:@"cast"]) {
                    NSString *name = [member objectForKey:@"name"];
                    NSString *role = [member objectForKey:@"character"];
                    NSString *profile = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [member objectForKey:@"profile_path"]];
                    Actor *actor = [[Actor alloc] initWithName:name role:role profileURL:profile];
                    [castArray addObject:actor];
                }
                completion([castArray copy]);
            }
            else {
                NSLog(@"Not valid dictionary");
            }
        }
    }] resume];
}

/* Returns array of movie IDs similar to input movie ID */
-(void)getRecommendedForID:(MovieID *)movieID completion:(void (^)(NSMutableArray *))completion {
    NSInteger idNumber = movieID.value;
    NSString *stringURL = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%ld/similar?api_key=%@", idNumber, key];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:[self getRequestWithStringURL:stringURL]
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
       @try {
           completion([self moviesFromData:data]);
       } @catch (NSException *exception) {
           NSLog(@"%@", exception.description);
           completion(nil);
       }
    }] resume];
}

# pragma mark - Helper Functions

- (NSMutableURLRequest *)getRequestWithStringURL:(NSString *)stringURL {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:stringURL]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}


- (NSString *)formatRuntime:(int)minutes {
    if (minutes == 0) {
        return @"N/A";
    }
    int hours = minutes / 60;
    int remainder = minutes % 60;
    return [NSString stringWithFormat:@"%dh %dm", hours, remainder];
}

- (NSString *)formatDate:(NSString *)stringDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:stringDate];
    
    [dateFormat setDateFormat: @"MMMM d, YYYY"];
    stringDate = [dateFormat stringFromDate:date];
    return stringDate;
}

@end
