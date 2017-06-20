# Linenoise-Swift

A pure Swift implementation of the [Linenoise](http://github.com/antirez/linenoise) library. A minimal, zero-config readline replacement.

### Supports
* Mac OS and Linux
* Line editing with emacs keybindings
* History handling
* Completion
* Hints

### Pure Swift
Implemented in pure Swift, with a Swifty API, this library is easy to embed in projects using Swift Package Manager, and requires no additional dependencies.

## Contents
- [API](#api)
  * [Quick Start](#quick-start)
  * [Basics](#basics)
  * [History](#history)
    + [Adding to History](#adding-to-history)
    + [Limit the Number of Items in History](#limit-the-number-of-items-in-history)
    + [Saving the History to a File](#saving-the-history-to-a-file)
    + [Loading History From a File](#loading-history-from-a-file)
  * [Completion](#completion)
  * [Hints](#hints)
- [Acknowledgements](#acknowledgements)

# API

## Quick Start
Linenoise-Swift is easy to use, and can be used as a replacement for [`Swift.readLine`](https://developer.apple.com/documentation/swift/1641199-readline). Here is a simple example:

```swift
let ln = LineNoise()

do {
	let input = try ln.getLine(prompt: "> ")
} catch {
	print(error)
}
	
```

## Basics
Simply creating a new `LineNoise` object is all that is necessary in most cases, with STDIN used for input and STDOUT used for output by default. However, it is possible to supply different files for input and output if you wish:

```swift
// 'in' and 'out' are standard POSIX file handles
let ln = LineNoise(inputFile: in, outputFile: out)
```

## History
### Adding to History
Adding to the history is easy:

```swift
let ln = LineNoise()

do {
	let input = try ln.getLine(prompt: "> ")
	ln.addHistory(input)
} catch {
	print(error)
}
```

### Limit the Number of Items in History
You can optionally set the maximum amount of items to keep in history. Setting this to `0` (the default) will keep an unlimited amount of items in history.
```swift
ln.setHistoryMaxLength(100)
```

### Saving the History to a File
```swift
ln.saveHistory(toFile: "/tmp/history.txt")
```

### Loading History From a File
This will add all of the items from the file to the current history
```swift
ln.loadHistory(fromFile: "/tmp/history.txt")
```

## Completion
![Completion example](https://github.com/andybest/linenoise-swift/raw/master/images/completion.gif)

Linenoise supports completion with `tab`. You can provide a callback to return an array of possible completions:

```swift
let ln = LineNoise()

ln.setCompletionCallback { currentBuffer in
    let completions = [
        "Hello, world!",
        "Hello, Linenoise!",
        "Swift is Awesome!"
    ]
    
    return completions.filter { $0.hasPrefix(currentBuffer) }
}
```

The completion callback gives you whatever has been typed before `tab` is pressed. Simply return an array of Strings for possible completions. These can be cycled through by pressing `tab` multiple times.

## Hints
![Hints example](https://github.com/andybest/linenoise-swift/raw/master/images/hints.gif)

Linenoise supports providing hints as you type. These will appear to the right of the current input, and can be selected by pressing `Return`.

The hints callback has the contents of the current line as input, and returns a tuple consisting of an optional hint string and an optional color for the hint text, e.g.:

```swift
let ln = LineNoise()

ln.setHintsCallback { currentBuffer in
    let hints = [
        "Carpe Diem",
        "Lorem Ipsum",
        "Swift is Awesome!"
    ]
    
    let filtered = hints.filter { $0.hasPrefix(currentBuffer) }
    
    if let hint = filtered.first {
        // Make sure you return only the missing part of the hint
        let hintText = String(hint.dropFirst(currentBuffer.count))
        
        // (R, G, B)
        let color = (127, 0, 127)
        
        return (hintText, color)
    } else {
        return (nil, nil)
    }
}

```

# Acknowledgements
Linenoise-Swift is heavily based on the [original linenoise library](http://github.com/antirez/linenoise) by [Salvatore Sanfilippo (antirez)](http://github.com/antirez)
