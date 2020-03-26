//
//  CYAlbumPhotoTraversaler.m
//  CYToolkit
//
//  Created by Chris Yang on 2020/3/26.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import <Photos/Photos.h>

#import "CYAlbumPhotoTraversaler.h"

@implementation CYAlbumPhotoTraversaler

- (id)init {
    self = [super init];
    if (self) {
        _tarSize = CGSizeMake(300, 500);
    }
    
    return self;
}

+ (CYAlbumPhotoTraversaler *)sharedTraversaler {
    
    static CYAlbumPhotoTraversaler *_sharedTraversaler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTraversaler = [[CYAlbumPhotoTraversaler alloc] init];
    });
    
    return _sharedTraversaler;
}

/* 同步遍历用户照片 */
- (void)traversalUserPhotosWithCallback:(CYAlbumPhotoTraversalerBlock)callback {
    
    /* Recents 相簿 */
    PHAssetCollection *userAssetCollection =
    [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                             subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                             options:nil].lastObject;
    
    /* 执行遍历 */
    [self __enumerateAssetsInAssetCollection:userAssetCollection withCallback:callback];
}

/* 同步遍历特定相册所有照片 */
- (void)traversalPhotosInAlbum:(NSString *)albumName
                  withCallback:(CYAlbumPhotoTraversalerBlock)callback {
    
    /* 获取目标相簿 */
    PHAssetCollection *tarCollection = [self __collectionFromAlbumName:albumName];
    if (nil == tarCollection) {
        return;
    }
    
    /* 执行遍历 */
    [self __enumerateAssetsInAssetCollection:tarCollection withCallback:callback];
}

- (void)LogAllAlbums {
    
    /* 普通相簿 */
    PHFetchResult<PHAssetCollection *> *assetCollections =
    [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                             subtype:PHAssetCollectionSubtypeAny
                                             options:nil];
    printf("\n");
    NSLog(@"相簿数量： %d", (int)(assetCollections.count));
    for (PHAssetCollection *assetCollection in assetCollections) {
        NSLog(@"相册名：%@     相册类型 %d", assetCollection.localizedTitle, (int)assetCollection.assetCollectionSubtype);
    }
    
    /* 智能相簿 */
    assetCollections =
    [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                             subtype:PHAssetCollectionSubtypeAny
                                             options:nil];
    
    printf("\n");
    NSLog(@"智能相簿数量： %d", (int)(assetCollections.count));
    for (PHAssetCollection *assetCollection in assetCollections) {
        NSLog(@"相册名：%@     相册类型 %d", assetCollection.localizedTitle, (int)assetCollection.assetCollectionSubtype);
    }
}

#pragma mark - MISC

- (PHAssetCollection *)__collectionFromAlbumName:(NSString *)albumName {
    
    /* 相簿 */
    PHFetchResult<PHAssetCollection *> *assetCollections =
    [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                             subtype:PHAssetCollectionSubtypeAny
                                             options:nil];
    for (PHAssetCollection *assetCollection in assetCollections) {
        if (YES == [assetCollection.localizedTitle isEqualToString:albumName]) {
            return assetCollection;
        }
    }
    
    /* 智能相簿 */
    assetCollections =
    [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                             subtype:PHAssetCollectionSubtypeAny
                                             options:nil];
    for (PHAssetCollection *assetCollection in assetCollections) {
        if (YES == [assetCollection.localizedTitle isEqualToString:albumName]) {
            return assetCollection;
        }
    }

    return nil;
}

- (void)__enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                              withCallback:(CYAlbumPhotoTraversalerBlock)callback {
        
    NSString *albumName = assetCollection.localizedTitle;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = YES;
    
    /* 遍历相簿 */
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        [[PHImageManager defaultManager]
         requestImageForAsset:asset
         targetSize:_tarSize
         contentMode:PHImageContentModeAspectFit
         options:options
         resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            callback(albumName, result);
         }];
    }
}

@end
