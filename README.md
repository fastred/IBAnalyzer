# IBAnalyzer

Find common xib/storyboard-related problems without having to run your app or write unit tests.

## Usage

Pass a path to your project to `IBAnalyzer` command line tool. That's it!

You can find the result of running `IBAnalyzer` on a sample app below:

```
$ ./IBAnalyzer ~/code/Sample/

TwitterViewController doesn't implement a required @IBAction named: loginButtonPressed:
TwitterViewController doesn't implement a required @IBOutlet named: twitterImageView
LoginViewController contains unused @IBAction named: onePasswordButtonTapped
MessageThreadCell contains unused @IBOutlet named: unreadIndicatorView
DashboardActionCell contains unused @IBOutlet named: drillDownIndicatorImageViews
MessagesViewController contains unused @IBAction named: backingInfoButtonPressed
```

## Features

- works with .xib, .storyboard and Swift (only version 3.0 or higher) files
- finds unimplemented outlets and actions in classes
- finds `@IBOutlet`s and `@IBAction`s defined in code but not used in xibs and storyboards

## Installation

### Manual

1. Clone or download the repo.
2. Build the project.
3. `$ cd Build/MacOS`
4. `$ ./IBAnalyzer /path/to/your/project`

### Binary

[Not implemented yet.](https://github.com/fastred/IBAnalyzer/issues/3)
