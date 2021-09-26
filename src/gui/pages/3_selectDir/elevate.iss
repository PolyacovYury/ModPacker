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
  ElevateMarquee: TOutputMarqueeProgressWizardPage;
  ElevateMarqueeText: TLabel;

function IsWinVista: Boolean;
begin
  Result := (GetWindowsVersion >= $06000000);
end;

function HaveWriteAccessToApp: Boolean;
var
  FileName: string;
begin
  FileName := AddBackslash(WizardDirValue) + 'write_test.tmp';
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

procedure ElevateIfNeeded();
begin
  if IsWinVista() then
    if not HaveWriteAccessToApp() then
      if not Elevate() then
        ElevateFailed := True;
end;

<event('InitializeWizard')>
procedure _Elevate__InitializeWizard;
begin
 Elevated := CMDCheckParams('/ELEVATE');
 ElevateFailed := False;
 ElevateMarquee := CreateOutputMarqueeProgressPage('', '');
 with ElevateMarquee do begin
  Msg1Label.Visible := False;
  Msg2Label.Visible := False;
 end;
 ElevateMarqueeText := TLabel.Create(ElevateMarquee);
 with ElevateMarqueeText do begin
  Parent := ElevateMarquee.Surface;
  Alignment := taCenter;
  WordWrap := True;
  AutoSize := True;
  Color := clWhite;
  Font.Size := 12;
  Font.Style := [fsBold];
  Top := ScaleY(8);
  Width := Parent.ClientWidth - ScaleY(16);
  Caption := CustomMessage('AccessDeniedLaunchingElevated');
  Left := (Parent.ClientWidth - Width) div 2;
 end;
 with ElevateMarquee.ProgressBar do begin
  Top := ElevateMarqueeText.Top + ElevateMarqueeText.Height + ScaleY(16);
 end;
end;

<event('CurPageChanged')>
procedure _Elevate__CurPageChanged(PageID: Integer);
begin
 if Elevated then begin
  if (
    (PageID = wpWelcome) or (PageID = wpLicense) or (PageID = wpSelectDir) or (PageID = wpInfoBefore)
    or (PageID = WelcomePage.ID)
  ) then begin
   WizardForm.NextButton.OnClick(WizardForm.NextButton);
  end else begin
   Elevated := False;
  end;
 end;
 if PageID <> wpSelectDir then exit;
 if (WizardForm.ComponentsList.Items.Count = 0) then
  WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall);
end;

<event('BackButtonClick')>
function _Elevate__BackButtonClick(PageID: Integer): Boolean;
begin
 Result := True;
 if PageID <> wpSelectDir then Exit;
 if ElevateFailed then begin
  Result := False;
  ElevateFailed := False;
  WizardForm.NextButton.Enabled := True;
  ElevateMarquee.Hide();
 end;
end;

procedure ElevateAnim();
begin
 ElevateMarquee.Animate();
 AppProcessMessage();
end;

<event('NextButtonClick')>
function _Elevate__NextButtonClick(PageID: Integer): Boolean;
begin
 Result := True;
 if PageID <> wpSelectDir then Exit;
 if Elevated then Exit;
 try
  ElevateAnimTimer := SetTimer(0, 0, 50, CreateCallback(@ElevateAnim));
  ElevateMarquee.Show();
  ElevateIfNeeded();
 finally
  Result := not ElevateFailed;
  KillTimer(0, ElevateAnimTimer);
  ElevateMarquee.Hide();
  if not Result then begin
   MsgBox(CustomMessage('AccessDenied'), mbError, MB_OK);
   BringToFrontAndRestore;
  end;
 end;
end;
