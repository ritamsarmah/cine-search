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

/* Returns mutable array of movies */
- (void)search:(NSString *)query completion:(void (^)(NSMutableArray*))completion{
    
    // Reformat search query for request
    NSCharacterSet *illegal = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_ñé "] invertedSet];
    NSString* newQuery = [[query componentsSeparatedByCharactersInSet:illegal]
                          componentsJoinedByString:@""];
    newQuery = [newQuery stringByReplacingOccurrencesOfString:@" "
                                                   withString:@"+"];
    
    NSMutableArray *movies = [NSMutableArray array];
    NSString *stringURL = [NSString stringWithFormat:@"https://api.themoviedb.org/3/search/movie?query=%@&api_key=%@", newQuery, key];
    NSMutableURLRequest *request = [self getRequestWithStringURL:stringURL];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        /* Prints movie data response to console
         NSString *movieData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
         NSLog(@"%@", movieData); */
        
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSError *error = nil;
            if (data != nil) {
                id results = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:0
                              error:&error];
                
                if (error) { NSLog(@"Error retrieving movie data"); }
                
                if ([results isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *movieResults = [results objectForKey:@"results"];
                    for (id movie in movieResults) {
                        [movies addObject:[NSNumber numberWithInt: (int)[[movie objectForKey:@"id"] integerValue]]];
                    }
                    
                    if (movies.count > 0) {
                        __block int count = 0;
                        NSLog(@"Entering getmovies");
                        for (int i = 0; i < movies.count; i++) {
                            NSNumber *movieId = movies[i];
                            [self getMovieForID:movieId.integerValue completion:^(Movie *movie) {
                                [movies setObject:movie atIndexedSubscript:i];
                                count++;
                                if (count == movies.count) {
                                    NSLog(@"completed");
                                    completion(movies);
                                }
                            }];
                        }
                    } else {
                        completion([NSMutableArray array]);
                    }
                }
                else {
                    NSLog(@"Not valid dictionary");
                }
            } else {
                completion(nil);
            }
        }
    }] resume];
}

/* Returns movie data for ID */
- (void)getMovieForID:(NSInteger)idNumber completion:(void (^)(Movie *))completion {
    NSString *stringURL = [NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%lu?api_key=%@&append_to_response=release_dates", idNumber, key];
    NSMutableURLRequest *request = [self getRequestWithStringURL:stringURL];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSError *error = nil;
            id movie = [NSJSONSerialization
                        JSONObjectWithData:data
                        options:0
                        error:&error];
            
            if (error) { NSLog(@"Error retrieving movie"); }
            
            if ([movie isKindOfClass:[NSDictionary class]]) {
                completion([self createMovieFromDict:movie isOnlyMovie:YES]);
            }
            
            else {
                NSLog(@"Not valid dictionary");
            }
        }
    }] resume];
}

/* Returns trailer video for ID */
- (void)getTrailerForID:(NSNumber *)idNumber completion:(void (^)(NSString *))completion {
    NSString *stringURL = [NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%@/videos?api_key=%@", idNumber, key];
    NSMutableURLRequest *request = [self getRequestWithStringURL:stringURL];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSError *error = nil;
            id results = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:0
                          error:&error];
            
            if (error) { NSLog(@"Error retrieving trailer data"); }
            
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
        }
    }] resume];
}

- (void)getCastForID:(NSInteger)idNumber completion:(void (^)(NSArray *))completion {
    NSString *stringURL = [NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%lu/credits?api_key=%@", idNumber, key];
    NSMutableURLRequest *request = [self getRequestWithStringURL:stringURL];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSError *error = nil;
            id credits = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:0
                          error:&error];
            
            if (error) { NSLog(@"Error retrieving credits"); }
            
            if ([credits isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *castArray = [[NSMutableArray alloc] init];
                for (id member in [credits objectForKey:@"cast"]) {
                    NSString *name = [member objectForKey:@"name"];
                    NSString *character = [member objectForKey:@"character"];
                    NSString *profile = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [member objectForKey:@"profile_path"]];
                    [castArray addObject:@[name, character, profile]];
                }
                completion([castArray copy]);
            }
            else {
                NSLog(@"Not valid dictionary");
            }
        }
    }] resume];
}

/* Returns array of movie IDs in theaters for US */
- (void)getNowPlaying:(void (^)(NSMutableArray *))completion {
    NSMutableArray *movies = [NSMutableArray array];
    NSString *stringURL = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/now_playing?api_key=%@&region=US", key];
    NSMutableURLRequest *request = [self getRequestWithStringURL:stringURL];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSError *error = nil;
            id results = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:0
                          error:&error];
            
            if (error) { NSLog(@"Error retrieving movie data"); }
            
            if ([results isKindOfClass:[NSDictionary class]]) {
                NSDictionary *movieResults = [results objectForKey:@"results"];
                for (id movie in movieResults) {
                    [movies addObject:[NSNumber numberWithInt: (int)[[movie objectForKey:@"id"] integerValue]]];
                }
                
                __block int count = 0;
                for (int i = 0; i < movies.count; i++) {
                    NSNumber *movieId = movies[i];
                    [self getMovieForID:movieId.integerValue completion:^(Movie *movie) {
                        [movies setObject:movie atIndexedSubscript:i];
                        count++;
                        if (count == movies.count) {
                            completion(movies);
                        }
                    }];
                }
            }
            else {
                NSLog(@"Not valid dictionary");
            }
        }
    }] resume];
}

