//
//  GMTileOverlay.h
//  SpatialReaderCore
//
//  Created by Stanislav Sumbera on 7/2/13.
//
//
#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>
#import <netdb.h>
#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>



@interface WMSTileLayer : GMSTileLayer
  
@property (nonatomic, strong) NSString * url;

- (id)initWithUrl:(NSString*)urlArg;

@end


#define TILE_SIZE 256
#define MINIMUM_ZOOM 0
#define MAXIMUM_ZOOM 25

#define TILE_CACHE   @"TILE_CACHE"

// range of map or layer
typedef struct BBox{
    double  left;
    double  bottom;
    double  right;
    double  top;
} BBox;


//----------------------------------------------------------------------------
NS_INLINE double xOfColumn(NSInteger column,NSInteger zoom){
    
	double x = column;
	double z = zoom;
    
	return x / pow(2.0, z) * 360.0 - 180;
}
//----------------------------------------------------------------------------

NS_INLINE  double yOfRow(NSInteger row,NSInteger zoom){
    
	double y = row;
	double z = zoom;
    
	double n = M_PI - 2.0 * M_PI * y / pow(2.0, z);
	return 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)));
}


//-------------------------------------------------------------------------------------
NS_INLINE  double MercatorXofLongitude(double lon){
    return  lon * 20037508.34 / 180;
}

//------------------------------------------------------------
NS_INLINE double MercatorYofLatitude(double lat){
    double y = log(tan((90 + lat) * M_PI / 360)) / (M_PI / 180);
    y = y * 20037508.34 / 180;
    
    return y;
}
//------------------------------------------------------------
NS_INLINE BBox bboxFromXYZ(NSUInteger x, NSUInteger y, NSUInteger z){
    // BBOX in spherical mercator
    BBox bbox = {
        .left   = MercatorXofLongitude(xOfColumn(x,z)),  //minX
        .right  = MercatorXofLongitude(xOfColumn(x+1,z)), //maxX
        .bottom = MercatorYofLatitude(yOfRow(y+1,z)), //minY
        .top    = MercatorYofLatitude(yOfRow(y,z))      //maxY
    };
    return bbox;
}
//--------------------------------------------------------------------------------------------------
NS_INLINE NSString* md5Hash (NSString* stringData) {
    NSData *data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

//--------------------------------------------------------------------------------------------------
NS_INLINE BOOL createPathIfNecessary (NSString* path) {
    BOOL succeeded = YES;
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        succeeded = [fm createDirectoryAtPath: path
                  withIntermediateDirectories: YES
                                   attributes: nil
                                        error: nil];
    }
    
    return succeeded;
}

//--------------------------------------------------------------------------------------------------
NS_INLINE  NSString*  cachePathWithName(NSString* name) {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [paths objectAtIndex:0];
    NSString* cachePath = [cachesPath stringByAppendingPathComponent:name];
    
    createPathIfNecessary(cachesPath);
    createPathIfNecessary(cachePath);
    
    return cachePath;
}


//--------------------------------------------------------------------------------------------------

NS_INLINE  NSString*  getFilePathForURL( NSString* url,NSString* folderName){
    return [cachePathWithName(folderName) stringByAppendingPathComponent:md5Hash(url)];
}


//------------------------------------------------------------
NS_INLINE void cacheUrlToLocalFolder(NSString* url,NSData* data, NSString* folderName){
    NSString *localFilePath =   getFilePathForURL(url,folderName);
    [data writeToFile: localFilePath atomically:YES];
    
}

//-------------------------------------------------------------------------------------
NS_INLINE UIImage* TileLoad(NSString* url,BOOL online){
    UIImage  *image = nil;
    
    NSString * filePath = getFilePathForURL(url,TILE_CACHE);
    // -- file is cached ?
    if ([[NSFileManager defaultManager] fileExistsAtPath: filePath]){
        image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
    }
    else if (online){
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString: url]];
        [imgData writeToFile: filePath atomically:YES];
        image =[UIImage imageWithData:imgData];
    }
    return image;
}
