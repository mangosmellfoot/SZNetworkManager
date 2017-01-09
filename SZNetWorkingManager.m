//
//  SZNetWorkingManager.m
//  SZAFNetworking
//
//  Created by MapABCios on 16/5/21.
//  Copyright © 2016年 MapABCios. All rights reserved.
//

#define NSLOG_YES

#import "SZNetWorkingManager.h"
#import "Reachability.h"


@implementation SZSessionModel

@end

@interface SZNetWorkingManager ()

@property (nonatomic,strong)AFHTTPSessionManager * manager;
@property (nonatomic,strong)NSMutableDictionary * dicTask;

@end

@implementation SZNetWorkingManager

#pragma mark - Life Cycle

/**
 *  单例获取
 *
 *  @return SZNetWorkingManager对象
 */
+ (instancetype)shareSZNetWorkingManager{
    
    static SZNetWorkingManager * netWorkingManager;
    
    static dispatch_once_t onceToken;
    _dispatch_once(&onceToken, ^{
        netWorkingManager = [[SZNetWorkingManager alloc] init];
    });
    return netWorkingManager;
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        _manager = [AFHTTPSessionManager manager];
        _dicTask = [[NSMutableDictionary alloc] init];
        _manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    return self;
}

//判断网络连接
- (BOOL)isExistenceNetwork{
    
    BOOL isExistenceNetwork;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.easymobi.cn"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=FALSE;
            self.netStatus = @"无网络";
            break;
        case ReachableViaWWAN:
            isExistenceNetwork=TRUE;
            self.netStatus = @"蜂窝数据网";
            break;
        case ReachableViaWiFi:
            isExistenceNetwork=TRUE;
            self.netStatus = @"WiFi网络";
            break;
        default:
            isExistenceNetwork=TRUE;
            self.netStatus = @"未知网络";
            break;
    }
    
#ifdef NSLOG_SHOW
    NSLog(@"当前网络状态为:%@",self.netStatus);
#endif
    
    if (!isExistenceNetwork) {
        [self.delegate netWorkingManagerStatusExistenceNetwork];
    }
    
    return isExistenceNetwork;
}

- (void)AFNetworkStatus{
    
    __weak SZNetWorkingManager * weakSelf = self;
    
    //1.创建网络监测者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*枚举里面四个状态  分别对应 未知 无网络 数据 WiFi
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,      未知
     AFNetworkReachabilityStatusNotReachable     = 0,       无网络
     AFNetworkReachabilityStatusReachableViaWWAN = 1,       蜂窝数据网络
     AFNetworkReachabilityStatusReachableViaWiFi = 2,       WiFi
     };
     */
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        
        //这里是监测到网络改变的block  可以写成switch方便
        //在里面可以随便写事件
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                weakSelf.netStatus = @"未知网络状态";
            }break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                weakSelf.netStatus = @"无网络";
            }break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                weakSelf.netStatus = @"蜂窝数据网";
            }break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                weakSelf.netStatus = @"WiFi网络";
            }break;
            default:
                break;
        }
    }] ;
#ifdef NSLOG_SHOW
    NSLog(@"当前网络状态为:%@,%s",weakSelf.netStatus,__FUNCTION__);
#endif
    
}

#pragma mark - 判断是否存在

- (SZSessionModel *)isTaskForNetWorkExistWithURLStr:(NSString *)urlStr andParameters:(id)parameters{
    
    if(parameters)  //是否有参数
    {
        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"%p",parameters]];
    }
    if ([_dicTask objectForKey:urlStr])    //是否正在下载-否
    {
#ifdef NSLOG_SHOW
        NSLog(@"链接:<%@>已在网络获取中，请勿重复",urlStr);
#endif
        [self.delegate netWorkingManagerRepeatAccessNetwork];
    }
    else
    {
        if(![self isExistenceNetwork])      //网络是否畅通-否
        {
            return nil;
        }
        SZSessionModel * model = [[SZSessionModel alloc] init];
        model.urlMark = urlStr;
        return model;
    }
    return nil;
}

#pragma mark - 参数处理

//url拼接
- (NSString *)urlRelativeToUrlStr:(NSString *)urlStr{
    
    NSString * url = nil;
    if([urlStr hasPrefix:@"http"]){
        
        url = urlStr;
    }
    else{
        
        url = [self.baseUrl stringByAppendingString:urlStr];
    }
    return url;
}

//
- (AFHTTPRequestSerializer <AFURLRequestSerialization> *)requestSerializer
{
    return _manager.requestSerializer;
}

- (void)setRequestSerializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer
{
    _manager.requestSerializer = requestSerializer;
}

- (AFHTTPResponseSerializer <AFURLResponseSerialization> *)responseSerializer
{
    return _manager.responseSerializer;
}

