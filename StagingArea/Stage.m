#import <OpenGLES/ES1/gl.h>
#import <CoreMotion/CoreMotion.h>
#import "Stage.h"
#include "StageCommon.h"

#import "Animation.h"
#import "Hotspot.h"
#import "OBJ.h"
#import "Camera.h"
#include "lights.c"


// ROOMS and SCREENS
#import "NavigationScreen.h"
#import "SquareRoom.h"

#define camHomeDistance 2.25
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

// # SCENES
typedef enum{
    scene1,
    scene2,
    scene3,
    scene4,
    scene5
} Scene;

// define all possible kinds of transitions:
typedef enum{
    animationNone,
    animationOrthoToPerspective,
    animationPerspectiveToOrtho,
    animationInsideToPerspective,
    animationPerspectiveToInside
} AnimationState;

// give names to all hotspots:
typedef enum{
    hotspotBackArrow,
    hotspotForwardArrow,
    hotspotControls
} HotspotID;


@interface Stage (){
    NSDate      *start;
    float       screenColor[4];
    
    Scene               scene;
    AnimationState      cameraAnimationState;
    
    
    // CUSTOMIZE BELOW
    
    // ANIMATIONS
    Animation           *animationTransition;  // triggered by navbar forward/back
    Animation           *animationNewGeodesic; // triggered by loading new geodesic

    // ROOMS   (3D ENVIRONMENTS)
    SquareRoom          *squareRoom;

    // SCREENS (ORTHOGRAPHIC LAYERS)
    NavigationScreen    *navScreen;

    // CAMERAS
    Camera              *camera;
    float               camDistance;
    GLKQuaternion       orientation, quaternionFrontFacing;

    // OBJECTS
    OBJ *obj;
    
    // ANIMATION TRIGGERS
    NSArray *hotspots;  // don't overlap hotspots, or re-write touch handling code
}

@end

@implementation Stage

- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)context{
    self = [super initWithFrame:frame context:context];
    if (self) {
        self.frame = frame;
        NSLog(@"DID THIS WORK?: %f, %f, %f, %f",self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
//        _frame = frame;
        [self setup];
    }
    return self;
}

-(void) setup{
    [self customizeOpenGL];
    
    squareRoom = [[SquareRoom alloc] init];
    
    navScreen = [[NavigationScreen alloc] initWithFrame:self.frame];
    [self addSubview:navScreen.view];     // add a screen's view or its UI elements won't show
    [navScreen setScene:(int*)&scene];
    
    // camera
    camDistance = camHomeDistance;
//    set_up(&camera, 0, 1, 0);
//    set_position(&camera, 0, 0, camDistance);
//    set_focus(&camera, 0, 0, 0);
//    build_projection_matrix(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height, 58);  // 60
    
    GLKMatrix4 m = GLKMatrix4MakeLookAt(camDistance, 0, 0, 0, 0, 0, 0, 1, 0);
    quaternionFrontFacing = GLKQuaternionMakeWithMatrix4(m);

    float arrowWidth = self.frame.size.width*.125;
    hotspots = @[ [Hotspot hotspotWithID:hotspotBackArrow Bounds:CGRectMake(5, 5, arrowWidth, arrowWidth)],
                  [Hotspot hotspotWithID:hotspotForwardArrow Bounds:CGRectMake(self.frame.size.width-(arrowWidth+5), 5, arrowWidth, arrowWidth)],
                  [Hotspot hotspotWithID:hotspotControls Bounds:CGRectMake(0, self.frame.size.height-arrowWidth*2.5, self.frame.size.width, arrowWidth*2.5)]];
    
    start = [NSDate date];
}

-(void) customizeOpenGL{
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

-(void)draw{
    [self animationHandler];
    
    glClearColor(screenColor[0], screenColor[1], screenColor[2], screenColor[3]);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // lighting independent of rotation
//    rainbow(screenColor, &one_f, &one_f);
    
    glPushMatrix();
    if(_orientToDevice){
        _orientationMatrix = GLKMatrix4MakeLookAt(camDistance*_deviceAttitude[2], camDistance*_deviceAttitude[6], camDistance*(-_deviceAttitude[10]), 0.0f, 0.0f, 0.0f, _deviceAttitude[1], _deviceAttitude[5], -_deviceAttitude[9]);
//        set_position(&camera, camDistance*_deviceAttitude[2], camDistance*_deviceAttitude[6], camDistance*(-_deviceAttitude[10]));
//        set_up(&camera, _deviceAttitude[1], _deviceAttitude[5], -_deviceAttitude[9]);
    }
//    frame_shot(&camera);
    
    _orientationMatrix.m32 = -camDistance;
    glMultMatrixf(_orientationMatrix.m);
    
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, zeroColor);
    
    // lighting rotates with orientation
    rainbow(screenColor, &one_f, &one_f);
    
    
    if(obj)
        [obj draw];
    
    if(squareRoom)
        [squareRoom draw];
    
    if(animationNewGeodesic != nil){
        float scale = 1.0-[animationNewGeodesic scale];  // this is getting called twice,
        rainbow(screenColor, &one_f, &scale);
        // draw more
    }
    
    if(navScreen)
        [navScreen draw];
    
    glPopMatrix();
}

-(void) changeScene:(Scene)newScene{
//    reset_lighting();
    [navScreen hideElements];
    
    if(newScene == scene1){
        [[navScreen octahedronLabel] setHidden:NO];
        [[navScreen icosahedronLabel] setHidden:NO];
        [[navScreen titleLabel] setText:@"SCENE 1"];
    }else if (newScene == scene2){
        for (int i = 0; i < [[navScreen numberLabels] count]; i++)
            [[[navScreen numberLabels] objectAtIndex:i] setHidden:NO];
        [[navScreen titleLabel] setText:@"SCENE 2"];
    }else if (newScene == scene3){
        [[navScreen titleLabel] setText:@"SCENE 3"];
    }else if (newScene == scene4){
        [[navScreen titleLabel] setText:@"SCENE 4"];
    }else if (newScene == scene5){
        [[navScreen titleLabel] setText:@"SCENE 5"];
    }
    scene = newScene;
}

-(void) changeCameraAnimationState:(AnimationState) newState{
    if(newState == animationNone){
        if(cameraAnimationState == animationOrthoToPerspective){
            _orientToDevice = true;
        }
    }
    else if(newState == animationPerspectiveToOrtho){
        GLKMatrix4 m = GLKMatrix4Make(_orientationMatrix.m[0], _orientationMatrix.m[1], _orientationMatrix.m[2], _orientationMatrix.m[3],
                                      _orientationMatrix.m[4], _orientationMatrix.m[5], _orientationMatrix.m[6], _orientationMatrix.m[7],
                                      _orientationMatrix.m[8], _orientationMatrix.m[9], _orientationMatrix.m[10],_orientationMatrix.m[11],
                                      _orientationMatrix.m[12],_orientationMatrix.m[13],_orientationMatrix.m[14],_orientationMatrix.m[15]);
        orientation = GLKQuaternionMakeWithMatrix4(m);
        _orientToDevice = false;
    }
    cameraAnimationState = newState;
}

-(void)animationDidStop:(Animation *)a{
    if([a isEqual:animationNewGeodesic]){
        
    }
    if([a isEqual:animationTransition]){
        if(cameraAnimationState == animationOrthoToPerspective) // this stuff could go into the function pointer function
            _orientToDevice = true;
        cameraAnimationState = animationNone;
    }
}

-(void) animationHandler{
    _elapsedSeconds = -[start timeIntervalSinceNow];

    // list all animations
    if(animationNewGeodesic)
        animationNewGeodesic = [animationNewGeodesic step];
    if(animationTransition)
        animationTransition = [animationTransition step];
    
    
    
    if(animationTransition != nil){

        float frame = [animationTransition scale];
        if(frame > 1) frame = 1.0;
        if(cameraAnimationState == animationPerspectiveToOrtho){
            GLKQuaternion q = GLKQuaternionSlerp(orientation, quaternionFrontFacing, powf(frame,2));
            _orientationMatrix = GLKMatrix4MakeWithQuaternion(q);
            [self dollyZoomFlat:powf(frame,3)];
        }
        if(cameraAnimationState == animationOrthoToPerspective){
            GLKMatrix4 m = GLKMatrix4MakeLookAt(camDistance*_deviceAttitude[2], camDistance*_deviceAttitude[6], camDistance*(-_deviceAttitude[10]), 0.0f, 0.0f, 0.0f, _deviceAttitude[1], _deviceAttitude[5], -_deviceAttitude[9]);
            GLKQuaternion mtoq = GLKQuaternionMakeWithMatrix4(m);
            GLKQuaternion q = GLKQuaternionSlerp(quaternionFrontFacing, mtoq, powf(frame,2));
            _orientationMatrix = GLKMatrix4MakeWithQuaternion(q);
            [self dollyZoomFlat:powf(1-frame,3)];
        }
        if(cameraAnimationState == animationPerspectiveToInside){
            [self flyToCenter:frame];
        }
        if(cameraAnimationState == animationInsideToPerspective){
            [self flyToCenter:1-frame];
        }
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"ARE TOUCHES WORKING?:");
    if(self.userInteractionEnabled){
        NSLog(@"YES, yes they are");
        for(UITouch *touch in touches){
            for(Hotspot *spot in hotspots){
                if(CGRectContainsPoint([spot bounds], [touch locationInView:self])){
                    // customize response to each touch area
                    if([spot ID] == hotspotBackArrow) { }
                    if([spot ID] == hotspotForwardArrow) { }
                    if([spot ID] == hotspotControls) { }
                    break;
                }
            }
        }
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.userInteractionEnabled){
        for(UITouch *touch in touches){
            for(Hotspot *spot in hotspots){
                if(CGRectContainsPoint([spot bounds], [touch locationInView:self])){
                    // customize response to each touch area
                    if([spot ID] == hotspotBackArrow) { }
                    if([spot ID] == hotspotForwardArrow) { }
                    if([spot ID] == hotspotControls && scene == scene2){
                        float freq = ([touch locationInView:self].x-(self.frame.size.width)/12.*1.5) / ((self.frame.size.width)/12.);
                        if(freq < 0) freq = 0;
                        if(freq > 8) freq = 8;
                        [navScreen setRadioBarPosition:freq];
                    }
                    break;
                }
            }
        }
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.userInteractionEnabled){
        for(UITouch *touch in touches){
            for(Hotspot *spot in hotspots){
                if(CGRectContainsPoint([spot bounds], [touch locationInView:self])){
                    // customize response to each touch area
                    if([spot ID] == hotspotBackArrow && scene > scene1){
                        animationTransition = [[Animation alloc] initOnStage:self Start:_elapsedSeconds End:_elapsedSeconds+.2];
                        if(scene == scene2)
                            [self changeCameraAnimationState:animationOrthoToPerspective];
                        if(scene == scene5)
                            [self changeCameraAnimationState:animationInsideToPerspective];
                        if (scene-1 == scene3)
                            [self changeCameraAnimationState:animationPerspectiveToOrtho];
                        if (scene-1 == scene5)
                            [self changeCameraAnimationState:animationPerspectiveToInside];
                        [self changeScene:scene-1];
                    }
                    else if([spot ID] == hotspotForwardArrow && scene < scene5){
                        if(scene == scene3)
                            [self changeCameraAnimationState:animationOrthoToPerspective];
                        if(scene == scene5)
                            [self changeCameraAnimationState:animationInsideToPerspective];
                        if (scene+1 == scene2)
                            [self changeCameraAnimationState:animationPerspectiveToOrtho];
                        if (scene+1 == scene5)
                            [self changeCameraAnimationState:animationPerspectiveToInside];
                        animationTransition = [[Animation alloc] initOnStage:self Start:_elapsedSeconds End:_elapsedSeconds+.2];
                        [self changeScene:scene+1];
                    }
                    else if([spot ID] == hotspotControls){
                        if(scene == scene1){
                            if([touch locationInView:self].x < self.frame.size.width*.5){
                                
                            }
                            else if([touch locationInView:self].x > self.frame.size.width*.5){
                                
                            }
                        }
                        if(scene == scene2){
                            int freq = ([touch locationInView:self].x-(self.frame.size.width)/12.*1.5) / ((self.frame.size.width)/12.);
                            if(freq < 0) freq = 0;
                            if(freq > 8) freq = 8;
                            [navScreen setRadioBarPosition:freq];
                            animationNewGeodesic = [[Animation alloc] initOnStage:self Start:_elapsedSeconds End:_elapsedSeconds+.5];
                        }
                    }
                    break;
                }
            }
        }
    }
}

-(void) flyToCenter:(float)frame{
    if(frame > 1) frame = 1;
    if(frame < 0) frame = 0;
    camDistance = .1+camHomeDistance*(1-frame);
    if(camDistance < 1.0) glCullFace(GL_BACK);
    else glCullFace(GL_FRONT);
}

-(void) dollyZoomFlat:(float)frame{

    float width = 1;
    float distance = camHomeDistance + frame * 50;
    camDistance = distance;
    float fov = 5*atan( width /(2*distance) );
    fov = fov / 3.1415926 * 180.0;
//    NSLog(@"FOV %f",fov);
//    build_projection_matrix(self.frame.origin.x, self.frame.origin.y, (1+IS_RETINA)*self.frame.size.width, (1+IS_RETINA)*self.frame.size.height, fov);
}

-(void) tearDownGL{
    //unload shapes
//    glDeleteBuffers(1, &_vertexBuffer);
//    glDeleteVertexArraysOES(1, &_vertexArray);
}

@end