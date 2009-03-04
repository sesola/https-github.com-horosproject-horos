/*=========================================================================
  Program:   OsiriX

  Copyright (c) OsiriX Team
  All rights reserved.
  Distributed under GNU - GPL
  
  See http://www.osirix-viewer.com/copyright.html for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
=========================================================================*/

#import "MPRController.h"


@implementation MPRController

- (DCMPix*) emptyPix: (DCMPix*) originalPix width: (long) w height: (long) h
{
	long size = sizeof( float) * w * h;
	float *imagePtr = malloc( size);
	DCMPix *emptyPix = [[[DCMPix alloc] initwithdata: imagePtr :32 :w :h :[originalPix pixelSpacingX] :[originalPix pixelSpacingY] :[originalPix originX] :[originalPix originY] :[originalPix originZ]] autorelease];
	free( imagePtr);
	
	return emptyPix;
}

- (id)initWithDCMPixList:(NSMutableArray*)pix filesList:(NSMutableArray*)files volumeData:(NSData*)volume viewerController:(ViewerController*)viewer fusedViewerController:(ViewerController*)fusedViewer;
{
	if(![super initWithWindowNibName:@"MPR"]) return nil;
	
	DCMPix *originalPix = [pix lastObject];
	
	pixList[0] = pix;
	filesList[0] = files;
	volumeData[0] = volume;
	
	[[self window] setWindowController: self];
	
	DCMPix *emptyPix = [self emptyPix: originalPix width: 100 height: 100];
	[mprView1 setDCMPixList:  [NSMutableArray arrayWithObject: emptyPix] filesList: [NSArray arrayWithObject: [files lastObject]] volumeData: [NSData dataWithBytes: [emptyPix fImage] length: [emptyPix pheight] * [emptyPix pwidth] * sizeof( float)] roiList:nil firstImage:0 type:'i' reset:YES];
	[mprView1 setFlippedData: [[viewer imageView] flippedData]];
	
	emptyPix = [self emptyPix: originalPix width: 100 height: 100];
	[mprView2 setDCMPixList:  [NSMutableArray arrayWithObject: emptyPix] filesList: [NSArray arrayWithObject: [files lastObject]] volumeData: [NSData dataWithBytes: [emptyPix fImage] length: [emptyPix pheight] * [emptyPix pwidth] * sizeof( float)] roiList:nil firstImage:0 type:'i' reset:YES];
	[mprView2 setFlippedData: [[viewer imageView] flippedData]];

	emptyPix = [self emptyPix: originalPix width: 100 height: 100];
	[mprView3 setDCMPixList:  [NSMutableArray arrayWithObject: emptyPix] filesList: [NSArray arrayWithObject: [files lastObject]] volumeData: [NSData dataWithBytes: [emptyPix fImage] length: [emptyPix pheight] * [emptyPix pwidth] * sizeof( float)] roiList:nil firstImage:0 type:'i' reset:YES];
	[mprView3 setFlippedData: [[viewer imageView] flippedData]];
	
	vrController = [[VRController alloc] initWithPix:pix :files :volume :fusedViewer :viewer style:@"noNib" mode:@"MIP"];
	[vrController load3DState];
	
	hiddenVRController = [[VRController alloc] initWithPix:pix :files :volume :fusedViewer :viewer style:@"noNib" mode:@"MIP"];
	[hiddenVRController load3DState];
	
	[[hiddenVRController window] setLevel: 0];	//NSNormalWindowLevel
	[[hiddenVRController window] orderBack: self];
//	[[hiddenVRController window] orderOut: self];
	
	hiddenVRView = [hiddenVRController view];
	[hiddenVRView setClipRangeActivated: YES];
	[hiddenVRView resetImage: self];
	[hiddenVRView setLOD: 2.0];
	
	[mprView1 setVRView: hiddenVRView];
	[mprView1 updateView];
	[mprView1 setWLWW: [originalPix wl] :[originalPix ww]];
	
	[mprView2 setVRView: hiddenVRView];
	[mprView2 updateView];
	[mprView2 setWLWW: [originalPix wl] :[originalPix ww]];
	
	[mprView3 setVRView: hiddenVRView];
	[mprView3 updateView];
	[mprView3 setWLWW: [originalPix wl] :[originalPix ww]];
	
	return self;
}

- (void) dealloc
{
	[[hiddenVRController window] orderOut: self];
	[vrController release];
	[hiddenVRController release];
	[super dealloc];
}

//- (void)windowWillLoad
//{
//	[hiddenVRView setFrame:containerFor3DView.frame];
//}

- (BOOL) is2DViewer
{
	return NO;
}

- (NSMutableArray*) pixList
{
	return pixList[ curMovieIndex];
}

@end
