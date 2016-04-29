//
//  SettingViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/4/25.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "SettingViewController.h"

@implementation SettingViewController

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type)
    {
        case Iphone5s:
            self.settingViewTop.constant=20;
            self.userName.font=[UIFont systemFontOfSize:19.f];
            break;
        case Iphone6:
            self.userName.font=[UIFont systemFontOfSize:22.f];
            break;
        case Iphone6p:
            self.settingViewTop.constant=40;
            break;
        default:
            self.settingViewTop.constant=10;
            self.userName.font=[UIFont systemFontOfSize:16.f];
            break;
    }
    
}

-(void)viewDidLoad
{
    UIImage *background=[CommonMethod imageWithImage:[UIImage imageNamed:@"naked_background"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor=[UIColor colorWithPatternImage:background];
    
    self.settingView.backgroundColor=[UIColor colorWithRed:9/255.f green:199/255.f blue:242/255.f alpha:1];
    self.settingView.layer.cornerRadius=5;
    self.settingView.layer.masksToBounds=YES;
    
    
    self.settingTableView.backgroundColor = [UIColor whiteColor];
    self.settingTableView.opaque = NO;
    self.settingTableView.layer.cornerRadius=5;
    self.settingTableView.layer.masksToBounds=YES;
    
    self.portraitImage.layer.cornerRadius=self.portraitImage.frame.size.width/2;
    self.portraitImage.clipsToBounds=YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isPickerView=false;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint pos=[touch locationInView:self.settingView];
    if (CGRectContainsPoint(self.portraitImage.frame, pos))
    {
        [self setAndUploadPortrait];
    }
    if (CGRectContainsPoint(self.userName.frame, pos))
    {
        [self setAndUploadUserName];
    }
}

-(void)setAndUploadPortrait
{
    UIActionSheet *sheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet=[[UIActionSheet alloc]initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    }
    else
        sheet=[[UIActionSheet alloc]initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机相册选择", nil];
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType;
    switch (buttonIndex)
    {
        case 0:
            sourceType=UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 2:
            return;
        default:
            break;
    }
    UIImagePickerController *picker=[[UIImagePickerController alloc]init];
    picker.delegate=self;
    picker.allowsEditing=YES;
    picker.sourceType=sourceType;
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isPickerView=true;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isPickerView=false;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    [self.portraitImage setImage:image];
}


-(void)setAndUploadUserName
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    UITextField *textField = [alert addTextField:@"请输入您的用户名"];
    
    [alert addButton:@"确认" actionBlock:^(void) {
        self.userName.text=textField.text;
    }];
    
    [alert showEdit:self title:@"修改用户名" subTitle:nil closeButtonTitle:@"取消" duration:0.0f];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
    if (!cell) {
        cell=[[SettingCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"settingCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row==0)
    {
        [cell.cellLeftImage setImage:[UIImage imageNamed:@"settingPhone"]];
        cell.cellLabel.text=@"绑定手机";
        cell.cellButton.hidden=YES;
    }
    if (indexPath.row==1)
    {
        [cell.cellLeftImage setImage:[UIImage imageNamed:@"settingUnknow"]];
        cell.cellLabel.text=@"生词本";
        cell.cellButton.hidden=YES;
    }
    if (indexPath.row==2)
    {
        [cell.cellLeftImage setImage:[UIImage imageNamed:@"settingPassword"]];
        cell.cellLabel.text=@"修改密码";
        cell.cellButton.hidden=YES;
    }
    if (indexPath.row==3)
    {
        cell.cellLeftImage.hidden=YES;
        cell.cellLabel.hidden=YES;
        cell.cellButton.hidden=NO;
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    cell.delegate=self;
    [cell setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==3)
    {
        return ceil(self.settingTableView.frame.size.height/4+9);
    }
    return  ceil(self.settingTableView.frame.size.height/4-3);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BindPhoneViewController *bindViewController=[storyboard instantiateViewControllerWithIdentifier:@"BindPhoneViewController"];
        [self.navigationController pushViewController:bindViewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (IBAction)goBackButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)logoutButtonClick {
    
        SCLAlertView *alert=[[SCLAlertView alloc]init];
        [alert addButton:@"确定" target:self selector:@selector(logout)];
        [alert showNotice:self title:@"提示" subTitle:@"您确定要退出当前账号？" closeButtonTitle:@"取消" duration:0.0f];
}


-(void)logout
{
    [[AccountManager singleInstance] deleteAccount];
    [[NSUserDefaults standardUserDefaults] setValue:@"out" forKey:@"MeticStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
    
}
@end
