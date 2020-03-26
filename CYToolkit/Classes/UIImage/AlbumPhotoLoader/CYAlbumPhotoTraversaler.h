//
//  CYAlbumPhotoTraversaler.h
//  CYToolkit
//
//  Created by Chris Yang on 2020/3/26.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CYAlbumPhotoTraversalerBlock)(NSString *albumName, UIImage *image);

@interface CYAlbumPhotoTraversaler : NSObject

/** 返回照片的目标大小，默认300 X 500, 设置为CGSizeZero则返回原图 */
@property (nonatomic, assign) CGSize tarSize;

+ (CYAlbumPhotoTraversaler *)sharedTraversaler;

/** 同步遍历用户相册照片 */
- (void)traversalUserPhotosWithCallback:(CYAlbumPhotoTraversalerBlock)callback;

/** 同步遍历特定相册照片 */
- (void)traversalPhotosInAlbum:(NSString *)albumName
                  withCallback:(CYAlbumPhotoTraversalerBlock)callback;

/** 打印所有相册信息 */
- (void)LogAllAlbums;

@end

NS_ASSUME_NONNULL_END
