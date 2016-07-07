//
//  ViewController.m
//  AsySocketDemo
//
//  Created by V on 7/7/2016.
//  Copyright © 2016 V. All rights reserved.
//

#import "ViewController.h"
#import <GCDAsyncSocket.h>

@interface ViewController ()<GCDAsyncSocketDelegate>
{

//    GCDAsyncSocket *socket;
}
@property (weak, nonatomic) IBOutlet UILabel *ShowLB;
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *DanmuTextField;

@property (assign, nonatomic)NSInteger status;

@property (strong, nonatomic)GCDAsyncSocket *clientSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark -- LazyLoad
- (GCDAsyncSocket *)clientSocket{

    if (!_clientSocket) {
        _clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_queue_create("delegateQueue", nil)];
    }
    
    return _clientSocket;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Send:(id)sender {
    
    NSLog(@"send message");
    NSString *str = self.DanmuTextField.text;
    NSData *data =[str dataUsingEncoding:NSUTF8StringEncoding];
    [_clientSocket writeData:data  withTimeout:-1 tag:101];//didWriteDataWithTag代理方法被触发
    
    
    
}

- (IBAction)Connection:(id)sender {
    
    if ([self.clientSocket isConnected]) {
        NSLog(@"connected already");
    }
    else{
    
        NSString *host = self.ipTextField.text;
        int port = [self.portTextField.text intValue];
        NSError *err = nil;
        BOOL isSuccess;
        
        NSLog(@"is connecting to host:%@ port:%d",host, port);
        isSuccess = [self.clientSocket connectToHost:host onPort:port error:&err];
        
        if (!isSuccess) {
            NSLog(@"error!!!");
        }
        else{
            self.ShowLB.text = @"connected!";
        }
    }
}

#pragma Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{

    NSLog(@"连接成功！！！！");
}



-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //接收数据需要手动调用这个方法，didReadData代理才回调用,以下是GCDAsyncSocket.m源码中的调用顺序。
    /*
     0）[_socket readDataWithTimeout:-1 tag:109];
     1）- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag 》- (void)readDataToData:(NSData *)data
     withTimeout:(NSTimeInterval)timeout
     buffer:(NSMutableData *)buffer
     bufferOffset:(NSUInteger)offset
     maxLength:(NSUInteger)maxLength
     tag:(long)tag
     
     2）maybeDequeueRead
     3）doReadData
     4）completeCurrentRead
     5）delegate 调用-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
     */
    
    [_clientSocket readDataWithTimeout:-1 tag:109];
    NSLog(@"%ld",tag);
    //打印的tag是101
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"返回数据");
    NSString *str = [[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    NSLog(@"%ld",tag);
    
    __block NSString *objStr = str;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ShowLB.text = objStr;
    });
    //打印的tag是109
    //所以通过tag可以辨认是哪个操作，是写操作还是读操作。还是登录操作，还是注册操作，吧啦啦啦
    
}

@end