- (void)setResponseSerializer:(AFHTTPResponseSerializer<AFURLResponseSerialization> *)responseSerializer
{
    _manager.responseSerializer = responseSerializer;
}

#pragma mark - 注册任务

//get请求
- (SZSessionModel *)getWithURLStr:(NSString *)strUrl parameters:(id)parameters Progress:(blockProgress)blkProgress success:(blockSuccess)blkSuccess failure:(blockFailure)blkFailure{
    SZSessionModel * model = nil;
    __weak SZNetWorkingManager * weakSelf = self;
    NSString * urlStr = [self urlRelativeToUrlStr:strUrl];
    if((model = [self isTaskForNetWorkExistWithURLStr:urlStr andParameters:parameters]))
    {
        NSURLSessionDataTask * task = [_manager GET:urlStr parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
#ifdef NSLOG_SHOW
            NSLog(@"NSProgress : %@, %s", downloadProgress, __FUNCTION__);
#endif
            
            if(blkProgress)
            {
                blkProgress(downloadProgress);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
#ifdef NSLOG_SHOW
            NSLog(@"NSProgress : %@, %s", task, __FUNCTION__);
#endif
            
            if(blkSuccess)
            {
                blkSuccess(responseObject);
            }
            [weakSelf.dicTask removeObjectForKey:model.urlMark];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef NSLOG_SHOW
            NSLog(@"NSProgress : %@, %s", task, __FUNCTION__);
#endif
            
            if(blkFailure)
            {
                blkFailure(error);
            }
            [weakSelf.dicTask removeObjectForKey:model.urlMark];
        }];
        model.task = task;
        model.urlStr = urlStr;
        model.parameters = parameters;
        [_dicTask setObject:model forKey:model.urlMark];
    }
    
    return model;
}

//post请求
- (SZSessionModel *)postWithURLStr:(NSString *)strUrl parameters:(id)parameters Progress:(blockProgress)blkProgress success:(blockSuccess)blkSuccess failure:(blockFailure)blkFailure{
    SZSessionModel * model = nil;
    __weak SZNetWorkingManager * weakSelf = self;
    NSString * urlStr = [self urlRelativeToUrlStr:strUrl];
    if((model = [self isTaskForNetWorkExistWithURLStr:urlStr andParameters:parameters]))
    {
        NSURLSessionDataTask * task = [_manager POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
#ifdef NSLOG_SHOW
            NSLog(@"NSProgress : %@, %s", uploadProgress, __FUNCTION__);
#endif
            
            if(blkProgress)
            {
                blkProgress(uploadProgress);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#ifdef NSLOG_SHOW
            NSLog(@"NSProgress : %@, %s", task, __FUNCTION__);
#endif
            
            if(blkSuccess)
            {
                blkSuccess(responseObject);
            }
            [weakSelf.dicTask removeObjectForKey:model.urlMark];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef NSLOG_SHOW
            NSLog(@"NSProgress : %@, %s", task, __FUNCTION__);
#endif
            
            if(blkFailure)
            {
                blkFailure(error);
            }
            [weakSelf.dicTask removeObjectForKey:model.urlMark];
        }];
        model.task = task;
        model.urlStr = urlStr;
        model.parameters = parameters;
        [_dicTask setObject:model forKey:model.urlMark];
    }
    
    return model;
}

//post上传数据
- (SZSessionModel *)postUpLoadWithURLStr:(NSString*)strUrl parameters:(id)parameters constructingBodyWithBlock:(void(^)(id<AFMultipartFormData>  _Nonnull formData))blkFormData Progress:(blockProgress)blkProgress success:(blockSuccess)blkSuccess failure:(blockFailure)blkFailure{
    SZSessionModel * model = nil;
    __weak SZNetWorkingManager * weakSelf = self;
    NSString * urlStr = [self urlRelativeToUrlStr:strUrl];
    if((model = [self isTaskForNetWorkExistWithURLStr:urlStr andParameters:parameters]))
    {
        NSURLSessionDataTask * task = [_manager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
#ifdef NSLOG_SHOW
            NSLog(@"formData : %@, %s", formData, __FUNCTION__);
#endif
            
            if(blkFormData)
            {
                blkFormData(formData);
            }
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
#ifdef NSLOG_SHOW
            NSLog(@"NSProgress : %@, %s", uploadProgress, __FUNCTION__);
#endif
            
            if(blkProgress)
            {
                blkProgress(uploadProgress);
            }
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#ifdef NSLOG_SHOW
            NSLog(@"success : %@, %s", task, __FUNCTION__);
#endif
            
            if(blkSuccess)
            {
                blkSuccess(responseObject);
            }
            [weakSelf.dicTask removeObjectForKey:model.urlMark];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef NSLOG_SHOW
            NSLog(@"failure : %@, %s", task, __FUNCTION__);
#endif
            
            if(blkFailure)
            {
                blkFailure(error);
            }
            [weakSelf.dicTask removeObjectForKey:model.urlMark];
        }];
        model.task = task;
        model.urlStr = urlStr;
        model.parameters = parameters;
        [_dicTask setObject:model forKey:model.urlMark];
    }
    
    return model;
}

