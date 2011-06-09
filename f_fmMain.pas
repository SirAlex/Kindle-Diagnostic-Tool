unit f_fmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ActnList, StdCtrls, ExtCtrls, StdActns, Menus, ComCtrls,
  PlatformDefaultStyleActnCtrls, ActnMan, ToolWin, ActnCtrls, ActnMenus;

type
  TKindleInfo = record
    sn: string;
    recovery_pass: string;
    DevInstDisk: Cardinal;
    DevInstKindle: Cardinal;
    Drive: Char;
    DrivePath: string;
  end;

  TForm3 = class(TForm)
    lbSN: TLabel;
    lbPass: TLabel;
    log: TMemo;
    aclMain: TActionList;
    acRefresh: TAction;
    lbModel: TLabel;
    lbSNVal: TLabel;
    lbPassVal: TLabel;
    lbModelVal: TLabel;
    acCopyInfo: TAction;
    acEject: TAction;
    cxLabel1: TLabel;
    lbDriveLetterVal: TLabel;
    tmrRefresh: TTimer;
    pnLog: TPanel;
    pnInfo: TPanel;
    ppmCopyInfo: TPopupMenu;
    Copytoclipboard1: TMenuItem;
    sBar: TStatusBar;
    FileExit1: TFileExit;
    Splitter1: TSplitter;
    ActionMainMenuBar1: TActionMainMenuBar;
    acmMain: TActionManager;
    procedure FormCreate(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure acCopyInfoExecute(Sender: TObject);
    procedure acEjectUpdate(Sender: TObject);
    procedure acEjectExecute(Sender: TObject);
    procedure lbSNValClick(Sender: TObject);
  private
    { Private declarations }
    FKindleInfo: TKindleInfo;
    procedure UpdateKindleInfo;
    procedure FindKindleDrive;
    procedure EjectKindleInWin7;
  public
    { Public declarations }
    procedure OnDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
    procedure FindKindle;
  end;

const
  GUID_CLASS_USB_DEVICE:TGUID='{4D36E967-E325-11CE-BFC1-08002BE10318}'; // disk

var
  Form3: TForm3;
  selToCopy: string;

implementation

uses JwaWinUser, JwaDbt, JwaWinIoctl, Cfg, CfgMgr32, SetupAPI,
     RegularExpressions, md5, clipbrd;

{$R *.dfm}

function GetKindleModelFromSN(aSN:string):string;
var
  md: char;
begin
  md := aSN[4];
  case md of
    '1': result := 'Kindle 1';
    '2': result := 'Kindle 2 U.S.';
    '3': result := 'Kindle 2 international';
    '8': result := 'Kindle 3 WIFI';
    '6': result := 'Kindle 3 3G + WIFI U.S.';
    'A': result := 'Kindle 3 3G + WIFI European';
    '4': result := 'Kindle DX U.S.';
    '5': result := 'Kindle DX international';
    '9': result := 'Kindle DX Graphite';
  else
    result := 'Unknown';
  end;
end;

procedure Init;
var
  hdr: DEV_BROADCAST_HDR;
begin
  hdr.dbch_size := sizeof(DEV_BROADCAST_VOLUME);
  hdr.dbch_devicetype := DBT_DEVTYP_VOLUME;
  RegisterDeviceNotification(Form3.Handle, @hdr, DEVICE_NOTIFY_WINDOW_HANDLE);
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  sBar.SimpleText := 'Initializing...';
  Application.ProcessMessages;
  LoadSetupApi;
  LoadConfigManagerApi;
  Init;
  FindKindle;
end;

procedure TForm3.lbSNValClick(Sender: TObject);
begin
  if sender is TLabel then
  begin
    Clipboard.AsText := TLabel(sender).Caption;
  end;
end;

function DWORDtoDiskNames(val:DWORD):string;
var
  _i: integer;
begin
  Result:='';
  for _i := 0 to 25 do
   begin
    if ((val mod 2)=1) then Result:=result+ chr(_i + 65);
    val:=val shr 1;
   end;
end;

procedure TForm3.OnDeviceChange(var Msg: TMessage);
begin
  if ((Msg.WParam=DBT_DEVICEREMOVECOMPLETE) or (Msg.WParam=DBT_DEVICEARRIVAL)) and (PDEV_BROADCAST_HDR(Msg.LParam)^.dbch_devicetype = DBT_DEVTYP_VOLUME) then
  begin
    FindKindle;
  end;
end;


//USB\VID_1949&PID_0004&
function isKindle(PnPHandle: HDEVINFO; const DevData: TSPDevInfoData): boolean;
var
  BytesReturned: DWORD;
  RegDataType: DWORD;
  Buffer: array [0..5000] of CHAR;
begin
  BytesReturned := 0;
  RegDataType := 0;
  Buffer[0] := #0;
  SetupDiGetDeviceRegistryProperty(PnPHandle, DevData, SPDRP_HARDWAREID,
    RegDataType, PByte(@Buffer[0]), SizeOf(Buffer), BytesReturned);
  Result := Pos('USB\VID_1949&PID_0004',Buffer)>0;
end;

function ReadValue(PnPHandle: HDEVINFO; const DevData: TSPDevInfoData): string;
var
  BytesReturned: DWORD;
  RegDataType: DWORD;
  Buffer: array [0..5000] of CHAR;
begin
  BytesReturned := 0;
  RegDataType := 0;
  Buffer[0] := #0;
  SetupDiGetDeviceRegistryProperty(PnPHandle, DevData, SPDRP_FRIENDLYNAME,
    RegDataType, PByte(@Buffer[0]), SizeOf(Buffer), BytesReturned);
  Result := Buffer;
end;

procedure TForm3.acCopyInfoExecute(Sender: TObject);
var
  res: string;
begin
  if FKindleInfo.sn <> '' then
  begin
    res := res + 'SN: '+ FKindleInfo.sn + #13#10;
    res := res + 'Pass: '+ FKindleInfo.recovery_pass + #13#10;
    res := res + 'Model: '+ GetKindleModelFromSN(FKindleInfo.sn) + #13#10;
    res := res + 'Drive: '+ FKindleInfo.Drive;
    Clipboard.AsText := res;
  end;
end;

procedure TForm3.acEjectExecute(Sender: TObject);
var
  res: Cardinal;
begin
  log.Lines.Add('Ejecting Kindle...');
  EjectKindleInWin7;
  res := CM_Request_Device_Eject(FKindleInfo.DevInstKindle, nil, nil, 0, 0);
  if res <> CR_SUCCESS then
    log.Lines.Add('Eject error code: '+inttostr(res));
end;

procedure TForm3.acEjectUpdate(Sender: TObject);
begin
  acEject.Enabled := FKindleInfo.sn <> '';
end;

procedure TForm3.acRefreshExecute(Sender: TObject);
begin
  FindKindle;
end;

procedure TForm3.FindKindle;
var
  PnPHandle: HDEVINFO;
  DevData: TSPDevInfoData;
  RES: LongBool;
  Devn: Integer;
  devID: WideString;
  regex: TRegEx;
  match: TMatch;
  bCon: boolean;
  DevInstParent: Cardinal;
begin
  bCon := FKindleInfo.sn <> '';
  FKindleInfo.sn := '';
  FKindleInfo.recovery_pass := '';
  FKindleInfo.Drive := ' ';
  FKindleInfo.DrivePath := '';
  FKindleInfo.DevInstDisk := INVALID_HANDLE_VALUE;
  FKindleInfo.DevInstKindle := INVALID_HANDLE_VALUE;

  PnPHandle := SetupDiGetClassDevs(@GUID_CLASS_USB_DEVICE, nil, 0, DIGCF_PRESENT);
  if DWORD(PnPHandle) = INVALID_HANDLE_VALUE then  Exit;
  Devn := 0;
  DevData.cbSize := SizeOf(DevData);
  SetupDiEnumDeviceInfo(PnPHandle, Devn, DevData);
//  inc(devn);
  repeat
   DevData.cbSize := SizeOf(DevData);
   RES := SetupDiEnumDeviceInfo(PnPHandle, Devn, DevData);
   if RES then
   begin
        setLength(devID, 1024);
        CM_Get_Device_ID(DevData.DevInst, @devID[1],1024,0);
        setLength(devID, pos(#0,devID));
        regex := TRegex.Create('\bUSBSTOR\\DISK&VEN_KINDLE&PROD_INTERNAL_STORAGE&REV_0100\\(B00[A-Z0-9]+)\b');
        match := regex.Match(devID);
        if (match.Value <> '') and (match.Groups.Count > 0) then
        begin
          // We found Kindle and got Serial number
          FKindleInfo.DevInstDisk := DevData.DevInst;
          FKindleInfo.sn := match.Groups.Item[1].Value;
          // getting password;
          FKindleInfo.recovery_pass := 'fiona'+copy(string(MD5Print(MD5AnsiString(AnsiString(FKindleInfo.sn)+#10))),8,4);
          if CM_Get_Parent(DevInstParent, DevData.DevInst, 0) = CR_SUCCESS then
            FKindleInfo.DevInstKindle := DevInstParent;
        break;
        end;
     Inc(Devn);
   end else
     break;
  until not RES;
  SetupDiDestroyDeviceInfoList(PnPHandle);
  if (bCon and (FKindleInfo.sn = ''))then
  begin
    log.Lines.Add('Kindle disconnected!');
    sBar.SimpleText := 'Kindle disconnected!';
    UpdateKindleInfo;
  end;
  if (not bCon and (FKindleInfo.sn <> '')) then
  begin
    FindKindleDrive;
    log.Lines.Add('Kindle connected!');
    sBar.SimpleText := 'Kindle connected';
    UpdateKindleInfo;
  end;
end;

procedure TForm3.UpdateKindleInfo;
begin
  if FKindleInfo.sn <> '' then
  begin
    lbSNVal.Caption := FKindleInfo.sn;
    lbPassVal.Caption := FKindleInfo.recovery_pass;
    lbModelVal.Caption := GetKindleModelFromSN(FKindleInfo.sn);
    lbDriveLetterVal.Caption := FKindleInfo.Drive;
  end else begin
    lbSNVal.Caption := '---';
    lbPassVal.Caption := '---';
    lbModelVal.Caption := '---';
    lbDriveLetterVal.Caption := '---';
  end;
end;

procedure TForm3.FindKindleDrive;
var
  i:char;
  DriveType: Cardinal;
  hVolume, hDrive: Cardinal;
  VolumeStorageDevNumber, DriveStorageDevNumber: STORAGE_DEVICE_NUMBER;
  nBytes, rBytes: Cardinal;
  PnPHandle: HDEVINFO;
  dia: TSPDeviceInterfaceData;
  didd: PSPDeviceInterfaceDetailData;
  drive_path: string;
  MemberIndex: Cardinal;
  DevData: TSPDevInfoData;
begin
  for i := 'C' to 'Z' do
  begin
    drive_path := i+':\';
    DriveType := GetDriveType(PWideChar(drive_Path));
    if DriveType = DRIVE_REMOVABLE then
    begin
      drive_path := '\\.\'+i+':';
      hVolume := CreateFile(PWideChar(drive_path),0,FILE_SHARE_READ OR FILE_SHARE_WRITE ,nil,OPEN_EXISTING,0,0);
      if( hVolume = INVALID_HANDLE_VALUE ) then continue;
      try
        if DeviceIoControl(hVolume,IOCTL_STORAGE_GET_DEVICE_NUMBER,nil,0,@VolumeStorageDevNumber,sizeof(STORAGE_DEVICE_NUMBER),nBytes,nil) then
        begin
          PnPHandle := SetupDiGetClassDevs(@GUID_DEVINTERFACE_DISK, nil, 0, DIGCF_PRESENT or DIGCF_DEVICEINTERFACE);
          if DWORD(PnPHandle) = INVALID_HANDLE_VALUE then continue; // Skip to next drive
          try
            dia.cbSize := sizeof(TSPDeviceInterfaceData);
            MemberIndex := 0;
            while SetupDiEnumDeviceInterfaces(PnPHandle,nil,GUID_DEVINTERFACE_DISK,MemberIndex,dia) do
            begin
              inc(MemberIndex);
              SetupDiGetDeviceInterfaceDetail(PnPHandle,@dia,nil,0,rBytes,nil);
              getMem(didd, rBytes+sizeof(TSPDeviceInterfaceDetailData));
              try
                didd^.cbSize := sizeof(TSPDeviceInterfaceDetailData);
                DevData.cbSize := sizeof(TSPDevInfoData);
                if not SetupDiGetDeviceInterfaceDetail(PnPHandle,@dia,didd,rBytes,nBytes,@devData) then
                  raiseLastOsError;
                hDrive := CreateFile(didd^.DevicePath,0,FILE_SHARE_READ OR FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                if( hDrive = INVALID_HANDLE_VALUE ) then continue;
                try
                  if DeviceIoControl(hDrive,IOCTL_STORAGE_GET_DEVICE_NUMBER,nil,0,@DriveStorageDevNumber,sizeof(STORAGE_DEVICE_NUMBER),nBytes,nil) then
                  begin
                    if DriveStorageDevNumber.DeviceNumber = VolumeStorageDevNumber.DeviceNumber then
                    begin
                      FKindleInfo.Drive := i;
                      FKindleInfo.DrivePath := PWideChar(@didd^.DevicePath);
                      exit;
                    end;
                  end;
                finally
                  CloseHandle(hDrive);
                end;
              finally
                FreeMem(didd);
              end;
            end;
          finally
            SetupDiDestroyDeviceInfoList(PnPHandle);
          end;
        end;
      finally
        CloseHandle(hVolume);
      end;
    end;
  end;
end;

procedure TForm3.EjectKindleInWin7;
var
  hVolume: Cardinal;
  szVal: Cardinal;
  prevent: PREVENT_MEDIA_REMOVAL;
begin
  hVolume := CreateFile(PWideChar('\\.\'+FKindleInfo.Drive+':'),GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ OR FILE_SHARE_WRITE, nil,OPEN_EXISTING,0,0);
  if hVolume <> INVALID_HANDLE_VALUE then
    if DeviceIoControl(hVolume,FSCTL_LOCK_VOLUME,nil,0,nil,0,szVal,nil) then
    begin
      DeviceIoControl(hVolume,FSCTL_DISMOUNT_VOLUME,nil ,0,nil,0,szVal,nil);
      Prevent.PreventMediaRemoval := FALSE;
      DeviceIoControl(hVolume,IOCTL_STORAGE_MEDIA_REMOVAL,@Prevent,sizeof(PREVENT_MEDIA_REMOVAL),nil,0,szVal,nil);
      DeviceIoControl(hVolume,IOCTL_STORAGE_EJECT_MEDIA, nil,0,nil,0,szVal,nil);
      DeviceIoControl(hVolume,FSCTL_UNLOCK_VOLUME,nil,0 ,nil,0,szVal,nil);
    end;
  CloseHandle(hVolume);
end;

end.
