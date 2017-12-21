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
    NSString *url = [NSString stringWithFormat:@"https://api.themoviedb.org/3/search/movie?query=%@&api_key=%@", newQuery, key];
    // TODO: &append_to_response=release_dates for certifications
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
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
                        NSString *title = [movie objectForKey:@"title"];
                        NSString *overview = [movie objectForKey:@"overview"];
                        NSString *releaseDate = [self formatDate:[movie objectForKey:@"release_date"]];
                        NSNumber *rating = [NSNumber numberWithDouble:[[movie objectForKey:@"vote_average"] doubleValue]];
                        NSString *poster = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"poster_path"]];
                        NSString *backdrop = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"backdrop_path"]];
                        NSArray *genreNumbers = [NSArray arrayWithArray:[movie objectForKey:@"genre_ids"]];
                        NSMutableArray *movieGenres = [[NSMutableArray alloc] init];
                        // TODO: Add certification to movie
                        for (NSNumber *genreID in genreNumbers) {
                            if (self.genres[genreID] != nil) {
                                [movieGenres addObject:self.genres[genreID]];
                            }
                        }
                        
                        NSNumber *idNumber = [NSNumber numberWithInt: (int)[[movie objectForKey:@"id"] integerValue]];
                        
                        Movie *newMovie = [[Movie alloc] initWithTitle:title overview:overview releaseDate:releaseDate rating:rating genres:movieGenres posterURL:poster backdropURL:backdrop idNumber:idNumber];
                        [movies addObject:newMovie];
                    }
                    completion(movies);
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

- (NSString *)formatDate:(NSString *)stringDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:stringDate];
    
    [dateFormat setDateFormat: @"MMMM d, YYYY"];
    stringDate = [dateFormat stringFromDate:date];
    return stringDate;
}

/* Returns movie data for ID */
- (void)getMovieForID:(NSInteger)idNumber completion:(void (^)(Movie *))completion {
    NSString *stringURL = [NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%lu?api_key=%@&append_to_response=release_dates", idNumber, key];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:stringURL]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
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
                NSString *title = [movie objectForKey:@"title"];
                NSString *overview = [movie objectForKey:@"overview"];
                NSString *releaseDate = [self formatDate:[movie objectForKey:@"release_date"]];
                NSNumber *rating = [NSNumber numberWithDouble:[[movie objectForKey:@"vote_average"] doubleValue]];
                NSString *poster = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"poster_path"]];
                NSString *backdrop = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"backdrop_path"]];
                NSArray *genreResults = [NSArray arrayWithArray:[movie objectForKey:@"genres"]];
                NSMutableArray *movieGenres = [[NSMutableArray alloc] init];
                // TODO: Add certification to movie
                for (id genre in genreResults) {
                    if (self.genres[[genre objectForKey:@"id"]] != nil) {
                        [movieGenres addObject:self.genres[[genre objectForKey:@"id"]]];
                    }
                }
                
                NSNumber *idNumber = [NSNumber numberWithInt: (int)[[movie objectForKey:@"id"] integerValue]];
                
                Movie *newMovie = [[Movie alloc] initWithTitle:title overview:overview releaseDate:releaseDate rating:rating genres:movieGenres posterURL:poster backdropURL:backdrop idNumber:idNumber];
                completion(newMovie);
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
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:stringURL]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
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
                    if ([[video objectForKey:@"name"]  containsString:@"Trailer"]) {
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

/* Returns array of movies in theaters for US */
- (void)getNowPlaying:(void (^)(NSMutableArray *))completion {
    NSMutableArray *movies = [NSMutableArray array];
    NSString *stringURL = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/now_playing?api_key=%@&region=US", key];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:stringURL]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
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
                    NSString *title = [movie objectForKey:@"title"];
                    NSString *overview = [movie objectForKey:@"overview"];
                    NSString *releaseDate = [self formatDate:[movie objectForKey:@"release_date"]];
                    NSNumber *rating = [NSNumber numberWithDouble:[[movie objectForKey:@"vote_average"] doubleValue]];
                    NSString *poster = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"poster_path"]];
                    NSString *backdrop = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"backdrop_path"]];
                    NSArray *genreNumbers = [NSArray arrayWithArray:[movie objectForKey:@"genre_ids"]];
                    NSMutableArray *movieGenres = [[NSMutableArray alloc] init];
                    for (NSNumber *genreID in genreNumbers) {
                        if (self.genres[genreID] != nil) {
                            [movieGenres addObject:self.genres[genreID]];
                        }
                    }
                    
                    NSNumber *idNumber = [NSNumber numberWithInt: (int)[[movie objectForKey:@"id"] integerValue]];
                    
                    Movie *newMovie = [[Movie alloc] initWithTitle:title overview:overview releaseDate:releaseDate rating:rating genres:movieGenres posterURL:poster backdropURL:backdrop idNumber:idNumber];
                    [movies addObject:newMovie];
                }
                completion(movies);
            }
            else {
                NSLog(@"Not valid dictionary");
            }
        }
    }] resume];
}