//请求下载
- (SZSessionModel *)downloadWithURLStr:(NSString *)strUrl progress:(blockProgress)blkProgress destination:(NSURL * _Nonnull(^)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response))blkDestination completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))blkCompletionHandler{
    SZSessionModel * model = nil;
    __weak SZNetWorkingManager * weakSelf = self;
    NSString * urlStr = [self urlRelativeToUrlStr:strUrl];
    if((model = [self isTaskForNetWorkExistWithURLStr:urlStr andParameters:nil]))
    {
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        NSURLSessionTask * task = [_manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
#ifdef NSLOG_SHOW
            NSLog(@"NSProgress : %@, %s", downloadProgress, __FUNCTION__);
#endif
            if(blkProgress)
            {
                blkProgress(downloadProgress);
            }
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
#ifdef NSLOG_SHOW
            NSLog(@"destination : %@, %s", response, __FUNCTION__);
#endif
            if(blkDestination)
            {
                return blkDestination(targetPath,response);
            }
            else
            {
                NSString * strPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                return [NSURL URLWithString:strPath];
            }
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
#ifdef NSLOG_SHOW
            NSLog(@"completionHandler : %@, %s", response, __FUNCTION__);
#endif
            if (blkCompletionHandler)
            {
                blkCompletionHandler(response,filePath,error);
            }
            [weakSelf.dicTask removeObjectForKey:model.urlMark];
        }];
        
        model.task = task;
        model.urlStr = urlStr;
        [_dicTask setObject:model forKey:model.urlMark];
        
    }
    
    return model;
}

//请求上传data
- (SZSessionModel *)uploadDataWithURLStr:(NSString *)strUrl fromData:(nullable NSData *)data progress:(blockProgress)blkProgress completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))blkCompletionHandler{
    SZSessionModel * model = nil;
    __weak SZNetWorkingManager * weakSelf = self;
    NSString * urlStr = [self urlRelativeToUrlStr:strUrl];
    if((model = [self isTaskForNetWorkExistWithURLStr:urlStr andParameters:nil]))
    {
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        NSURLSessionTask * task = [_manager uploadTaskWithRequest:request fromData:data progress:^(NSProgress * _Nonnull uploadProgress) {
#ifdef NSLOG_SHOW
            NSLog(@"NSProgress : %@, %s", uploadProgress, __FUNCTION__);
#endif
            if(blkProgress)
            {
                blkProgress(uploadProgress);
            }
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
#ifdef NSLOG_SHOW
            NSLog(@"completionHandler : %@, %s", response, __FUNCTION__);
#endif
            if(blkCompletionHandler)
            {
                blkCompletionHandler(response,responseObject,error);
            }
            [weakSelf.dicTask removeObjectForKey:model.urlMark];
        }];
        model.task = task;
        model.urlStr = urlStr;
        [_dicTask setObject:model forKey:model.urlMark];
    }
    
    return model;
}

//请求上传file
- (SZSessionModel *)uploadFileWithURLStr:(NSString *)strUrl fromFile:(nonnull NSURL *)fileUrl progress:(blockProgress)blkProgress completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))blkCompletionHandler{
    SZSessionModel * model = nil;
    __weak SZNetWorkingManager * weakSelf = self;
    NSString * urlStr = [self urlRelativeToUrlStr:strUrl];
    if((model = [self isTaskForNetWorkExistWithURLStr:urlStr andParameters:nil]))
    {
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        NSURLSessionTask * task = [_manager uploadTaskWithRequest:request fromFile:fileUrl progress:^(NSProgress * _Nonnull uploadProgress) {
#ifdef NSLOG_SHOW
            NSLog(@"NSProgress : %@, %s", uploadProgress, __FUNCTION__);
#endif
            if(blkProgress)
            {
                blkProgress(uploadProgress);
            }
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
#ifdef NSLOG_SHOW
            NSLog(@"completionHandler : %@, %s", response, __FUNCTION__);
#endif
            if(blkCompletionHandler)
            {
                blkCompletionHandler(response,responseObject,error);
            }
            [weakSelf.dicTask removeObjectForKey:model.urlMark];
        }];
        model.task = task;
        model.urlStr = urlStr;
        [_dicTask setObject:model forKey:model.urlMark];
    }
    
    return model;
}

@end
