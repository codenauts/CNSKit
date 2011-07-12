#import "CNSClassUtils.h"
#import <objc/runtime.h>

@implementation CNSClassUtils

+ (void)checkDelegate:(id)delegate performSelector:(SEL)selector withObject:(id)object {
  if ([delegate respondsToSelector:selector]) {
    [delegate performSelector:selector withObject:object];
  }
}

+ (void)checkDelegate:(id)delegate performSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2 {
  if ([delegate respondsToSelector:selector]) {
    [delegate performSelector:selector withObject:object1 withObject:object2];
  }
}

+ (void)swizzleSelector:(SEL)originalSelector ofClass:(Class)klass withSelector:(SEL)newSelector {
  Method originalMethod = class_getInstanceMethod(klass, originalSelector);
  Method newMethod = class_getInstanceMethod(klass, newSelector);
  
  if (class_addMethod(klass, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
    class_replaceMethod(klass, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
  }
  else {
    method_exchangeImplementations(originalMethod, newMethod);
  }  
}

@end
