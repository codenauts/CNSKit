#import "UIImageView+CNSURLHandling.h"
#import "NSString+CNSStringAdditions.h"
#import <objc/runtime.h>

@implementation UIImageView (CNSURLHandling)

static char imageURLKey;
static char imageDefaultKey;
static char imageLoadingKey;

static BOOL cns_imageBufferEnabled;
static NSCache *cns_imageBuffer;
static NSMutableDictionary *cns_domainFilter;
static NSString *cns_cachePath;
static NSCache *cns_md5HashCache;

+ (void)cns_imageBufferEnabled:(BOOL)enabled {
  cns_imageBufferEnabled = enabled;
}

+ (BOOL)cns_isImageBufferEnabeld {
  return cns_imageBufferEnabled;
}

+ (NSCache *)cns_imageBuffer {
  if (!cns_imageBuffer) {
    cns_imageBuffer = [[NSCache alloc] init];
  }
  return cns_imageBuffer;
}

+ (NSCache *)cns_md5HashCache {
  if (!cns_md5HashCache) {
    cns_md5HashCache = [[NSCache alloc] init];
  }
  return cns_md5HashCache;
}

+ (void)cns_cleanupImageBuffer {
  [[UIImageView cns_imageBuffer] removeAllObjects];
}

+ (void)cns_cachePath:(NSString *)path {
  [path retain];
  [cns_cachePath release];
  cns_cachePath = path;
  [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (NSString *)cns_cachePath {
  if (!cns_cachePath) {
    cns_cachePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"cns_imagebuffer"] retain];
  }
  return cns_cachePath;
}

+ (NSMutableDictionary *)cns_domainFilter {
  if (!cns_domainFilter) {
    cns_domainFilter = [[NSMutableDictionary alloc] init];
  }
  return cns_domainFilter;
}

+ (void)cns_addDomainFilterWithRegEx:(NSString *)regex replaceWith:(NSString *)url {
  [[self cns_domainFilter] setValue:url forKey:regex];
}

- (NSString *)cns_MD5HashForURL:(NSString *)url {
  NSString *md5Hash = [[UIImageView cns_md5HashCache] objectForKey:url];
  if (!md5Hash) {
    md5Hash = [url MD5Hash];
    [[UIImageView cns_md5HashCache] setObject:md5Hash forKey:url];
  }
  return md5Hash;
}

- (void)cns_loadCachedImageWithURL:(NSString *)url completionBlock:(void (^)(UIImage *loadedImage))completionBlock {
  if ([UIImageView cns_isImageBufferEnabeld]) {
    NSString *md5Hash = [self cns_MD5HashForURL:url];
    UIImage *cachedImage = [[UIImageView cns_imageBuffer] objectForKey:md5Hash];
    if (cachedImage) {
      self.image = cachedImage;
    }
    if (completionBlock) {
      completionBlock(cachedImage);
    }
  }
}

- (void)cns_loadImageFromURL:(NSString *)url completionBlock:(void (^)(UIImage *loadedImage))completionBlock {
  self.image = [UIImage imageNamed:[self loadingImage]];
  UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  activityIndicator.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
  [self addSubview:activityIndicator];
  [activityIndicator startAnimating];
  [activityIndicator release];
  NSString *md5Hash = [self cns_MD5HashForURL:url];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    UIImage *image = nil;
    NSString *filePath = [[UIImageView cns_cachePath] stringByAppendingPathComponent:md5Hash];
    NSURL *imageURL = [NSURL URLWithString:url];
    
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
    
    dispatch_sync(dispatch_get_main_queue(), ^{
      if ([self.imageURL isEqualToString:url]) {
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
    });
    
    [image release];
  });
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
    
    NSMutableString *hashableURL = [[newUrl mutableCopy] autorelease];
    NSMutableDictionary *domainFilter = [[self class] cns_domainFilter];
    for (NSString *key in domainFilter) {
      [hashableURL replaceOccurrencesOfString:key withString:[cns_domainFilter valueForKey:key] options:NSRegularExpressionSearch range:NSMakeRange(0, [hashableURL length])];
    }
    
    objc_setAssociatedObject(self, &imageURLKey, hashableURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self cns_loadCachedImageWithURL:hashableURL completionBlock:completionBlock];
    
    if (!self.image) {
      [self cns_loadImageFromURL:hashableURL completionBlock:completionBlock];
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
