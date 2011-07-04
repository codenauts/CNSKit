@interface UIImageView (CNSURLHandling) {
}

- (void)setImageURL:(NSString *)url;
- (NSString *)imageURL;
- (void)setImageURL:(NSString *)newUrl completionBlock:(void (^)(UIImage *loadedImage))block;

- (void)setDefaultImage:(NSString *)imageName;
- (NSString *)defaultImage;

- (void)setLoadingImage:(NSString *)imageName;
- (NSString *)loadingImage;

@end
