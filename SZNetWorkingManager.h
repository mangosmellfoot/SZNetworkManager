//
//  SZNetWorkingManager.h
//  SZAFNetworking
//
//  Created by MapABCios on 16/5/21.
//  Copyright © 2016年 MapABCios. All rights reserved.
//
#import "AFNetworking.h"

/**
 *  网络请求成功的回调block
 *
 *  @param responseObject 网络连接成功的返回数据体
 */
typedef void(^_Nullable blockSuccess)(id  _Nullable responseObject);
/**
 *  网络请求失败的回调block
 *
 *  @param error 错误信息
 */
typedef void(^_Nullable blockFailure)(NSError * _Nullable error);
/**
 *  网络请求过程的回调block
 *
 *  @param downloadProgress 下载过程信息
 */
typedef void(^_Nullable blockProgress)(NSProgress * _Nullable downloadProgress);

@interface SZSessionModel : NSObject
/**
 *  网络通道
 */
@property (strong,nonatomic,nullable) NSURLSessionTask * task;
/**
 *  下载标记
 */
@property (assign,nonatomic,nullable) NSString * urlMark;
/**
 *  请求url
 */
@property (assign,nonatomic,nullable) NSString * urlStr;
/**
 *  请求url参数
 */
@property (strong,nonatomic,nullable) id parameters;

@end


@protocol SZNetWorkingManagerDelegate <NSObject>

/**
 *  网络连接失败时执行的消息
 */
- (void)netWorkingManagerStatusExistenceNetwork;

/**
 网络加载url重复时执行的消息
 */
- (void)netWorkingManagerRepeatAccessNetwork;
@end


@interface SZNetWorkingManager : NSObject

/**
 *  当前网络状态
 */
@property (nonatomic,assign,nullable) NSString * netStatus;
@property (nonatomic,assign,nullable) NSString * baseUrl;
@property (nonatomic,weak,nullable) id<SZNetWorkingManagerDelegate> delegate;
@property (nonatomic, strong,nullable) AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;
@property (nonatomic, strong,nullable) AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;

/**
 *  单例获取
 *
 *  @return SZNetWorkingManager对象
 */
+ (instancetype _Nullable)shareSZNetWorkingManager;
/**
 *  判断网络连接
 *
 *  @return <#return value description#>
 */
- (BOOL)isExistenceNetwork;
/**
 *  get请求网络数据
 *
 *  @param strUrl      <#strUrl description#>
 *  @param parameters  <#parameters description#>
 *  @param blkProgress <#blkProgress description#>
 *  @param blkSuccess  <#blkSuccess description#>
 *  @param blkFailure  <#blkFailure description#>
 *
 *  @return <#return value description#>
 */
- (SZSessionModel *_Nullable)getWithURLStr:(NSString *_Nullable)strUrl parameters:(id _Nullable)parameters Progress:(blockProgress)blkProgress success:(blockSuccess)blkSuccess failure:(blockFailure)blkFailure;
/**
 *  post请求网络数据
 *
 *  @param strUrl      <#strUrl description#>
 *  @param parameters  <#parameters description#>
 *  @param blkProgress <#blkProgress description#>
 *  @param blkSuccess  <#blkSuccess description#>
 *  @param blkFailure  <#blkFailure description#>
 *
 *  @return <#return value description#>
 */
- (SZSessionModel *_Nullable)postWithURLStr:(NSString *_Nonnull)strUrl parameters:(id _Nullable)parameters Progress:(blockProgress)blkProgress success:(blockSuccess)blkSuccess failure:(blockFailure)blkFailure;
/**
 *  post请求上传数据
 *
 *  @param strUrl      <#strUrl description#>
 *  @param parameters  <#parameters description#>
 *  @param blkFormData <#blkFormData description#>
 *  @param blkProgress <#blkProgress description#>
 *  @param blkSuccess  <#blkSuccess description#>
 *  @param blkFailure  <#blkFailure description#>
 *
 *  @return <#return value description#>
 */
- (SZSessionModel *_Nullable)postUpLoadWithURLStr:(NSString *_Nonnull)strUrl parameters:(id _Nullable)parameters constructingBodyWithBlock:(void(^_Nonnull)(id<AFMultipartFormData>  _Nonnull formData))blkFormData Progress:(blockProgress)blkProgress success:(blockSuccess)blkSuccess failure:(blockFailure)blkFailure;
/**
 *  下载网络数据
 *
 *  @param strUrl               <#strUrl description#>
 *  @param blkProgress          <#blkProgress description#>
 *  @param blkDestination       <#blkDestination description#>
 *  @param blkCompletionHandler <#blkCompletionHandler description#>
 *
 *  @return <#return value description#>
 */
- (SZSessionModel *_Nullable)downloadWithURLStr:(NSString *_Nonnull)strUrl progress:(blockProgress)blkProgress destination:(NSURL *_Nullable(^_Nonnull)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response))blkDestination completionHandler:(void (^_Nonnull)(NSURLResponse *_Nullable response, NSURL *_Nullable filePath, NSError *_Nullable error))blkCompletionHandler;
/**
 *  上传网络本地data数据
 *
 *  @param strUrl               <#strUrl description#>
 *  @param data                 <#data description#>
 *  @param blkProgress          <#blkProgress description#>
 *  @param blkCompletionHandler <#blkCompletionHandler description#>
 *
 *  @return <#return value description#>
 */
- (SZSessionModel *_Nullable)uploadDataWithURLStr:(NSString *_Nonnull)strUrl fromData:(nullable NSData *)data progress:(blockProgress)blkProgress completionHandler:(void (^_Nonnull)(NSURLResponse *_Nullable response, id _Nullable responseObject, NSError *_Nullable error))blkCompletionHandler;
/**
 *  上传网络本地文件
 *
 *  @param strUrl               <#strUrl description#>
 *  @param fileUrl              <#fileUrl description#>
 *  @param blkProgress          <#blkProgress description#>
 *  @param blkCompletionHandler <#blkCompletionHandler description#>
 *
 *  @return <#return value description#>
 */
- (SZSessionModel *_Nullable)uploadFileWithURLStr:(NSString *_Nonnull)strUrl fromFile:(nonnull NSURL *)fileUrl progress:(blockProgress)blkProgress completionHandler:(void (^_Nonnull)(NSURLResponse *_Nullable response, id _Nullable responseObject, NSError *_Nullable error))blkCompletionHandler;
@end
