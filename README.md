# osx-mouse-cocoa

Mouse tracking for macOS. Receive the screen position of various mouse events.

  npm install osx-mouse-cocoa

This is a fork of [osx-mouse](https://github.com/kapetan/osx-mouse) that works on macOS Mojave without accessibility permissions. Unlike `osx-mouse`, the events are only emitted when the application is in focused. Even when the application is unfocused, `move` events are still generated when hovering over the application windows.

# Usage

The module returns an event emitter instance.

```javascript
var mouse = require('osx-mouse-cocoa')();

mouse.on('move', function(x, y) {
	console.log(x, y);
});
```

To stop tracking events, call `mouse.destroy()`. The `mouse.ref()` and `mouse.unref()` methods have been retained for API compatibility with `osx-mouse`, but they have no effect.

The events emitted are: `move`, `left-down`, `left-up`, `left-drag`, `right-up`, `right-down` and `right-drag`. For each event the screen coordinates are passed to the handler function.
