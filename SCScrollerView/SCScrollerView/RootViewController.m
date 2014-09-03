//
//  RootViewController.m
//  SCScrollerView
//
//  Created by SCMac on 14-8-30.
//  Copyright (c) 2014年 devDM. All rights reserved.
//

#import "RootViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "SCPhoto.h"

#import "SCPhotoBrowser.h"
@interface RootViewController ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;
@property (strong, nonatomic) NSMutableDictionary* fileIndexMap;

//照片数组
@property (nonatomic, strong) NSMutableArray *localAssets;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, strong) NSMutableDictionary *timeDic;
@property (nonatomic, strong) NSMutableArray *fileNameList;
@property (nonatomic) BOOL photosLoadingDone;
@end

@implementation RootViewController
- (void)dealloc
{
    _assetsLibrary = nil;
    _groups = nil;
    _fileIndexMap = nil;
    _localAssets = nil;
    _assets = nil;
    _localAssets = nil;
    _fileNameList = nil;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pushButton setFrame:CGRectMake(0, 200, 280, 40)];
    [pushButton setTitle:@"PushToBrowserViewController" forState:UIControlStateNormal];
    [pushButton.titleLabel setBackgroundColor:[UIColor blueColor]];
    [pushButton setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    [self.view addSubview:pushButton];
    [pushButton addTarget:self action:@selector(pushButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [pushButton.titleLabel.layer setCornerRadius:5.0f];
    
    [self startImportAllPhotos];
    
}
- (void)pushButtonAction:(id)sender {
    
    SCPhotoBrowser *browser = [[SCPhotoBrowser alloc] init];
    [browser setPhotoArray:_localAssets];
    [self.navigationController pushViewController:browser animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)startImportAllPhotos
{
    if (self.assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    if (self.groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    }
    else {
        [self.groups removeAllObjects];
    }
    if (self.timeDic == nil) {
        _timeDic = [[NSMutableDictionary alloc] init];
    }else
    {
        [self.timeDic removeAllObjects];
    }
    if (!self.assets) {
        _assets = [[NSMutableArray alloc] init];
    }
    else {
        [self.assets removeAllObjects];
    }
    if (self.localAssets == nil) {
        _localAssets = [[NSMutableArray alloc] init];
    }else
    {
        [_localAssets removeAllObjects];
    }
    
    //    if (self.fileNameList == nil) {
    //        _fileNameList = [[NSMutableArray alloc] init];
    //    }
    //    else {
    //        [self.fileNameList removeAllObjects];
    //    }
    
    __block int imageAssetIndex = 0;
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
    };
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            
            NSString* fileName = [result defaultRepresentation].filename;
            if([_fileIndexMap objectForKey:fileName] == nil)
            {
                [_fileIndexMap setObject:[NSNumber numberWithInt:imageAssetIndex] forKey:fileName];
                //                [self.fileNameList addObject:fileName];
                [self.assets addObject:result];
                
                NSString *photoTime = [NSString stringWithFormat:@"%@", [result valueForProperty:ALAssetPropertyDate]];
                NSString *time = [photoTime substringWithRange:NSMakeRange(0, 10)];
                //                NSLog(@"photoFileName: %@", result.defaultRepresentation.filename);
                SCPhoto *photo = [[SCPhoto alloc] init];
                //                MWPhoto *photo = [[MWPhoto alloc] init];
                photo.alasset = result;
                //                photo.date = time;
                //                photo.alassetID = imageAssetIndex;
//                if (self.localAssets.count <= 10) {
                        [self.localAssets addObject:photo];
//                }

                
                //筛选时间
                [self.timeDic setObject:@"time" forKey:time];
                
                imageAssetIndex++;
            }
        }
        else
        {
            //             NSLog(@"end of enumerate block!");
        }
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group == 0) {
            NSLog(@"done");
            _photosLoadingDone = YES;
        }
        if(group == nil)
        {
            NSLog(@"end of enumerate, assets = %d!",imageAssetIndex);
            return;
        }
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        [self.groups addObject:group];
        
        if ([group numberOfAssets] > 0)
        {
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        }
    };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // enumerate only photos
        NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
        //        NSUInteger groupTypes = ALAssetsGroupAll;
        [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    });
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
