# Movie Search
Discover and search for the latest movies using Movie Search for iPhone. Uses [The Movie Database API](https://www.themoviedb.org/documentation/api) to find and retrieve movie information.

<img src="https://cloud.githubusercontent.com/assets/17148467/21966242/ca27bb56-db24-11e6-8073-4ee401a241d3.png" height="534" width="300">
<img src="https://cloud.githubusercontent.com/assets/17148467/21966243/ca28f106-db24-11e6-8a31-a415847df25e.png" height="534" width="300">

## Getting Started
1. Install Xcode.

2. Clone this repository.

3. Install dependencies using [CocoaPods](https://github.com/CocoaPods/CocoaPods).

4. Create an account with [tMDB](https://www.themoviedb.org/account/signup?language=en) and apply for an API key.

5. Create files in MovieSearch.xcworkspace holding your key:

    ```objc
    // Constants.h
    extern NSString *const key;

    // Constants.m
    NSString *const key = @"your-key-here";
    ```
    
6. Build and run.

## Dependencies 
- [Realm](https://github.com/realm/realm-cocoa)

## Known Issues & Bugs
- Discover tab is incomplete
- Crashes when there is no internet connection
