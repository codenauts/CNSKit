#import "UIImageView+CNSURLHandling.h"
#import "NSString+CNSStringAdditions.h"
#import <objc/runtime.h>

@implementation UIImageView (CNSURLHandling)

static char imageURLKey;
static char imageDefaultKey;
static char imageLoadingKey;

static BOOL cns_imageBufferEnabled;
static NSMutableDictionary *cns_imageBuffer;


+ (void)cns_imageBufferEnabled:(BOOL)enabled {
  cns_imageBufferEnabled = enabled;
}

+ (BOOL)cns_isImageBufferEnabeld {
  return cns_imageBufferEnabled;
}

+ (NSMutableDictionary *)cns_imageBuffer {
  if (!cns_imageBuffer) {
    cns_imageBuffer = [[NSMutableDictionary alloc] init];
  }
  return cns_imageBuffer;
}

+ (void)cns_cleanupImageBuffer {
  [[UIImageView cns_imageBuffer] removeAllObjects];
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
    self.image = nil;

    NSString *md5Hash = [newUrl MD5Hash];
    if ([UIImageView cns_isImageBufferEnabeld]) {
      UIImage *cachedImage = [[UIImageView cns_imageBuffer] valueForKey:md5Hash];
      if (cachedImage) {
        self.image = cachedImage;
      }
      if (completionBlock) {
        completionBlock(cachedImage);
      }
    }
    
    if (!self.image) {
      self.image = [UIImage imageNamed:[self loadingImage]];
      UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
      activityIndicator.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
      [self addSubview:activityIndicator];
      [activityIndicator startAnimating];
      
      objc_setAssociatedObject(self, &imageURLKey, newUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *image = nil;
        
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@",md5Hash];
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
            if ([UIImageView cns_isImageBufferEnabeld] && (image)) {
              if ((image.size.width * image.size.height) <= 100000) {
                [[UIImageView cns_imageBuffer] setObject:image forKey:md5Hash];
              }
            }
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