/* Returns array of movies in theaters for US */
- (void)getPopular:(void (^)(NSMutableArray *))completion {
    NSMutableArray *movies = [NSMutableArray array];
    NSString *stringURL = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/popular?api_key=%@&region=US", key];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:stringURL]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
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
                    NSString *title = [movie objectForKey:@"title"];
                    NSString *overview = [movie objectForKey:@"overview"];
                    NSString *releaseDate = [self formatDate:[movie objectForKey:@"release_date"]];
                    NSNumber *rating = [NSNumber numberWithDouble:[[movie objectForKey:@"vote_average"] doubleValue]];
                    NSString *poster = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"poster_path"]];
                    NSString *backdrop = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"backdrop_path"]];
                    NSArray *genreNumbers = [NSArray arrayWithArray:[movie objectForKey:@"genre_ids"]];
                    NSMutableArray *movieGenres = [[NSMutableArray alloc] init];
                    for (NSNumber *genreID in genreNumbers) {
                        if (self.genres[genreID] != nil) {
                            [movieGenres addObject:self.genres[genreID]];
                        }
                    }
                    
                    NSNumber *idNumber = [NSNumber numberWithInt: (int)[[movie objectForKey:@"id"] integerValue]];
                    
                    Movie *newMovie = [[Movie alloc] initWithTitle:title overview:overview releaseDate:releaseDate rating:rating genres:movieGenres posterURL:poster backdropURL:backdrop idNumber:idNumber];
                    [movies addObject:newMovie];
                }
                completion(movies);
            }
            else {
                NSLog(@"Not valid dictionary");
            }
        }
    }] resume];
}

-(void)getRecommendedForID:(NSInteger)idNumber completion:(void (^)(NSMutableArray *))completion {
    NSMutableArray *movies = [NSMutableArray array];
    NSString *stringURL = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%ld/similar?api_key=%@", idNumber, key];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:stringURL]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
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
                    NSString *title = [movie objectForKey:@"title"];
                    NSString *overview = [movie objectForKey:@"overview"];
                    NSString *releaseDate = [self formatDate:[movie objectForKey:@"release_date"]];
                    NSNumber *rating = [NSNumber numberWithDouble:[[movie objectForKey:@"vote_average"] doubleValue]];
                    NSString *poster = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"poster_path"]];
                    NSString *backdrop = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"backdrop_path"]];
                    NSArray *genreNumbers = [NSArray arrayWithArray:[movie objectForKey:@"genre_ids"]];
                    NSMutableArray *movieGenres = [[NSMutableArray alloc] init];
                    for (NSNumber *genreID in genreNumbers) {
                        if (self.genres[genreID] != nil) {
                            [movieGenres addObject:self.genres[genreID]];
                        }
                    }
                    
                    NSNumber *idNumber = [NSNumber numberWithInt: (int)[[movie objectForKey:@"id"] integerValue]];
                    
                    Movie *newMovie = [[Movie alloc] initWithTitle:title overview:overview releaseDate:releaseDate rating:rating genres:movieGenres posterURL:poster backdropURL:backdrop idNumber:idNumber];
                    [movies addObject:newMovie];
                }
                completion(movies);
            }
            else {
                NSLog(@"Not valid dictionary");
            }
        }
    }] resume];
}

@end
