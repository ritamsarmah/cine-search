//
//  DiscoverViewController.h
//  MovieSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieSingleton.h"

@interface DiscoverViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property NSTimer *scrollTimer;
@property MovieSingleton *manager;
@property NSMutableArray *moviesNowPlaying;
@property NSMutableDictionary *imageCache;

@end
