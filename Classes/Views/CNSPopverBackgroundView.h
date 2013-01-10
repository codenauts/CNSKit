//
//  LKPopOverView.h
//  Lernkurve
//
//  Created by Benjamin Reimold on 09.01.13.
//  Copyright (c) 2013 Codenauts UG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNSPopverBackgroundView : UIPopoverBackgroundView 

@property (nonatomic, assign) CGFloat arrowOffset;
@property (nonatomic, assign) UIPopoverArrowDirection arrowDirection;

+(void)borderImage:(UIImage *)borderImage arrowImage:(UIImage *)arrowImage;

@end
