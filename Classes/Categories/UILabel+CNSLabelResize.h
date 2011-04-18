@interface UILabel (CNSLabelResize)

- (void)moveLabelBelowLabel:(UILabel *)above offset:(CGFloat)offset;
- (void)resizeLabelToFitText;

@end
