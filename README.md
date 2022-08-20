<center>Combined Animation Widget</center>

A combined animation widget, contains alignment, opacity, transform for show in and hide out a widget.

## Features

- [x] alignment animation.
- [x] opacity animation.
- [x] transform animation.

- [x] show in animation.
- [x] hide out animation.

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
    onEndOut: () {
        doRemove(item);
        setState(() {});
    },
    config: AnimationConfig.fadeAndZoomIn,
    child: child,
)
```

