//
//  WMSTileOverlay.m
//
//
//  Created by Stanislav Sumbera on 7/2/13.
//
//

#import "WMSTileLayer.h"


@implementation WMSTileLayer{
     id<GMSTileReceiver>  _tileReceiver;
  
}

//------------------------------------------------------------
- (id)initWithUrl:(NSString*)urlArg{
    
    if ((self = [self init])) {
        self.url  = urlArg;
    }
    return self;
}


//------------------------------------------------------------
- (NSString*) getUrlX: (NSUInteger) x Y:(NSUInteger)y Z:(NSUInteger) z{
 
    BBox bbox = bboxFromXYZ(x,y,z);
    NSString *resolvedUrl = [NSString stringWithFormat:@"%@&BBOX=%f,%f,%f,%f",
                       self.url,
                       bbox.left, bbox.bottom,bbox.right,bbox.top];
    return resolvedUrl;
    
}

//-------------------------------------------------------------------------------------------------------------------------
-(void) drawTileAtX: (NSUInteger) x   y:(NSUInteger)y    zoom:(NSUInteger)zoom   Url:(NSString*) url Receiver: (id<GMSTileReceiver>) receiver {
     UIImage             *image   = TileLoad(url,NO);
     [receiver receiveTileWithX:x y:y zoom:zoom image:image];
    
}
//-------------------------------------------------------------------------------------------------------------------------
- (void)requestTileForX:(NSUInteger)x   y:(NSUInteger)y    zoom:(NSUInteger)z    receiver:(id<GMSTileReceiver>)receiver{
    
    
    NSString    *urlStr =  [self getUrlX:x Y:y Z:z];
    
    if (!urlStr){
        NSLog(@"Url evaluation error \n");
        [receiver receiveTileWithX:x y:y zoom:z image:kGMSTileLayerNoTile];
        return;
    }
    NSString *filePath = getFilePathForURL(urlStr,TILE_CACHE);
    // -- check if tile is cached
    if ([[NSFileManager defaultManager] fileExistsAtPath: filePath]){
        [self drawTileAtX:x y:y zoom:z Url:urlStr Receiver:receiver] ;

        return;
    }
    else {
    
        NSURL *URL = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
                                   if (error) {
                                      NSLog(@"Error downloading tile ! \n");
                                      [receiver receiveTileWithX:x y:y zoom:z  image:kGMSTileLayerNoTile];
                                       
                                   }
                                   else {
                                     [data  writeToFile: filePath  atomically:YES];
                                     [self drawTileAtX:x y: y zoom: z Url:urlStr Receiver:receiver] ;
                                   }
                                   
                               }];
        
         }
    
}

@end
