@interface UIImageView (CNSURLHandling) {
}

- (void)setImageURL:(NSString *)url;
- (NSString *)imageURL;

- (void)setDefaultImage:(NSString *)imageName;
- (NSString *)defaultImage;

- (void)setLoadingImage:(NSString *)imageName;
- (NSString *)loadingImage;

@end
