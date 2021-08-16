[Code]
// https://stackoverflow.com/a/35435534

var
  Elevated: Boolean;
  ElevateFailed: Boolean;

function CmdLineParamExists(const Value: string): Boolean;
var
  I: Integer;  
begin
  Result := False;
  for I := 1 to ParamCount do
    if CompareText(ParamStr(I), Value) = 0 then begin
      Result := True;
      Exit;
    end;
end;

function IsWinVista: Boolean;
begin
  Result := (GetWindowsVersion >= $06000000);
end;

function HaveWriteAccessToApp: Boolean;
var
  FileName: string;
begin
  FileName := AddBackslash(WizardDirValue) + 'writetest.tmp';
  Result := SaveStringToFile(FileName, 'test', False);
  if Result then begin
    Log(Format('Write access to the last installation path provided: [%s]', [WizardDirValue]));
    DeleteFile(FileName);
  end else
    Log(Format('Write access to the last installation path not provided: [%s]', [WizardDirValue]));
end;

procedure ExitProcess(uExitCode: UINT);
  external 'ExitProcess@kernel32.dll stdcall';
function ShellExecute(hwnd: HWND; lpOperation: string; lpFile: string;
  lpParameters: string; lpDirectory: string; nShowCmd: Integer): THandle;
  external 'ShellExecuteW@shell32.dll stdcall';

function Elevate: Boolean;
var
  I: Integer;
  RetVal: Integer;
  Params: string;
  S: string;
begin
  for I := 1 to ParamCount do begin  // Collect current instance parameters
    S := ParamStr(I);
    if CompareText(Copy(S, 1, 5), '/LOG=') = 0 then  // Unique log file name for the elevated instance
      S := S + '-elevated';
    if CompareText(Copy(S, 1, 5), '/SL5=') <> 0 then  // Do not pass our /SL5 switch
      Params := Params + AddQuotes(S) + ' ';
  end;

  Params := Params + '/LANG=' + ActiveLanguage + ' /DIR="' + WizardDirValue + '" /ELEVATE'

  Log(Format('Elevating setup with parameters [%s]', [Params]));
  RetVal := ShellExecute(0, 'runas', ExpandConstant('{srcexe}'), Params, '', SW_SHOW);
  Log(Format('Running elevated setup returned [%d]', [RetVal]));
  Result := (RetVal > 32);
  if Result then begin  // if elevated executing of this setup succeeded, then...
    Log('Elevation succeeded');
    ExitProcess(0);  //exit this non-elevated setup instance
  end else
    Log(Format('Elevation failed [%s]', [SysErrorMessage(RetVal)]));
end;

procedure ElevateIfNeeded;
begin
  if not IsWinVista then
    Log(Format('This version of Windows [%x] does not support elevation', [GetWindowsVersion]))
  else if IsAdminInstallMode then begin
    Log('Running elevated');
    Log(WizardDirValue);
  end else begin
    Log('Running non-elevated');
    if not HaveWriteAccessToApp then
      if not Elevate then
        ElevateFailed := True;
  end;
end;

<event('InitializeWizard')>
procedure _Elevate__InitializeWizard;
begin
  Elevated := CmdLineParamExists('/ELEVATE');
  ElevateFailed := False;
end;

<event('ShouldSkipPage')>
function _Elevate__ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
  if ((PageID = wpSelectDir) or (PageID = wpWelcome) or (PageID = wpLicense) or (PageID = wpInfoBefore)) and Elevated then
    Result := True;
end;


<event('CurPageChanged')>
procedure _Elevate__CurPageChanged(CurPageID: Integer);
begin
  if ((CurPageID = wpSelectDir) and (WizardForm.ComponentsList.Items.Count = 0)) then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall);
end;

<event('NextButtonClick')>
function _Elevate__NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (CurPageID = wpSelectDir) and not Elevated then
    ElevateIfNeeded;
end;

<event('PrepareToInstall')>
function _Elevate__PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  if ElevateFailed then
    Result := CustomMessage('AccessDenied');
end;

[CustomMessages]
en.AccessDenied=Could not get write access to install directory.
ru.AccessDenied=Не удалось получить доступ к папке установки.
