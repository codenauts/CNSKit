@interface UIImageView (CNSURLHandling) {
}

+ (void)cns_imageBufferEnabled:(BOOL)enabled;
+ (void)cns_cleanupImageBuffer;

- (void)setImageURL:(NSString *)url;
- (NSString *)imageURL;
- (void)setImageURL:(NSString *)newUrl completionBlock:(void (^)(UIImage *loadedImage))block;

- (void)setDefaultImage:(NSString *)imageName;
- (NSString *)defaultImage;

- (void)setLoadingImage:(NSString *)imageName;
- (NSString *)loadingImage;

@end
