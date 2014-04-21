//
//  WMSController.m
//  WMSOnGoogleMap
//
//  Created by Stanislav Sumbera on 20/04/14.
//  Copyright (c) 2014 sumbera. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "WMSTileLayer.h"
#import "WMSController.h"





@interface WMSController ()

@end

@implementation WMSController

//---------------------------------------------------------
+(void) initialize{
    
    [GMSServices provideAPIKey:kAPIKey];
    
      
    
}
//--------------------------------------------------------------------------
- (void)loadView{
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:50.07
                                                            longitude:14.43
                                                                 zoom:18];
    
    CGRect initFrame = CGRectMake(0, 0, 380, 460);

    GMSMapView         *mapView  = [GMSMapView  mapWithFrame:initFrame camera:camera];
 
    self.view = mapView;
   
    // -- method A : WMS tile layer with full control of the cache
    WMSTileLayer *wmsTileLayer  = [[WMSTileLayer alloc] initWithUrl:@"http://services.cuzk.cz/wms/wms.asp?&LAYERS=prehledka_kraju-linie,KN&REQUEST=GetMap&SERVICE=WMS&VERSION=1.3.0&FORMAT=image/png&TRANSPARENT=TRUE&STYLES=&CRS=EPSG:900913&WIDTH=256&HEIGHT=256"];
    wmsTileLayer.map = mapView;

   
    // -- method B. WMS tile layer with GMSTileURLConstructor
    GMSTileURLConstructor urls = ^(NSUInteger x, NSUInteger y, NSUInteger z) {
        BBox bbox = bboxFromXYZ(x,y,z);
        NSString *urlKN = [NSString stringWithFormat:@"http://services.cuzk.cz/wms/wms.asp?&LAYERS=DEF_BUDOVY&REQUEST=GetMap&SERVICE=WMS&VERSION=1.3.0&FORMAT=image/png&TRANSPARENT=TRUE&STYLES=&CRS=EPSG:900913&WIDTH=256&HEIGHT=256&&BBOX=%f,%f,%f,%f",
                           bbox.left, bbox.bottom,bbox.right,bbox.top];
        
        return [NSURL URLWithString:urlKN];
    };
    GMSTileLayer *tileLayer = [GMSURLTileLayer tileLayerWithURLConstructor:urls];
    tileLayer.map = mapView;
 
}

//---------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    self.navigationItem.title=@"WMS on Google Maps SDK";
    
    
}

@end
