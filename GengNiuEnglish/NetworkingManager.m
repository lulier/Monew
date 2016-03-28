//
//  NetworkingManager.m
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/22.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import "NetworkingManager.h"
#import "AFNetworking.h"

#define domain @"http://120.25.103.72:8002"
//#define domain @"http://english.mo-new.com"

static const NSString *URLForGradeList=@"/courseware/grade_list_query/";
static const NSString *URLForTextList=@"/courseware/text_list_query/";
static const NSString *URLForTextDetai=@"/courseware/text_detail_query/";
static const NSString *URLForRegist=@"/student/register/";
static const NSString *URLForLogin=@"/student/login/";
static const NSString *URLForGetSalt=@"/student/get_salt/";
static const NSString *URLForCheckAvail=@"/student/phone/check_avail/";
static const NSString *URLForActionCode=@"/courseware/get_app_status/";

@implementation NetworkingManager

+(NSURLSessionTask*)httpRequest:(RequestType)type url:(RequestURL)url parameters:(NSDictionary*)parameters progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock success:(nullable void (^)( NSURLSessionTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionTask * _Nullable task, NSError * _Nullable error))failure completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler
{
    NSString *link=[NetworkingManager requestURL:url];
    if (!link) {
        link=[parameters objectForKey:@"url"];
    }
    switch (type) {
        case RTGet:
            return [NetworkingManager httpGet:link parameters:parameters success:success failure:failure];
            break;
        case RTPost:
            return [NetworkingManager httpPost:link parameters:parameters success:success failure:failure];
        case RTDownload:
            return [NetworkingManager httpDownload:link parameters:parameters progress:downloadProgressBlock completionHandler:completionHandler];
        case RTUpload:
            return nil;
        default:
            return nil;
    }
}
+(const NSString *)requestURL:(RequestURL)url
{
    switch (url)
    {
        case RUText_list:
            return [NSString stringWithFormat:@"%@%@",domain,URLForTextList];
        case RUText_detail:
            return [NSString stringWithFormat:@"%@%@",domain,URLForTextDetai];
        case RUGrade_list:
            return [NSString stringWithFormat:@"%@%@",domain,URLForGradeList];
        case RURegist:
            return [NSString stringWithFormat:@"%@%@",domain,URLForRegist];
        case RULogin:
            return [NSString stringWithFormat:@"%@%@",domain,URLForLogin];
        case RUGetSalt:
            return [NSString stringWithFormat:@"%@%@",domain,URLForGetSalt];
        case RUCheckAvail:
            return [NSString stringWithFormat:@"%@%@",domain,URLForCheckAvail];
        case RUActionCode:
            return [NSString stringWithFormat:@"%@%@",domain,URLForActionCode];
        case RUCustom:
            return nil;
        default:
            return nil;
    }
}
+(NSURLSessionDataTask *)httpGet:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError *))failure
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task=[manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
        //        NSLog(@"log for the response data%@",responseObject);
        
        success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error){
        NSLog(@"your request has failed%@",error);
        failure(task,error);
    }];
    return task;
}
+(NSURLSessionDataTask *)httpPost:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError *))failure
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task=[manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
        //        NSLog(@"log for the response data%@",responseObject);
        
        success(task,responseObject);
        NSLog(@"log for response:%@",responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error){
        NSLog(@"your request has failed%@",error);
        failure(task,error);
    }];
    return task;
}
+(NSURLSessionDownloadTask *)httpDownload:(NSString *)url parameters:(NSDictionary *)parameters progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:downloadProgressBlock destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
    {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:completionHandler];
    [downloadTask resume];
    return downloadTask;
}
+(void)downloadImage:(NSURL *)downloadURL block:(void (^)(UIImage *))block
{
    NSString *cacheKey=[[SDWebImageManager sharedManager] cacheKeyForURL:downloadURL];
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:cacheKey done:
     ^(UIImage *image, SDImageCacheType cacheType) {
         if (image!=nil)
         {
             dispatch_async(dispatch_get_main_queue(),^{
                 block(image);
             });
         }
         else
         {
             SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
             [downloader downloadImageWithURL:downloadURL
                                      options:0
                                     progress:^(NSInteger receivedSize, NSInteger expectedSize){
                                         // progression tracking code
                                     }
                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                        if (image && finished)
                                        {
                                            // do something with image
                                            dispatch_async(dispatch_get_main_queue(),^{
                                                block(image);
                                                NSString *cacheKey=[[SDWebImageManager sharedManager] cacheKeyForURL:downloadURL];
                                                [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey];
                                            });
                                            
                                        }
                                        else
                                        {
                                            dispatch_async(dispatch_get_main_queue(),^{
                                                block([UIImage imageNamed:@"profile-image-placeholder"]);
                                            });
                                        }
                                    }];
         }
     }];
}
@end
