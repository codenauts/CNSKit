@class CNSApplicationDelegate;

@interface CNSBaseViewController : UIViewController {
}

+ (CNS_APPLICATION_DELEGATE_CLASS *)applicationDelegate;

- (void)releaseView;

@end
