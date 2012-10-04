//
//  WebServiceClient.h
//  Window&DoorMeasurementNew
//
//  Created by Adam Heinz on 9/25/12.
//
//

#import <Foundation/Foundation.h>

@interface VTWebServiceClient : NSObject {
    NSString *sessionName;
    NSURL *serverURL;
}
@property(nonatomic,retain) NSString *sessionName;

-(id)init;
-(id)initWithURL:(NSURL *)url;

-(NSDictionary *)doCreate:(NSString *)elementType elementDict:(NSDictionary *)elementDict;
-(NSDictionary *)doGet:(NSDictionary *)getDict;
-(NSDictionary *)doLogin:(NSString *)userName accessKey:(NSString *)accessKey;
-(NSDictionary *)doPost:(NSDictionary *)postDict;
-(NSDictionary *)doPostFile:(NSDictionary *)postDict fileData:(NSData *)fileData;
-(NSDictionary *)doQuery:(NSString *)query;

@end
