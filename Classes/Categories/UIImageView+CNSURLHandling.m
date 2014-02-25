#import "UIImageView+CNSURLHandling.h"
#import "NSString+CNSStringAdditions.h"
#import "UIImage+CNSPreloading.h"
#import <objc/runtime.h>

@implementation UIImageView (CNSURLHandling)

static char cns_imageURLKey;
static char cns_imageDefaultKey;
static char cns_imageLoadingKey;
static char cns_hashableImageURLKey;
static char cns_requestOperationKey;

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

- (NSBlockOperation *)cns_imageRequestOperation {
  return (NSBlockOperation *)objc_getAssociatedObject(self, &cns_requestOperationKey);
}

- (void)cns_setImageRequestOperation:(NSBlockOperation *)imageRequestOperation {
  objc_setAssociatedObject(self, &cns_requestOperationKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)cns_imageRequestOperationQueue {
  static NSOperationQueue *imageRequestOperationQueue = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    imageRequestOperationQueue = [[NSOperationQueue alloc] init];
    [imageRequestOperationQueue setMaxConcurrentOperationCount:10];
  });
  
  return imageRequestOperationQueue;
}

+ (dispatch_semaphore_t)cns_imageBufferWriteSemaphore {
  static dispatch_semaphore_t semaphore;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    semaphore = dispatch_semaphore_create(1);
  });
  return semaphore;
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask ,YES );
    NSString *cachesDirectory = [paths objectAtIndex:0];
    cns_cachePath = [[cachesDirectory stringByAppendingPathComponent:@"cns_imagebuffer"] retain];
    [[NSFileManager defaultManager] createDirectoryAtPath:cns_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
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

- (void)cns_cancelImageRequestOperation {
  [[self cns_imageRequestOperation] cancel];
  [self cns_setImageRequestOperation:nil];
}

- (NSString *)cns_MD5HashForURL:(NSString *)url {
  NSString *md5Hash = [[UIImageView cns_md5HashCache] objectForKey:url];
  if (!md5Hash) {
    md5Hash = [url MD5Hash];
    [[UIImageView cns_md5HashCache] setObject:md5Hash forKey:url];
  }
  return md5Hash;
}

- (void)cns_loadCachedImageWithCompletionBlock:(void (^)(UIImage *loadedImage))completionBlock {
  if ([UIImageView cns_isImageBufferEnabeld]) {
    NSString *md5Hash = [self cns_MD5HashForURL:self.hashableImageURL];
    UIImage *cachedImage = [[UIImageView cns_imageBuffer] objectForKey:md5Hash];
    if (cachedImage) {
      self.image = cachedImage;
      if (completionBlock) {
        completionBlock(cachedImage);
      }
    }
  }
}

- (void)cns_loadImageWithCompletionBlock:(void (^)(UIImage *loadedImage))completionBlock processingBlock:(UIImage * (^)(UIImage * loadedImage))processingBlock {
  [self cns_cancelImageRequestOperation];
  
  self.image = [UIImage imageNamed:[self loadingImage]];
  __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  activityIndicator.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
  [self addSubview:activityIndicator];
  [activityIndicator startAnimating];
  [activityIndicator release];
  NSString *md5Hash = [self cns_MD5HashForURL:self.hashableImageURL];
  NSString *url = self.imageURL;
  
  
  NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
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
      dispatch_semaphore_wait([UIImageView cns_imageBufferWriteSemaphore], DISPATCH_TIME_FOREVER);
      [imageData writeToFile:filePath atomically:YES];
      dispatch_semaphore_signal([UIImageView cns_imageBufferWriteSemaphore]);
      [imageData release];
    }
    
    UIImage *preLoadedImage = nil;
    if (processingBlock) {
      UIImage *processedImage = processingBlock(image);
      preLoadedImage = [processedImage cns_preloadedImage];
    }
    else {
      preLoadedImage = [image cns_preloadedImage];
    }
    [image release];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([UIImageView cns_isImageBufferEnabeld] && (preLoadedImage)) {
        if ((preLoadedImage.size.width * preLoadedImage.size.height) <= 500000) {
          [[UIImageView cns_imageBuffer] setObject:preLoadedImage forKey:md5Hash];
        }
      }
      if ([self.imageURL isEqualToString:url]) {
        self.image = preLoadedImage;
        if (completionBlock) {
          completionBlock(preLoadedImage);
        }
      }
      [activityIndicator stopAnimating];
      [activityIndicator removeFromSuperview];
    });
  }];
  [[[self class] cns_imageRequestOperationQueue] addOperation:operation];
  [self cns_setImageRequestOperation:operation];
}

- (void)cns_loadImageWithCompletionBlock:(void (^)(UIImage *loadedImage))completionBlock {
  [self cns_loadImageWithCompletionBlock:completionBlock processingBlock:nil];
}

- (void)setImageURL:(NSString *)newUrl {
  [self setImageURL:newUrl processingBlock:nil completionBlock:nil];
}

- (void)setImageURL:(NSString *)newUrl completionBlock:(void (^)(UIImage *loadedImage))completionBlock {
  [self setImageURL:newUrl processingBlock:nil completionBlock:completionBlock];
}

- (void)setImageURL:(NSString *)newUrl processingBlock:(UIImage * (^)(UIImage * loadedImage))processingBlock completionBlock:(void (^)(UIImage *loadedImage))completionBlock { 
  NSString *url = (NSString *)objc_getAssociatedObject(self, &cns_imageURLKey);
  
  if (!([newUrl length] > 0)) {
    objc_setAssociatedObject(self, &cns_imageURLKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.image = [UIImage imageNamed:[self defaultImage]];
  }
  else if (!(self.image) || !([url isEqualToString:newUrl])) {
    self.image = nil;
    
    NSMutableString *hashableURL = [[newUrl mutableCopy] autorelease];
    NSMutableDictionary *domainFilter = [[self class] cns_domainFilter];
    for (NSString *key in domainFilter) {
      [hashableURL replaceOccurrencesOfString:key withString:[cns_domainFilter valueForKey:key] options:NSRegularExpressionSearch range:NSMakeRange(0, [hashableURL length])];
    }
    
    objc_setAssociatedObject(self, &cns_imageURLKey, newUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cns_hashableImageURLKey, hashableURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self cns_loadCachedImageWithCompletionBlock:completionBlock];
    
    if (!self.image) {
      [self cns_loadImageWithCompletionBlock:completionBlock processingBlock:processingBlock];
    }    
  }
  else {
    if (completionBlock) {
      completionBlock(self.image);
    }
  }
}

- (NSString *)imageURL {
  return (NSString *)objc_getAssociatedObject(self, &cns_imageURLKey);
}

- (NSString *)hashableImageURL {
  return (NSString *)objc_getAssociatedObject(self, &cns_hashableImageURLKey);
}

- (void)setDefaultImage:(NSString *)imageName {
  objc_setAssociatedObject(self, &cns_imageDefaultKey, imageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)defaultImage {
  return (NSString *)objc_getAssociatedObject(self, &cns_imageDefaultKey);
}

- (void)setLoadingImage:(NSString *)imageName {
  objc_setAssociatedObject(self, &cns_imageLoadingKey, imageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)loadingImage {
  return (NSString *)objc_getAssociatedObject(self, &cns_imageLoadingKey);
}


@end
