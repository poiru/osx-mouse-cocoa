#include "mouse.h"

#import <node.h>
#import <Cocoa/Cocoa.h>

#define countof(ar) (sizeof(ar)/sizeof(*(ar)))

using namespace v8;

Nan::Persistent<Function> Mouse::constructor;

const char *NSEventTypeToString(NSEventType type) {
  switch (type) {
  case NSEventTypeLeftMouseDown:
    return "left-down";
  case NSEventTypeLeftMouseUp:
    return "left-up";
  case NSEventTypeRightMouseDown:
    return "right-down";
  case NSEventTypeRightMouseUp:
    return "right-up";
  case NSEventTypeMouseMoved:
    return "move";
  case NSEventTypeLeftMouseDragged:
    return "left-drag";
  case NSEventTypeRightMouseDragged:
    return "right-drag";
  default:
    return nullptr;
  }
}

Mouse::Mouse(Nan::Callback *callback) {
  stopped = false;
  event_callback = callback;

  event_monitor = [NSEvent
      addLocalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown |
                                            NSEventMaskLeftMouseUp |
                                            NSEventMaskRightMouseDown |
                                            NSEventMaskRightMouseUp |
                                            NSEventMaskMouseMoved |
                                            NSEventMaskLeftMouseDragged |
                                            NSEventMaskRightMouseDragged)
                                   handler:^(NSEvent *e) {
                                     const char *type =
                                         NSEventTypeToString(e.type);
                                     const auto cgEvent = e.CGEvent;
                                     if (!type || !cgEvent) {
                                       return e;
                                     }

                                     const auto location =
                                         CGEventGetLocation(cgEvent);

                                     Local<Value> argv[] = {
                                         Nan::New<String>(type)
                                             .ToLocalChecked(),
                                         Nan::New<Number>(location.x),
                                         Nan::New<Number>(location.y)};

                                     Nan::Call(*event_callback, countof(argv), argv);
                                     return e;
                                   }];
}

Mouse::~Mouse() { Stop(); }

void Mouse::Initialize(Nan::ADDON_REGISTER_FUNCTION_ARGS_TYPE exports) {
  Nan::HandleScope scope;

  Local<FunctionTemplate> tpl = Nan::New<FunctionTemplate>(Mouse::New);
  tpl->SetClassName(Nan::New<String>("Mouse").ToLocalChecked());
  tpl->InstanceTemplate()->SetInternalFieldCount(1);

  Nan::SetPrototypeMethod(tpl, "destroy", Mouse::Destroy);
  Nan::SetPrototypeMethod(tpl, "ref", Mouse::AddRef);
  Nan::SetPrototypeMethod(tpl, "unref", Mouse::RemoveRef);

  auto func = Nan::GetFunction(tpl).ToLocalChecked();
  Mouse::constructor.Reset(func);
  Nan::Set(
      exports,
      Nan::New<String>("Mouse").ToLocalChecked(),
      func);
}

void Mouse::Stop() {
  if (stopped) {
    return;
  }
  stopped = true;

  [NSEvent removeMonitor:(id)event_monitor];
  event_monitor = nullptr;
}

NAN_METHOD(Mouse::New) {
  Nan::Callback *callback = new Nan::Callback(info[0].As<Function>());

  Mouse *obj = new Mouse(callback);
  obj->Wrap(info.This());
  obj->Ref();

  info.GetReturnValue().Set(info.This());
}

NAN_METHOD(Mouse::Destroy) {
  Mouse *mouse = Nan::ObjectWrap::Unwrap<Mouse>(info.Holder());
  mouse->Stop();
  mouse->Unref();

  info.GetReturnValue().SetUndefined();
}

NAN_METHOD(Mouse::AddRef) { info.GetReturnValue().SetUndefined(); }

NAN_METHOD(Mouse::RemoveRef) { info.GetReturnValue().SetUndefined(); }
