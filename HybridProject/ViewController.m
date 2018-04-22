//
//  ViewController.m
//  HybridProject
//
//  Created by nanhu on 2018/4/21.
//  Copyright © 2018年 nanhu. All rights reserved.
//

#import "ValueEnv.h"
#import "ViewController.h"
#import "MENoticeProfile.h"
#import <SSZipArchive/SSZipArchive.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Hybrid Cordova";
    
    [ValueEnv setKey:@"env" value:APP_ENV];
    [ValueEnv setKey:@"webServer" value:DEFAULT_HTTP_SERVER_URL];
    
    [self prepareCordovaEnv];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 准备Cordova环境
 */
- (void)prepareCordovaEnv {
    NSLog(@"sanbox:%@", NSHomeDirectory());
    int wwwVersion = [self fetchVersionFromWWWResourceZip];
    NSLog(@"old version:%d", wwwVersion);
    
    NSString *destPath = [self sandboxPath];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"www" ofType:@"zip"];
    BOOL ret = [SSZipArchive unzipFileAtPath:path toDestination:destPath];
    if (!ret) {
        NSLog(@"解压文件出错");
    }
}

- (int)fetchVersionFromWWWResourceZip {
    NSString *tmpPath = [self tempPath];
    NSString *fileName = @"www";
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"zip"];
    BOOL ret = [SSZipArchive unzipFileAtPath:path toDestination:tmpPath];
    if (!ret) {
        NSLog(@"解压文件出错");
        return -1;
    }
    NSString *versionPath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/version.json", fileName]];
    NSData *versionData = [NSData dataWithContentsOfFile:versionPath];
    NSError *err;
    NSDictionary *versionMap = [NSJSONSerialization JSONObjectWithData:versionData options:NSJSONReadingMutableContainers error:&err];
    if (err || !versionMap) {
        NSLog(@"json 解析出错！");
        return INT8_MAX;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    err = nil;
    ret = [fileManager removeItemAtPath:tmpPath error:&err];
    if (!ret) {
        NSLog(@"remove files error:%@", err.description);
    }
    NSNumber *version = [versionMap objectForKey:@"version"];
    return version.intValue;
}

- (NSString *)sandboxPath {
    NSArray <NSString*>*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    return paths.firstObject;
}

- (NSString *)tempPath {
    return NSTemporaryDirectory();
}

- (IBAction)displayCordovaRenderAction {
    MENoticeProfile *noticeProfile = [[MENoticeProfile alloc] init];
    [self.navigationController pushViewController:noticeProfile animated:true];
}

@end
