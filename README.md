# CineSearch
Discover and search for the latest movies using CineSearch for iPhone. Uses [The Movie Database API](https://www.themoviedb.org/documentation/api) to find and retrieve movie information.

<img src="https://user-images.githubusercontent.com/17148467/34470124-9e82bfa8-eedf-11e7-9af2-4cc21d125d19.png" height="534" width="300">
<img src="https://user-images.githubusercontent.com/17148467/34470123-9e6c3e68-eedf-11e7-9b3b-e081c02d103c.png" height="534" width="300">
<img src="https://user-images.githubusercontent.com/17148467/34470125-9e98b3da-eedf-11e7-9549-7eff8c80f58c.png" height="534" width="300">

## Getting Started
1. Install Xcode.

2. Clone this repository.

3. Install dependencies using [CocoaPods](https://github.com/CocoaPods/CocoaPods).

4. Create an account with [tMDB](https://www.themoviedb.org/account/signup?language=en) and apply for an API key.

5. Create files in CineSearch.xcworkspace holding your key:

    ```objc
    // Constants.h
    extern NSString *const key;

    // Constants.m
    NSString *const key = @"your-key-here";
    ```

6. Build and run.

## Dependencies
- [Realm](https://github.com/realm/realm-cocoa)
- [MKParallaxHeader](https://github.com/maxep/MXParallaxHeader)
- [SDWebImage](https://github.com/rs/SDWebImage)
