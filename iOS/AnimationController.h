#import <Foundation/Foundation.h>

// designed to operate only one transition at a time

typedef enum : unsigned short {
    Scene1,
    Scene2
//  list Scenes here
//  ..
//  ..
} Scene;

@protocol AnimationDelegate <NSObject>

@required
// tween increments from 0.0 to 1.0 if transition has duration
-(void) transitionFrom:(unsigned short)fromScene To:(unsigned short)toScene Tween:(float)t;
// called only once
-(void) beginTransitionFrom:(unsigned short)fromScene To:(unsigned short)toScene;
-(void) endTransitionFrom:(unsigned short)fromScene To:(unsigned short)toScene;

@end

@interface AnimationController : NSObject

@property id <AnimationDelegate> delegate;

@property (readonly) Scene scene;
@property (readonly) BOOL sceneInTransition;

-(void) gotoScene:(unsigned short)scene;
-(void) gotoScene:(unsigned short)scene withDuration:(NSTimeInterval)interval;

@end
