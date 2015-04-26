//
//  TFCameraOverlayView.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 28/01/15.
//
//

#import "TFCameraOverlayView.h"

@implementation TFCameraOverlayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id) init
{
    if (self = [super init]) {
    }
    return self;
}


-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    
    // Both frames are defined in the same coordinate system
    CGRect biggerRect = self.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    
    [maskPath moveToPoint:self.center];
    [maskPath addArcWithCenter:self.center
                        radius:150.f
                    startAngle:0
                      endAngle:M_PI * 2
                     clockwise:YES];
    
    [maskWithHole setPath:[maskPath CGPath]];
    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [maskWithHole setFillColor:[[UIColor colorWithRed:1 green:1 blue:1 alpha:.8f] CGColor]];
    [self.layer addSublayer:maskWithHole];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 0)];
    [infoLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
    [infoLabel setNumberOfLines:0];
    [infoLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [infoLabel setText:@"PLease make sure you take a selfie in bright light and face resides within the circle"];
    [infoLabel sizeToFit];
    infoLabel.center = CGPointMake(self.center.x, infoLabel.center.y);
    [self addSubview:infoLabel];
}

@end
