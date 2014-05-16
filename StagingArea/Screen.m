//
//  Screen.m
//  StagingArea
//
//  Created by Robby on 5/6/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import "Screen.h"
#import <OpenGLES/ES1/gl.h>

@interface Screen (){
    float _aspectRatio;
    float width, height;
}

@end

@implementation Screen

-(id) initWithFrame:(CGRect)frame{
    self = [super init];
    if(self){
        _frame = frame;
        [self setup];
    }
    return self;
}

-(id) init{
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}

-(void) setup{
    width = _frame.size.width;
    height = _frame.size.height;
    _aspectRatio = _frame.size.width/_frame.size.height;
}

typedef struct GLColor GLcolor;
struct GLColor{
    float color[4];
};

-(void) draw{
    [self enterOrthographic];
    
    // BEGIN CUSTOMIZE DRAW
    
    static GLfloat whiteColor[4] = {1.0f, 1.0f, 1.0f, 1.0f};
    static GLfloat clearColor[4] = {1.0f, 1.0f, 1.0f, 0.3f};
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, whiteColor);
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);

    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, whiteColor);

    // a line loop, 2 pixel wide square sides, 10.0 line width makes a crosshair
//    glLineWidth(10.0);
//    glTranslatef(height*.5, width*.5, 0.0);
//    glScalef(1/_aspectRatio, _aspectRatio, 1);
    
    glLineWidth(10.0);
//    [self drawRectOutline:CGRectMake(width*.5, height*.5, width*.99, height*.99)];
    
    glLineWidth(0.0);
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, clearColor);
    [self drawRect:CGRectMake(width*.5, height*.5, 20, 20)];
    
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, whiteColor);
    [self drawRect:CGRectMake(width*.5, 50, width, 100)];
    
    [self drawRect:CGRectMake(50, height-50, 100, 100)];
    [self drawRect:CGRectMake(width-50, height-50, 100, 100)];
    

    // END CUSTOMIZE DRAW
    
    [self exitOrthographic];
}

-(void) drawRect:(CGRect)rect{
    static const GLfloat _unit_square[] = {
        -0.5f, 0.5f,
        0.5f, 0.5f,
        -0.5f, -0.5f,
        0.5f, -0.5f
    };
    glPushMatrix();
    glTranslatef(rect.origin.x, rect.origin.y, 0.0);
    glScalef(rect.size.width, rect.size.height, 1.0);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, _unit_square);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableClientState(GL_VERTEX_ARRAY);
    glPopMatrix();
}

-(void) drawRectOutline:(CGRect)rect{
    static const GLfloat _unit_square_outline[] = {
        -0.5f, 0.5f,
        0.5f, 0.5f,
        0.5f, -0.5f,
        -0.5f, -0.5f
    };
    glPushMatrix();
    glTranslatef(rect.origin.x, rect.origin.y, 0.0);
    glScalef(rect.size.width, rect.size.height, 1.0);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, _unit_square_outline);
    glDrawArrays(GL_LINE_LOOP, 0, 4);
    glDisableClientState(GL_VERTEX_ARRAY);
    glPopMatrix();
}

-(void)drawHexagons{
    static const GLfloat hexFan[] = {
        0.0f, 0.0f,
        -.5f, -.8660254f,
        -1.0f, 0.0f,
        -.5f, .8660254f,
        .5f, .8660254f,
        1.0f, 0.0f,
        .5f, -.8660254f,
        -.5f, -.8660254f
    };
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, hexFan);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 8);
    glDisableClientState(GL_VERTEX_ARRAY);
}

-(void) drawHexLines{
    static const GLfloat hexVertices[] = {
        -.5f, -.8660254f, -1.0f, 0.0f, -.5f, .8660254f,
        .5f, .8660254f,    1.0f, 0.0f,  .5f, -.8660254f
    };
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, hexVertices);
    glDrawArrays(GL_LINE_LOOP, 0, 6);
    glDisableClientState(GL_VERTEX_ARRAY);
}

-(void)enterOrthographic{
    glDisable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrthof(0, width, 0, height, -5, 1);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
}

-(void)exitOrthographic{
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

@end
