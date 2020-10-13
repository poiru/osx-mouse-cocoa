#include "mouse.h"

using namespace v8;

NAN_MODULE_INIT(Initialize) {
  Mouse::Initialize(target);
}

NODE_MODULE(addon, Initialize)
