//
//  DiscoverViewController.h
//  MovieSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class MovieSingleton;

@interface DiscoverViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) UIActivityIndicatorView *loadingMovies;
@property (weak, nonatomic) UILabel *bannerLabel;

@property NSTimer *scrollTimer;
@property MovieSingleton *manager;
@property NSMutableArray *moviesNowPlaying;
@property NSMutableArray *bannerMovies; // Movies for banner images
@property NSMutableDictionary *imageCache;

-(void)setupImageScrollView;
-(void)nextImage;
-(void)openMovie:(UITapGestureRecognizer *)sender;


@end
