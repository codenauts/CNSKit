//
//  LKPopOverView.m
//  Lernkurve
//
//  Created by Benjamin Reimold on 09.01.13.
//  Copyright (c) 2013 Codenauts UG. All rights reserved.
//

#import "CNSPopverBackgroundView.h"

#define CONTENT_INSET 10.0
#define CAP_INSET 25.0

@implementation CNSPopverBackgroundView

@synthesize arrowDirection;
@synthesize arrowOffset;

static float arrowBase = 22.0;
static float arrowHeight = 22.0;

static UIImageView *borderImageView;
static UIImageView *arrowView;

//this class was implemented using http://blog.teamtreehouse.com/customizing-the-design-of-uipopovercontroller as input


+ (void)borderImage:(UIImage *)borderImage arrowImage:(UIImage *)arrowImage {
  borderImageView = [[UIImageView alloc] initWithImage:[borderImage resizableImageWithCapInsets:UIEdgeInsetsMake(CAP_INSET, CAP_INSET, CAP_INSET, CAP_INSET)]];
  arrowView = [[UIImageView alloc] initWithImage:[arrowImage resizableImageWithCapInsets:UIEdgeInsetsMake(CAP_INSET, CAP_INSET, CAP_INSET, CAP_INSET)]];
  arrowHeight = arrowView.bounds.size.height;
  arrowBase = arrowView.bounds.size.width;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:borderImageView];
        [self addSubview:arrowView];      
    }
  
    return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat height = self.frame.size.height;
  CGFloat width = self.frame.size.width;
  CGFloat left = 0.0;
  CGFloat top = 0.0;
  CGFloat coordinate = 0.0;
  CGAffineTransform _rotation = CGAffineTransformIdentity;
  
  switch (self.arrowDirection) {
    case UIPopoverArrowDirectionUp:
      top += arrowHeight;
      height -= arrowHeight;
      coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (arrowBase/2);
      arrowView.frame = CGRectMake(coordinate, 0, arrowBase, arrowHeight);
      break;
    case UIPopoverArrowDirectionDown:
      height -= arrowHeight;
      coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (arrowBase/2);
      arrowView.frame = CGRectMake(coordinate, height, arrowBase, arrowHeight);
      _rotation = CGAffineTransformMakeRotation( M_PI );
      break;
    case UIPopoverArrowDirectionLeft:
      left += arrowBase;
      width -= arrowBase;
      coordinate = ((self.frame.size.height / 2) + self.arrowOffset) - (arrowHeight/2);
      arrowView.frame = CGRectMake(0, coordinate, arrowBase, arrowHeight);
      _rotation = CGAffineTransformMakeRotation( -M_PI_2 );
      break;
    case UIPopoverArrowDirectionRight:
      width -= arrowBase;
      coordinate = ((self.frame.size.height / 2) + self.arrowOffset)- (arrowHeight/2);
      arrowView.frame = CGRectMake(width, coordinate, arrowBase, arrowHeight);
      _rotation = CGAffineTransformMakeRotation( M_PI_2 );
      break;
    case UIPopoverArrowDirectionAny:
      break;
    case UIPopoverArrowDirectionUnknown:
      break;
  }
  
  borderImageView.frame =  CGRectMake(left, top, width, height);
  [arrowView setTransform:_rotation];
  
}


+ (UIEdgeInsets)contentViewInsets{
  return UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET);
}

+ (CGFloat)arrowHeight{
  return arrowHeight;
}

+ (CGFloat)arrowBase{
  return arrowHeight;
}


@end
