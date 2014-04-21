WMSOnGoogleMap
==============

Sample for using WMS sources in Google Maps SDK for iOS.
There are two ways of doing this:
"Method B": use GMSTileURLConstructor

           // -- method B. WMS tile layer with GMSTileURLConstructor
              GMSTileURLConstructor urls = ^(NSUInteger x, NSUInteger y, NSUInteger z) {
                  BBox bbox = bboxFromXYZ(x,y,z);
                  NSString *urlKN = [NSString stringWithFormat:@"Your WMS url&BBOX=%f,%f,%f,%f",
                                     bbox.left, bbox.bottom,bbox.right,bbox.top];
                  
                  return [NSURL URLWithString:urlKN];
              };
              
              
"Method A": use custom TileLayer derived from  GMSTileLayer

 1. your derived class from GMSTileLayer (here WMSTileLayer.h)
 will receive tiel request 
            - (void)requestTileForX:(NSUInteger)x   y:(NSUInteger)y    zoom:(NSUInteger)z    receiver:(id<GMSTileReceiver>)receiver
            
 2. WMSTileLayer first checks for cached tile and if found calls :
              [self drawTileAtX:x y:y zoom:z Url:urlStr Receiver:receiver] ;
 
 3. if tile is not cached we download it, save it to the file system (using MD5 hash) and call to draw it
              [data  writeToFile: filePath  atomically:YES];
              [self drawTileAtX:x y: y zoom: z Url:urlStr Receiver:receiver] ;
              
 4. drawTileAtX is very simple:
            -(void) drawTileAtX: (NSUInteger) x   y:(NSUInteger)y    zoom:(NSUInteger)zoom   Url:(NSString*) url Receiver: (id<GMSTileReceiver>) receiver {
                 UIImage             *image   = TileLoad(url,NO); // loads tile from file system
                 [receiver receiveTileWithX:x y:y zoom:zoom image:image]; // pass it to the SDK API
            }
    
}
both ways are used in this sample.
