// https://stackoverflow.com/a/35435534
[CustomMessages]
en.AccessDenied=Could not get write access to install directory.
ru.AccessDenied=Не удалось получить доступ к папке установки.
en.AccessDeniedLaunchingElevated=Could not get write access to install directory.%nAttempting to re-launch with admin privileges.%nPlease, wait.
ru.AccessDeniedLaunchingElevated=Не удалось получить доступ к папке установки.%nПроизводится попытка перезапустить установку от имени администратора.%nПожалуйста, подождите.

[Code]
var
  Elevated: Boolean;
  ElevateFailed: Boolean;
  ElevateAnimTimer: LongWord;
  ElevateMemo: TMemo;

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
  if Result then begin  // if elevated executing of this setup succeeded
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
  if (
    (PageID = wpWelcome) or (PageID = wpLicense) or (PageID = wpSelectDir) or (PageID = wpInfoBefore)
    or (PageID = WelcomePage.ID)
  ) and Elevated then
   Result := True;
end;

<event('CurPageChanged')>
procedure _Elevate__CurPageChanged(CurPageID: Integer);
begin
 if CurPageID <> wpSelectDir then exit;
 if ElevateMemo <> nil then
  ElevateMemo.Visible := False;
 if (WizardForm.ComponentsList.Items.Count = 0) then
  WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall);
end;

<event('BackButtonClick')>
function _Elevate__BackButtonClick(CurPageID: Integer): Boolean;
begin
 Result := True;
 if CurPageID <> wpSelectDir then Exit;
 if ElevateFailed then begin
  Result := False;
  ElevateFailed := False;
  WizardForm.NextButton.Enabled := True;
 end;
 if ElevateMemo <> nil then
  ElevateMemo.Visible := False;
end;

<event('NextButtonClick')>
function _Elevate__NextButtonClick(CurPageID: Integer): Boolean;
begin
 Result := True;
 if CurPageID <> wpSelectDir then Exit;
 if Elevated then exit;
 try
  ElevateAnimTimer := SetTimer(0, 0, 50, CreateCallback(@AppProcessMessage));
  WizardForm.BackButton.Enabled := False;
  WizardForm.NextButton.Enabled := False;
  WizardForm.CancelButton.Enabled := False;
  ElevateMemo := TMemo.Create(WizardForm.SelectDirPage);
  with ElevateMemo do begin
   Parent := WizardForm.SelectDirPage;
   Left := ScaleX(8);
   Top := ScaleY(8);
   Width := WizardForm.ClientWidth - Left * 2;
   Height := WizardForm.InnerNotebook.Height - Top;
   ReadOnly := True;
   HideSelection := True;
   Alignment := taCenter;
   BorderStyle := bsNone;
   Text := CustomMessage('AccessDeniedLaunchingElevated');
   Font.Color := clWhite;
   Font.Size := 12;
   Font.Style := [fsBold];
   Visible := True;
  end;
  ElevateIfNeeded;
 finally
  Result := not ElevateFailed;
  KillTimer(0, ElevateAnimTimer);
  WizardForm.BackButton.Enabled := True;
  WizardForm.CancelButton.Enabled := True;
  if ElevateFailed then begin
   ElevateMemo.Text := CustomMessage('AccessDenied');
  end else begin
   WizardForm.NextButton.Enabled := True;
   ElevateMemo.Visible := False;
  end;
 end;
end;
