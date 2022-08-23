<center>Combined Animation Widget</center>

<center>

[![pub package](https://img.shields.io/pub/v/combined_animation.svg)](https://pub.dartlang.org/packages/combined_animation)

</center>

A combined animation widget, contains alignment, opacity, transform for show in and hide out a widget.

## Features

- [x] alignment animation.
- [x] opacity animation.
- [x] transform animation.
- [x] size animation.

- [x] enter animation.
- [x] leave animation.

## Preview

![preview](preview/combined_animation.gif "preview")

## Getting started

```shell
flutter pub add combined_animation
```

## Usage

```dart
CombinedAnimation(
    state: willRemove?
        ? AnimationType.end
        : AnimationType.start,
    onLeaved: (size) {
        
    },
    onDissmiss:(){
        doRemove(item);
        setState(() {});
    },
    config: AnimationConfig.fadeAndZoomIn,
    child: child,
)
```

## Produce
