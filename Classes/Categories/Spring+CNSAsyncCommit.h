#import "Spring.h"

@interface Spring (CNSAsyncCommit)

+ (dispatch_queue_t)cns_springQueue;

- (void)cns_commitAsync:(NSMutableDictionary *)dictionary;

@end
