# Hackathon (Team 08) - Smart UMAC

This is the repository for team 08 (SmartUmac) in the Hackathon Competition. 
I chose to solve Problem #1 by creating an app about News and Events in order
to keep students up to date with the campus most recent activities

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. Please keep reading

### Prerequisites

In order to get this project running you need the following software:

- XCODE

The following dependencies need to be installed:

SwiftSoup - This is used to parse the html content of the News api

### Installing

To install swiftsoup first you need to install cocoapods - https://cocoapods.org/

After installing cocoapods, create a Podfile in the same directory as your application folder:

```
touch Podfile
```
Inside the Podfile add the following content

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target 'SmartUmac' do
    pod 'SwiftSoup'
end

```

In the end run the following command

```
pod install
```

And you are all set!

### APIs

My app uses 3 APIs:

- UM NEWS
- UM EVENTS
- PUBLIC HOLIDAYS

The app is organized in 3 tabs, one for the News API, one for the Events API
and one for the Holidays and Events API combined in a calendar that shows
which days have activities and allows these calendar days to be clickable and
show the activities happening that day

![alt text](https://github.com/RickBoss/SmartUmac/blob/master/Presentation/News%20Screen%20Main.png) ![alt text](https://github.com/RickBoss/SmartUmac/blob/master/Presentation/Screen%20Shot%202018-10-27%20at%207.20.14%20AM.png)
![alt text](https://github.com/RickBoss/SmartUmac/blob/master/Presentation/Screen%20Shot%202018-10-27%20at%207.21.02%20AM.png)
