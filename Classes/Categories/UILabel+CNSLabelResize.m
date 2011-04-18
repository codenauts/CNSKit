#import "UILabel+CNSLabelResize.h"

@implementation UILabel (CNSLabelResize)

- (void)resizeLabelToFitText {
  CGSize size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.bounds.size.width, 1e4) lineBreakMode:UILineBreakModeWordWrap];
  CGRect frame = self.frame;
  frame.size.height = (self.text ? size.height : 0);
  self.frame = frame;  
}

- (void)moveLabelBelowLabel:(UILabel *)above offset:(CGFloat)offset {
  CGRect frame = self.frame;
  frame.origin.y = above.frame.origin.y + above.frame.size.height + offset;
  self.frame = frame;
}


@end
