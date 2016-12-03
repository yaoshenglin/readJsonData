//
//  ViewController.m
//  readJsonData
//
//  Created by xy on 16/9/7.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "ViewController.h"
#import "Tools.h"

@interface ViewController ()<NSTextViewDelegate>
{
    int position;
//    NSUndoManager *undoManager;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubViews];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    //注册撤销（压栈）：
//    NSUndoManager *undoManager = self.undoManager;
//    NSLog(@"%@",undoManager.redoMenuItemTitle);
//    NSLog(@"%@",undoManager.undoMenuItemTitle);
}

- (void)setupSubViews
{
    self.view.window.backgroundColor = [NSColor redColor];
    
    NSTextView *textView = _txtContent.documentView;
    textView.delegate = self;
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"demo.sh" ofType:nil];
    //NSLog(@"path = %@",path);
    //NSLog(@"content = %@",[NSBundle allBundles]);
}

- (IBAction)parseJsonData:(NSButton *)sender
{
    NSTextView *textView = _txtContent.documentView;
    NSString *content = textView.string;
    //NSLog(@"content = %@",content);
    
    NSColor *textColor = textView.textColor;
    if (textColor.whiteComponent != 0) {
        CGFloat redValue, greenValue, blueValue, alphaValue;
        [textColor getRed:&redValue green:&greenValue blue:&blueValue alpha:&alphaValue];
        if (textColor == [NSColor whiteColor] || (redValue == greenValue == blueValue)) {
            textView.textColor = [NSColor blackColor];
            NSLog(@"%f",textColor.redComponent);
            NSLog(@"%f",textColor.greenComponent);
            NSLog(@"%f",textColor.blueComponent);
            NSLog(@"%f",textColor.alphaComponent);
        }
    }
    
    
    NSError *error = nil;
    NSString *replacement = @"✄";
    content = [content stringByReplacingOccurrencesOfString:@"\\n" withString:replacement];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length <= 0) {
        error = error ?: [NSError errorWithDomain:@"输入内容为空" code:0 userInfo:@{NSLocalizedDescriptionKey:@"the content is nil"}];
        NSLog(@"%@",error.localizedDescription);
        NSAlert *alert = [NSAlert alertWithError:error];
        alert.messageText = @"输入内容不能为空";
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            NSLog(@"%ld",(long)returnCode);
        }];
        return;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
        NSAlert *alert = [NSAlert alertWithError:error];
        alert.messageText = @"该数据不是Json数据";
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            NSLog(@"%ld",(long)returnCode);
        }];
        return;
    }
    
    content = [NSString stringWithFormat:@"%@",json.description];
    content = [NSString stringWithCString:[content cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    if (content.length <= 0) {
        error = error ?: [NSError errorWithDomain:@"解析失败" code:0 userInfo:@{NSLocalizedDescriptionKey:@"the content is nil"}];
        NSLog(@"%@",error.localizedDescription);
        NSAlert *alert = [NSAlert alertWithError:error];
        alert.messageText = @"解析失败";
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        
        content = json.description;
    }
    
    content = [content stringByReplacingOccurrencesOfString:replacement withString:@"\n"];
    textView.string = content;
    textView.textColor = [NSColor blackColor];
    
    [textView selectedTextAttributes];
    [textView updateInsertionPointStateAndRestartTimer:YES];
    [textView updateConstraints];
}

////则invoke方法undoAction
//- (void)undoAction:(NSNumber *)num
//{
//    NSLog(@"%@",num);
//    [self.undoManager registerUndoWithTarget:self selector:@selector(undoAction:) object:num];
//    
//}

- (NSUndoManager *)undoManagerForTextView:(NSTextView *)view
{
    NSArray *list = [self.undoManager getObjectPropertyList];
    for (NSString *key in list) {
        id value = [self.undoManager valueForKey:key];
        if (value) {
            NSLog(@"%@, %@",key,value);
        }
    }

    return nil;
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
