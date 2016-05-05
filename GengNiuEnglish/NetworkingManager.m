//
//  NetworkingManager.m
//  GengNiuEnglish
//
//  Created by luzegeng on 15/12/22.
//  Copyright © 2015年 luzegeng. All rights reserved.
//

#import "NetworkingManager.h"
#import "AFNetworking.h"
#import "CommonMethod.h"



//#define DEBUGFOLDER @"DEBUGFOLDER"
//#define OFFICIALFOLDER @"OFFICIALFOLDER"

static const NSString *URLForGradeList=@"/courseware/grade_list_query/";
static const NSString *URLForTextList=@"/courseware/text_list_query/";
static const NSString *URLForTextDetai=@"/courseware/text_detail_query/";
static const NSString *URLForRegist=@"/student/register/";
static const NSString *URLForLogin=@"/student/login/";
static const NSString *URLForGetSalt=@"/student/get_salt/";
static const NSString *URLForCheckAvail=@"/student/phone/check_avail/";
static const NSString *URLForActionCode=@"/courseware/get_app_status/";
static const NSString *URLForBindPhone=@"/student/phone/bind/";
static const NSString *URLForUserInfo=@"/student/get_userinfo/";
static const NSString *URLForSetUserInfo=@"/student/set_userinfo/";
static const NSString *URLForCloudURL=@"/student/get_file_url/";
static const NSString *URLForCheckNetwork=@"http://www.baidu.com";
static const NSString *URLForResetPassword=@"/student/change_passwd/";
static const NSString *URLForUpdateState=@"/studystatus/text_state_update/";
static const NSString *URLForWeixinBind=@"/weixin/check_avail/";
static const NSString *URLForUploadVoice=@"/studystatus/upload_repeat/";


@implementation NetworkingManager


+(NSURLSessionTask*)httpRequest:(RequestType)type url:(RequestURL)url parameters:(NSDictionary*)parameters progress:(nullable void (^)(NSProgress *progress))progressBlock success:(nullable void (^)( NSURLSessionTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionTask * _Nullable task, NSError * _Nullable error))failure completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler
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
            return [NetworkingManager httpDownload:link parameters:parameters progress:progressBlock completionHandler:completionHandler];
        case RTUpload:
            return [NetworkingManager httpUpload:[parameters objectForKey:@"uploadURL"] parameters:parameters progress:progressBlock completionHandler:completionHandler];
        default:
            return nil;
    }
}
+(const NSString *)requestURL:(RequestURL)url
{
    switch (url)
    {
        case RUText_list:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForTextList];
        case RUText_detail:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForTextDetai];
        case RUGrade_list:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForGradeList];
        case RURegist:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForRegist];
        case RULogin:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForLogin];
        case RUGetSalt:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForGetSalt];
        case RUCheckAvail:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForCheckAvail];
        case RUActionCode:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForActionCode];
        case RUBindPhone:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForBindPhone];
        case RUUserInfo:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForUserInfo];
        case RUSetUserInfo:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForSetUserInfo];
        case RUGetCloudURL:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForCloudURL];
        case RUCheckNetwork:
            return URLForCheckNetwork;
        case RUResetPassword:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForResetPassword];
        case RUUpdateState:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForUpdateState];
        case RUWeixinBind:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForWeixinBind];
        case RUUploadVoice:
            return [NSString stringWithFormat:@"%@%@",MONEWDOMAIN,URLForUploadVoice];
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
    manager.requestSerializer.timeoutInterval =30;
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
    manager.requestSerializer.timeoutInterval =30;
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
    //delete file if exist
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *fileName=[CommonMethod getPath:[[[[url componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"?"] objectAtIndex:0]];
    NSString *file=[fileName stringByReplacingOccurrencesOfString:@"\%2F" withString:@"_"];
    if ([fileManager fileExistsAtPath:file])
    {
        BOOL success=[fileManager removeItemAtPath:file error:nil];
        if (!success)
        {
            NSLog(@"delete exist download file failed");
        }
    }
    
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
+(NSURLSessionDataTask *)httpUpload:(NSString *)url parameters:(NSDictionary *)parameters progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, id responseObject, NSError * _Nullable error))completionHandler
{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    NSData *fileData = [NSData dataWithContentsOfFile:[parameters objectForKey:@"filePath"]];
    
    
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:fileData];
    
    NSURLSessionDataTask *uploadTask=[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
            NSLog(@"log for response:%@",response);
            //alert upload fail
        } else {
            completionHandler(response,responseObject,error);
            NSLog(@"Success: %@ %@", response, responseObject);
        }
    }];

    [uploadTask resume];
    return uploadTask;
}
@end
