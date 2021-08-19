[CustomMessages]
en.AccessDenied=Could not get write access to install directory.
ru.AccessDenied=Не удалось получить доступ к папке установки.

[Code]
// https://stackoverflow.com/a/35435534

var
  Elevated: Boolean;
  ElevateFailed: Boolean;

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
  if Result then
    DeleteFile(FileName);
end;

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
  if IsWinVista then
    if not HaveWriteAccessToApp then
      if not Elevate then
        ElevateFailed := True;
end;

<event('InitializeWizard')>
procedure _Elevate__InitializeWizard;
begin
  Elevated := CMDCheckParams('/ELEVATE');
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
