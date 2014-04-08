//
//  Stage.h
//  StagingArea
//
//  Created by Robby Kraft on 3/29/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stage : NSObject

-(id) init; // init Stage after EAGL context has been setup
-(void) draw;
-(void) loadRandomGeodesic;

@end
