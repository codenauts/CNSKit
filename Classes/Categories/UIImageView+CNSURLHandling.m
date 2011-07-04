#import "UIImageView+CNSURLHandling.h"
#import "NSString+CNSStringAdditions.h"
#import <objc/runtime.h>

@implementation UIImageView (CNSURLHandling)

static char imageURLKey;
static char imageDefaultKey;
static char imageLoadingKey;

+ (dispatch_queue_t)imageLoadingQueue {
  static dispatch_queue_t queue = nil;
  
  if (!(queue)) {
    queue = dispatch_queue_create("de.codenauts.cns.imagequeue", NULL);
  }
  return queue;
}

- (void)setImageURL:(NSString *)newUrl {
  [self setImageURL:newUrl completionBlock:nil];
}

- (void)setImageURL:(NSString *)newUrl completionBlock:(void (^)(UIImage *loadedImage))completionBlock {
  NSString *url = (NSString *)objc_getAssociatedObject(self, &imageURLKey);
  
  if (!([newUrl length] > 0)) {
    objc_setAssociatedObject(self, &imageURLKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.image = [UIImage imageNamed:[self defaultImage]];
  }
  else if (!([url isEqualToString:newUrl])) {
    self.image = [UIImage imageNamed:[self loadingImage]];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    [self addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    objc_setAssociatedObject(self, &imageURLKey, newUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_queue_t image_queue = [UIImageView imageLoadingQueue];
    
    dispatch_async(image_queue, ^{
      
      UIImage *image = nil;
      
      NSString *filePath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@",[newUrl MD5Hash]];
      NSURL *imageURL = [NSURL URLWithString:newUrl];
      
      if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil]) {
        image = [[UIImage alloc] initWithContentsOfFile:filePath];
      }
      else if ([[imageURL scheme] isEqualToString:@"file"]) {
        NSData* imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
        image = [[UIImage alloc] initWithData:imageData];
        [imageData release];
      }
      else {
        NSData* imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
        image = [[UIImage alloc] initWithData:imageData];
        [imageData writeToFile:filePath atomically:YES];
        [imageData release];
      }
      
      dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.imageURL isEqualToString:newUrl]) {
          self.image = image;
          if (completionBlock) {
            completionBlock(image);
          }
        }
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        [activityIndicator release];
      });
      
      [image release];
    });
  }
}

- (NSString *)imageURL {
  return (NSString *)objc_getAssociatedObject(self, &imageURLKey);
}

- (void)setDefaultImage:(NSString *)imageName {
  objc_setAssociatedObject(self, &imageDefaultKey, imageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)defaultImage {
  return (NSString *)objc_getAssociatedObject(self, &imageDefaultKey);
}

- (void)setLoadingImage:(NSString *)imageName {
  objc_setAssociatedObject(self, &imageLoadingKey, imageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)loadingImage {
  return (NSString *)objc_getAssociatedObject(self, &imageLoadingKey);
}

@end
