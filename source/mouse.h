#ifndef _MOUSE_H
#define _MOUSE_H

#include <nan.h>

class Mouse : public Nan::ObjectWrap {
public:
  static void Initialize(Nan::ADDON_REGISTER_FUNCTION_ARGS_TYPE exports);
  static Nan::Persistent<v8::Function> constructor;
  void Run();
  void Stop();

private:
  Nan::Callback *event_callback;
  bool stopped;
  void *event_monitor;

  explicit Mouse(Nan::Callback *);
  ~Mouse();

  static NAN_METHOD(New);
  static NAN_METHOD(Destroy);
  static NAN_METHOD(AddRef);
  static NAN_METHOD(RemoveRef);
};

#endif
