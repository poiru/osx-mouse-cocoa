#include "mouse.h"

using namespace v8;

void Initialize(Handle<Object> exports) { Mouse::Initialize(exports); }

NODE_MODULE(addon, Initialize)
