//
//  Animation.h
//  StagingArea
//
//  Created by Robby on 6/2/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stage.h"

@interface Animation : NSObject

@property Stage *delegate;

@property NSTimeInterval startTime;
@property NSTimeInterval endTime;
@property NSTimeInterval duration;

-(float) scale;  // 0.0 to 1.0, start to end

-(id)initOnStage:(Stage*)stage Start:(NSTimeInterval)start End:(NSTimeInterval)end;
-(id)initOnStage:(Stage*)stage Start:(NSTimeInterval)start Duration:(NSTimeInterval)duration;

-(void) animateFrame;

@end
