//
//  DetailViewController.m
//  CineSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "DetailViewController.h"
#import "MovieSingleton.h"
#import "MovieID.h"
#import "CastCollectionViewCell.h"
#import <Realm/Realm.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MXParallaxHeader/MXParallaxHeader.h>

@interface DetailViewController ()

@property (nonatomic, strong) RLMResults *array;
@property (nonatomic, strong) RLMNotificationToken *notification;

@end

@implementation DetailViewController

- (void)configureView {
    // Configure buttons
    self.trailerButton.layer.cornerRadius = 5;
    self.trailerButton.layer.masksToBounds = YES;
    self.favoriteButton.layer.cornerRadius = 5;
    self.favoriteButton.layer.masksToBounds = YES;
    self.ratingView.layer.cornerRadius = 5;
    self.ratingView.layer.masksToBounds = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.hidden = YES;
    
    // Update the user interface for the detail item.
    self.movieTitleLabel.text = self.movie.title;
    self.detailLabel.text = [NSString stringWithFormat:@"%@ ‧ %@ ‧ %@", self.movie.certification, self.movie.runtime, self.movie.releaseDate ?: @"TBA"];
    self.ratingLabel.text = [NSString stringWithFormat:@"%0.1f", [self.movie.rating doubleValue]];
    self.overviewLabel.text = self.movie.overview;
    if ([self.overviewLabel.text isEqualToString:@""]) {
        self.overviewLabel.text = @"No summary available.";
    }
    
    // Format and display genres label text
    self.genreLabel.text = [self.movie.genres componentsJoinedByString:@" | "];
    
    // Set up parallax header
    self.scrollView.parallaxHeader.view = self.headerView;
    
    // Download poster image from URL
    [self.posterLoadingIndicator startAnimating];
    NSURL *posterURL = [[NSURL alloc] initWithString:self.movie.posterURL];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:posterURL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        [self.posterLoadingIndicator stopAnimating];
        if (image) {
            self.posterImageView.image = image;
            if (cacheType == SDImageCacheTypeNone) {
                [UIView transitionWithView:self.posterImageView
                                  duration:0.2
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    self.posterImageView.image = image;
                                } completion:nil];
            } else {
                self.posterImageView.image = image;
            }
        } else {
            self.posterImageView.image = [UIImage imageNamed:@"BlankMoviePoster"];
        }
    }];
    
    // Download backdrop image from URL
    self.backdropImageView.image = [UIImage imageNamed:@"BlankBackdrop"];
    self.backdropImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.scrollView.parallaxHeader.height = self.view.frame.size.height/3;
    self.scrollView.parallaxHeader.mode = MXParallaxHeaderModeFill;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 2436: // iPhone X Height
                self.scrollView.parallaxHeader.minimumHeight = 88;
                break;
            default:
                self.scrollView.parallaxHeader.minimumHeight = 64;
        }
    }
    
    NSURL *backdropURL = [[NSURL alloc] initWithString:self.movie.backdropURL];
    [manager loadImageWithURL:backdropURL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        [self.posterLoadingIndicator stopAnimating];
        if (image) {
            CIContext *context = [CIContext contextWithOptions:nil];
            CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
            
            CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
            [filter setValue:inputImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:4.0f] forKey:@"inputRadius"];
            CIImage *result = [filter valueForKey:kCIOutputImageKey];
            
            CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
            [UIView transitionWithView:self.backdropImageView
                              duration:0.4
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.backdropImageView.image = [UIImage imageWithCGImage:cgImage];
                            } completion:nil];
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }];
    
    // Set up cast collection view
    self.castCollectionView.backgroundColor = [UIColor clearColor];
    
    [self.manager.database getCastForID:self.movie.idNumber.integerValue completion:^(NSArray *cast) {
        int actorCount = (int)MIN(6, cast.count);
        self.castImageDict = [[NSMutableDictionary alloc] init];
        self.castArray = [cast subarrayWithRange:NSMakeRange(0, actorCount)];
        
        if (actorCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.castCollectionView removeConstraint:self.castCollectionViewHeight];
                [self.castCollectionView layoutIfNeeded];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.castCollectionView reloadData];
                self.castCollectionView.hidden = NO;
                [UIView animateWithDuration:0.4 animations:^() {
                    self.castCollectionView.alpha = 1.0;
                }];
            });
            dispatch_group_t actorGroup = dispatch_group_create();
            
            for (int i = 0; i < actorCount; i++) {
                Actor *actor = self.castArray[i];
                NSURL *url = [[NSURL alloc] initWithString:actor.profileURL];
                dispatch_group_enter(actorGroup);
                [manager loadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (image) {
                        NSString *key = [NSString stringWithFormat: @"%d", i];
                        [self.castImageDict setValue:image forKey:key];
                    }
                    if (cacheType == SDImageCacheTypeNone) {
                        self.castImagesFromWeb = YES;
                    }
                    dispatch_group_leave(actorGroup);
                }];
            }
            
            dispatch_group_notify(actorGroup, dispatch_get_main_queue(),^{
                [self.castCollectionView reloadData];
            });
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [MovieSingleton sharedManager];
    self.array = [[MovieID allObjects] sortedResultsUsingKeyPath:@"movieID" ascending:YES];
    self.scrollView.delegate = self;
    self.castCollectionView.delegate = self;
    self.castCollectionView.dataSource = self;
    self.castCollectionView.hidden = YES;
    self.castCollectionView.alpha = 0;
    self.castImagesFromWeb = NO;
    
    [self configureView];
    
    __weak typeof(self) weakSelf = self;
    self.notification = [self.array addNotificationBlock:^(RLMResults *data, RLMCollectionChange *changes, NSError *error) {
        if (error) {
            NSLog(@"Failed to open Realm on background worker: %@", error);
            return;
        }
        
        weakSelf.isFavorite = NO;
        
        for (MovieID *realmMovieID in weakSelf.array) {
            if (realmMovieID.movieID == [weakSelf.movie.idNumber integerValue]) {
                weakSelf.isFavorite = YES;
            }
        }
        
        if (!weakSelf.isFavorite) {
            [weakSelf.favoriteButton setTintColor:[UIColor whiteColor]];
            [weakSelf.favoriteButton setImage:[UIImage imageNamed:@"HeartHollow"] forState:UIControlStateNormal];
        } else {
            [weakSelf.favoriteButton setTintColor:[UIColor colorWithRed:1.00 green:0.32 blue:0.30 alpha:1.0]];
            [weakSelf.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.isFavorite) {
        [self.favoriteButton setTintColor:[UIColor whiteColor]];
        [self.favoriteButton setImage:[UIImage imageNamed:@"HeartHollow"] forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setTintColor:[UIColor colorWithRed:1.00 green:0.32 blue:0.30 alpha:1.0]];
        [self.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
    }
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollView == scrollView) {
        self.posterImageView.alpha = scrollView.parallaxHeader.progress;
    }
}

#pragma mark - Managing the detail item

- (void)setMovie:(Movie *)newMovie {
    if (_movie != newMovie) {
        _movie = newMovie;
    }
}

- (IBAction)back:(UIButton *)sender {
    UINavigationController *navCon = [self.splitViewController.viewControllers objectAtIndex:0];
    [navCon popViewControllerAnimated: YES];
}

- (IBAction)favoritePressed:(UIButton *)sender {
    RLMRealm *realm = RLMRealm.defaultRealm;
    if (self.favoriteButton.tintColor != [UIColor whiteColor]) {
        // Animate to empty heart
        [UIView animateWithDuration:0.3/2.5 animations:^{
            sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            [self.favoriteButton setTintColor:[UIColor whiteColor]];
            [self.favoriteButton setImage:[UIImage imageNamed:@"HeartHollow"] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2.5 animations:^{
                sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2.5 animations:^{
                    sender.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
        
        // Remove from favorites list
        MovieID *movieToDelete = [MovieID objectForPrimaryKey:@([self.movie.idNumber integerValue])];
        
        [realm beginWriteTransaction];
        [realm deleteObject:movieToDelete];
        [realm commitWriteTransaction];
        
    } else {
        // Animate to red filled heart
        [UIView animateWithDuration:0.3/2.5 animations:^{
            sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            [self.favoriteButton setTintColor:[UIColor colorWithRed:1.00 green:0.32 blue:0.30 alpha:1.0]];
            [self.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2.5 animations:^{
                sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2.5 animations:^{
                    sender.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
        
        // Add to favorites list
        [realm beginWriteTransaction];
        [MovieID createInRealm:realm withValue:@{@"movieID": @([self.movie.idNumber integerValue])}];
        [realm commitWriteTransaction];
    }
}

- (IBAction)openTrailer:(UIButton *)sender {
    [self.manager.database getTrailerForID:self.movie.idNumber completion:^(NSString *trailer) {
        if (trailer != nil) {
            NSURL *appTrailer = [NSURL URLWithString:[NSString stringWithFormat:@"youtube:///watch?v=%@", trailer]];
            NSURL *webTrailer = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", trailer]];
            
            if ([[UIApplication sharedApplication] canOpenURL:appTrailer]) {
                [[UIApplication sharedApplication] openURL:appTrailer];
            }
            else {
                [[UIApplication sharedApplication] openURL:webTrailer];
            }
        } else {
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:@"Trailer not found"
                                        message:@"Search YouTube for movie trailer?"
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        
                                        handler:^(UIAlertAction * action) {
                                            NSString* query = [self.movie.title stringByReplacingOccurrencesOfString:@" "
                                                                                                          withString:@"+"];
                                            
                                            NSURL *appTrailer = [NSURL URLWithString:[NSString stringWithFormat:@"youtube:///results?q=%@+trailer", query]];
                                            NSURL *webTrailer = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/results?q=%@+trailer", query]];
                                            
                                            if ([[UIApplication sharedApplication] canOpenURL:appTrailer]) {
                                                [[UIApplication sharedApplication] openURL:appTrailer];
                                            }
                                            else {
                                                [[UIApplication sharedApplication] openURL:webTrailer];
                                            }
                                        }];
            
            UIAlertAction* cancelButton = [UIAlertAction
                                           actionWithTitle:@"Cancel"
                                           style:UIAlertActionStyleCancel
                                           
                                           handler:^(UIAlertAction * action) {
                                               
                                           }];
            
            [alert addAction:cancelButton];
            [alert addAction:yesButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.castArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CastCell";
    
    CastCollectionViewCell *cell = (CastCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.profileImageView.image = [UIImage imageNamed:@"BlankActor"];
    cell.nameLabel.text = @"";
    cell.roleLabel.text = @"";
    cell.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.profileImageView.layer.cornerRadius = 6;
    cell.profileImageView.layer.masksToBounds = YES;
    
    if (self.castArray.count != 0) {
        Actor *actor = self.castArray[indexPath.row];
        cell.nameLabel.text = actor.name;
        cell.roleLabel.text = actor.role;
        
        NSString *key = [NSString stringWithFormat:@"%lu", indexPath.row];
        if (self.castImageDict[key] != nil) {
            if (self.castImagesFromWeb) {
                [UIView transitionWithView:cell.profileImageView
                                  duration:0.2
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    cell.profileImageView.image = self.castImageDict[key];
                                } completion:nil];
            } else {
                cell.profileImageView.image = self.castImageDict[key];
            }
        }
    }
    
    return cell;
}

@end
