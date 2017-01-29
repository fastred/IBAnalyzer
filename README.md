# IBAnalyzer

Find common xib and storyboard-related problems without running your app and writing unit tests.

## Usage

Pass a path to your project to `IBAnalyzer` command line tool. Here's an example output you can expect:

```
$ ./IBAnalyzer ~/code/Sample/

TwitterViewController doesn't implement a required @IBAction named: loginButtonPressed:
TwitterViewController doesn't implement a required @IBOutlet named: twitterImageView
LoginViewController contains unused @IBAction named: onePasswordButtonTapped:
MessageCell contains unused @IBOutlet named: unreadIndicatorView
MessagesViewController contains unused @IBAction named: infoButtonPressed
```

You'll be able to avoid crashes caused by exceptions, like:

```
*** Terminating app due to uncaught exception 'NSUnknownKeyException', reason: '[<Sample.TwitterViewController 0x7fa84630a370> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key twitterImageView.'
```

## Features

- finds unimplemented outlets and actions in classes
- finds `@IBOutlet`s and `@IBAction`s defined in code but not used in xibs and storyboards

New warnings can be implemented by adding a new type conforming to the `Analyzer` protocol and initializing it in `main.swift`. Check [issues](https://github.com/fastred/IBAnalyzer/issues) to learn about some ideas for new warnings.

## Drawbacks

This is a new tool, used only on a handful of projects till now. If you encounter any bugs, please create new issues.

**Doesn't work with Objective-C. Tested on Swift 3.0.**

## How It Works

IBAnalyzer starts by parsing all `.xib,` `.storyboard` and `.swift` files in the provided folder. It then uses this data (wrapped in `AnalyzerConfiguration`) to generate warnings. You can see the source of an analyzer [checking connections between source code and nibs here](https://github.com/fastred/IBAnalyzer/blob/master/IBAnalyzer/Analyzers/ConnectionAnalyzer.swift).

## Installation

### Manual

1. Clone or download the repo.
2. Open `IBAnalyzer.xcworkspace` in Xcode 8.2 and build the project (⌘-B).
3. `$ cd Build/MacOS`
4. `$ ./IBAnalyzer /path/to/your/project`

### Binary

[Not implemented yet.](https://github.com/fastred/IBAnalyzer/issues/3) Help welcomed!

## Attributions

- [SourceKitten](https://github.com/jpsim/SourceKitten) – IBAnalyzer wouldn't be possible without it
- [SwiftGen](https://github.com/AliSoftware/SwiftGen) – inspiration for `NibParser`
