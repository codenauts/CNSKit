@interface UIImageView (CNSURLHandling) {
}

+ (void)cns_addDomainFilterWithRegEx:(NSString *)regex replaceWith:(NSString *)url;
+ (void)cns_imageBufferEnabled:(BOOL)enabled;
+ (void)cns_cleanupImageBuffer;
+ (void)cns_cachePath:(NSString *)path;
+ (NSString *)cns_cachePath;

- (void)setImageURL:(NSString *)url;
- (NSString *)imageURL;
- (NSString *)hashableImageURL;
- (void)setImageURL:(NSString *)newUrl completionBlock:(void (^)(UIImage *loadedImage))block;
- (void)setImageURL:(NSString *)newUrl processingBlock:(UIImage * (^)(UIImage * loadedImage))processingBlock completionBlock:(void (^)(UIImage *loadedImage))completionBlock;

- (void)setDefaultImage:(NSString *)imageName;
- (NSString *)defaultImage;

- (void)setLoadingImage:(NSString *)imageName;
- (NSString *)loadingImage;

@end
