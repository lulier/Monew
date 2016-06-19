//
//  SettingViewController.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/4/25.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "SettingViewController.h"
#import "NetworkingManager.h"

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
    self.portraitImage.backgroundColor=[UIColor clearColor];
    self.portraitImage.clipsToBounds=YES;
    
    AccountManager *account=[AccountManager singleInstance];
    if (account.gender==0)
    {
        [self.genderImage setImage:[UIImage imageNamed:@"boy"]];
    }
    else
        [self.genderImage setImage:[UIImage imageNamed:@"girl"]];
    
    if (![account.nickName isEqualToString:@""])
    {
        self.userName.text=account.nickName;
    }
    else
        self.userName.text=@"dd";
    
    [self.difficultSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (account.difficult)
    {
        [self.difficultSwitch setOn:YES animated:NO];
    }
    else
        [self.difficultSwitch setOn:NO animated:NO];
    
    
    
    
    // 设置头像
    if (account.type==LTWeiBo||account.type==LTWeiXin||account.type==LTQQ)
    {
        if (account.thirdPartyImage!=nil)
        {
            NSURL *url=[NSURL URLWithString:account.thirdPartyImage];
            [self.portraitImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Icon"]];
        }
    }
    else
    {
        if (account.portraitKey!=nil&&![account.portraitKey isEqualToString:@""])
        {
            NSMutableString *sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"GET%@",account.portraitKey]];
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:@"GET",@"method",account.portraitKey,@"object",sign,@"sign",nil];
            [NetworkingManager httpRequest:RTPost url:RUGetCloudURL parameters:dict progress:nil success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject) {
                long int status=[[responseObject objectForKey:@"status"]integerValue];
                if (status==0)
                {
                    NSURL *url=[NSURL URLWithString:[responseObject objectForKey:@"url"]];
                    [self.portraitImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Icon"]];
                }
                
            } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
                
            } completionHandler:nil];
        }
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isPickerView=false;
}
-(void)switchValueChanged:(id)sender
{
    AccountManager *account=[AccountManager singleInstance];
    BOOL value=[sender isOn];
    if (value)
    {
        account.difficult=true;
    }
    else
        account.difficult=false;
        
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
    if (CGRectContainsPoint(self.genderImage.frame, pos))
    {
        [self setAndUploadGender];
    }
}

-(void)setAndUploadGender
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert addButton:@"男生" actionBlock:^(void) {
        [self.genderImage setImage:[UIImage imageNamed:@"boy"]];
        AccountManager *account=[AccountManager singleInstance];
        account.gender=UGBoy;
        [account uploadUserInfo];
    }];
    
    [alert addButton:@"女生" actionBlock:^(void) {
        [self.genderImage setImage:[UIImage imageNamed:@"girl"]];
        AccountManager *account=[AccountManager singleInstance];
        account.gender=UGGirl;
        [account uploadUserInfo];
    }];
    alert.customViewColor=[UIColor grayColor];
    [alert showEdit:self title:@"性别" subTitle:@"请选择性别" closeButtonTitle:nil duration:0.0f];
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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
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
                return;
        }
    }
    else
    {
        switch (buttonIndex)
        {
            case 0:
                sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 1:
                return;
            default:
                return;
        }
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
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isPickerView=false;
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    [self saveImageAndCreateKey:image];
    
}

-(void)saveImageAndCreateKey:(UIImage*)image
{
    AccountManager *account=[AccountManager singleInstance];
    NSUInteger timeStamp=[CommonMethod getTimeStamp];
    NSString *key=[NSString stringWithFormat:@"%@_%ld.jpg",account.userID,(unsigned long)timeStamp];
    
    
    NSString *imageDoc=[CommonMethod getPath:@"avatar"];
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDoc isDirectory:&isDir])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDoc withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath=[imageDoc stringByAppendingPathComponent:key];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
//    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    [self uploadPortraitImage:key filePath:filePath image:image];
}

-(void)uploadPortraitImage:(NSString*)key filePath:(NSString*)filePath image:(UIImage*)image
{
    NSString *method=@"PUT";
    NSMutableString* sign=[CommonMethod MD5EncryptionWithString:[NSString stringWithFormat:@"%@%@",method,key]];
    key=[NSString stringWithFormat:@"avatar/%@",key];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:method,@"method",key,@"object",sign,@"sign",nil];

    
    
    [NetworkingManager httpRequest:RTPost url:RUGetCloudURL parameters:dict progress:nil
    success:^(NSURLSessionTask * _Nullable task, id  _Nullable responseObject)
    {
        long int status=[[responseObject objectForKey:@"status"]integerValue];
        if (status==0)
        {
            
            NSString *url=[responseObject objectForKey:@"url"];
            NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:url,@"uploadURL",filePath,@"filePath", nil];
            
            //upload image
            [NetworkingManager httpRequest:RTUpload url:RUGetCloudURL parameters:parameters progress:^(NSProgress * _Nullable progress) {
                
            } success:nil failure:nil
            completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                //set new userinfo
                [self.portraitImage setImage:image];
                AccountManager *account=[AccountManager singleInstance];
                account.portraitKey=key;
                [account uploadUserInfo];
            }];
        }
    }
    failure:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error)
    {
        
    }
    completionHandler:nil];
}


-(void)setAndUploadUserName
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    UITextField *textField = [alert addTextField:@"请输入您的用户名"];
    
    [alert addButton:@"确认" actionBlock:^(void) {
        if (![textField.text isEqualToString:@""])
        {
            self.userName.text=textField.text;
            AccountManager *account=[AccountManager singleInstance];
            account.nickName=textField.text;
            [account uploadUserInfo];
        }
    }];
    alert.customViewColor=[UIColor grayColor];
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
        [self goToBindView];
    }
    if (indexPath.row==1)
    {
        [self goToUnknow];
    }
    if (indexPath.row==2)
    {
        [self setPassword];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
-(void)goToBindView
{
    AccountManager *account=[AccountManager singleInstance];
    if (account.type==LTPhone)
    {
        //alert
        SCLAlertView *alert=[[SCLAlertView alloc]init];
        [alert showNotice:self title:@"提示" subTitle:@"您的帐号为手机号码，无需绑定手机" closeButtonTitle:@"确定" duration:0.0f];
    }
    else
    {
        //check whether bind phone
        AccountManager *account=[AccountManager singleInstance];
        [account checkPhoneBind:^(BOOL bind,NSString* phone) {
            UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            BindPhoneViewController *bindViewController=[storyboard instantiateViewControllerWithIdentifier:@"BindPhoneViewController"];
            if (!bind)
            {
                bindViewController.bind=YES;
                
            }
            else
            {
                bindViewController.bind=NO;
                bindViewController.currentPhone=phone;
            }
            [self.navigationController pushViewController:bindViewController animated:YES];
        } failure:^(NSString *message) {
            
        }];
        
    }
}
-(void)goToUnknow
{
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VocabularyViewController *vocabulary=[storyboard instantiateViewControllerWithIdentifier:@"VocabularyViewController"];
    [self.navigationController pushViewController:vocabulary animated:YES];
}
-(void)setPassword
{
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ModifyPassword *modifyPasswordView=[storyboard instantiateViewControllerWithIdentifier:@"ModifyPassword"];
    [self.navigationController pushViewController:modifyPasswordView animated:YES];
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
    [[NSUserDefaults standardUserDefaults] setValue:@"out" forKey:@"AccountStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
    
}
@end
