#import "Spring+CNSAsyncCommit.h"

@implementation Spring (CNSAsyncCommit)

+ (dispatch_queue_t)cns_springQueue {
  static dispatch_queue_t queue = nil;
  
  if (!(queue)) {
    queue = dispatch_queue_create("de.codenauts.cns.springqueue", NULL);
  }
  return queue;
}

- (void)cns_commitAsync:(NSMutableDictionary *)dictionary {
  dispatch_async([Spring cns_springQueue], ^{
    [self commit:dictionary];
  });
}

@end
