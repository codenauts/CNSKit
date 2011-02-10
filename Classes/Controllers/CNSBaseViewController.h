@class CNS_APPLICATION_DELEGATE_CLASS;

@interface CNSBaseViewController : UIViewController {
}

+ (CNS_APPLICATION_DELEGATE_CLASS *)applicationDelegate;

- (void)releaseView;

@end