/* Returns array of movie IDs in theaters for US */
- (void)getPopular:(void (^)(NSMutableArray *))completion {
    NSMutableArray *movies = [NSMutableArray array];
    NSString *stringURL = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/popular?api_key=%@&region=US", key];
    NSMutableURLRequest *request = [self getRequestWithStringURL:stringURL];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSError *error = nil;
            id results = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:0
                          error:&error];
            
            if (error) { NSLog(@"Error retrieving movie data"); }
            
            if ([results isKindOfClass:[NSDictionary class]]) {
                NSDictionary *movieResults = [results objectForKey:@"results"];
                for (id movie in movieResults) {
                    [movies addObject:[NSNumber numberWithInt: (int)[[movie objectForKey:@"id"] integerValue]]];
                }
                
                __block int count = 0;
                for (int i = 0; i < movies.count; i++) {
                    NSNumber *movieId = movies[i];
                    [self getMovieForID:movieId.integerValue completion:^(Movie *movie) {
                        [movies setObject:movie atIndexedSubscript:i];
                        count++;
                        if (count == movies.count) {
                            completion(movies);
                        }
                    }];
                }
            }
            else {
                NSLog(@"Not valid dictionary");
            }
        }
    }] resume];
}

/* Returns array of movie IDs similar to input movie ID */
-(void)getRecommendedForID:(NSInteger)idNumber completion:(void (^)(NSMutableArray *))completion {
    NSMutableArray *movies = [NSMutableArray array];
    NSString *stringURL = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%ld/similar?api_key=%@", idNumber, key];
    NSMutableURLRequest *request = [self getRequestWithStringURL:stringURL];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSError *error = nil;
            id results = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:0
                          error:&error];
            
            if (error) { NSLog(@"Error retrieving movie data"); }
            
            if ([results isKindOfClass:[NSDictionary class]]) {
                NSDictionary *movieResults = [results objectForKey:@"results"];
                for (id movie in movieResults) {
                    [movies addObject:[NSNumber numberWithInt: (int)[[movie objectForKey:@"id"] integerValue]]];
                }
                
                __block int count = 0;
                for (int i = 0; i < movies.count; i++) {
                    NSNumber *movieId = movies[i];
                    [self getMovieForID:movieId.integerValue completion:^(Movie *movie) {
                        [movies setObject:movie atIndexedSubscript:i];
                        count++;
                        if (count == movies.count) {
                            completion(movies);
                        }
                    }];
                }
            }
            else {
                NSLog(@"Not valid dictionary");
            }
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

- (Movie *)createMovieFromDict:(NSDictionary *)movieDict isOnlyMovie:(BOOL)isOnlyMovie {
    NSString *title = [movieDict objectForKey:@"title"];
    NSString *overview = [movieDict objectForKey:@"overview"];
    NSString *releaseDate = [self formatDate:[movieDict objectForKey:@"release_date"]];
    NSNumber *runtimeMinutes = [NSNumber numberWithInteger:[[movieDict objectForKey:@"runtime"] integerValue]];
    NSString *runtime = [self formatRuntime:runtimeMinutes.intValue];
    NSNumber *rating = [NSNumber numberWithDouble:[[movieDict objectForKey:@"vote_average"] doubleValue]];
    NSString *poster = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movieDict objectForKey:@"poster_path"]];
    NSString *backdrop = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movieDict objectForKey:@"backdrop_path"]];
    NSNumber *idNumber = [NSNumber numberWithInt: (int)[[movieDict objectForKey:@"id"] integerValue]];
    NSMutableArray *movieGenres = [[NSMutableArray alloc] init];
    
    // Get genres
    if (isOnlyMovie) {
        NSArray *genreResults = [NSArray arrayWithArray:[movieDict objectForKey:@"genres"]];
        for (id genre in genreResults) {
            if (self.genres[[genre objectForKey:@"id"]] != nil) {
                [movieGenres addObject:self.genres[[genre objectForKey:@"id"]]];
            }
        }
    } else {
        NSArray *genreNumbers = [NSArray arrayWithArray:[movieDict objectForKey:@"genre_ids"]];
        for (NSNumber *genreID in genreNumbers) {
            if (self.genres[genreID] != nil) {
                [movieGenres addObject:self.genres[genreID]];
            }
        }
    }
    
    // Get certification
    NSDictionary *releaseDateResults = [[movieDict objectForKey:@"release_dates"] objectForKey:@"results"];
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
