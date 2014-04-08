//
//  Camera.h
//  StagingArea
//
//  Created by Robby on 4/6/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#ifndef __Stage__Camera__
#define __Stage__Camera__

#include <iostream>
#include <OpenGLES/ES1/gl.h>

class Camera{
public:
    void frameShot();  // call at beginning of every draw function
    
    GLfloat position[3] = {0.0f, 0.0f, 0.0f};  // x,y,z of camera
    GLfloat focus[3] = {0.0f, 0.0f, 1.0f};     // x,y,z of point of attention
    GLfloat up[3] = {0.0f, 1.0f, 0.0f};        // tilt/roll around point of attention
    bool tiltLock;      // turn off up[3] (always above +y camera)
    
    void setFieldOfView(float fieldOfView);
    void setAspectRatio(float aspectRatio);
    void setFrame(int width, int height);

    float Z_NEAR = 0.1f;
    float Z_FAR = 10.0f;
    
    //////////////////////////
    // custom animation scripts
    void (*animation)() = NULL;

    void animationUpAndDownAndAround();
    
private:
    GLfloat m[16];
    float _width, _height;
    float _fieldOfView;
    float _aspectRatio = 1.0;
    // building matrix
    float forward[3], side[3], above[3];
    void rebuildProjectionMatrix();
    void logOrientation();
    
};

#endif /* defined(__Stage__Camera__) */
