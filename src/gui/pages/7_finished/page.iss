// © Kotyarko_O, 2020 \\

[CustomMessages]
en.finishedPageTasksText=Extended Setup tasks:
ru.finishedPageTasksText=Дополнительные задачи установщика:
en.createUninstallIconButtonText=Create modpack uninstall shortcut icon on desktop
ru.createUninstallIconButtonText=Создать ярлык на рабочем столе для быстрой деинсталляции сборки
en.launchGameButtonText=Launch game client (WorldOfTanks.exe) after Setup finished
ru.launchGameButtonText=Запустить игру (WorldOfTanks.exe) после закрытия установщика

[Icons]
Name: "{uninstallexe}\..\{cm:UninstallProgram,{cm:AppName}}"; Filename: "{uninstallexe}"; WorkingDir: "{uninstallexe}\..\"; Comment: "{cm:UninstallProgram,{cm:AppName}}."; IconFilename: "{uninstallexe}";

[Code]
Var
 FinishedPage: TWizardPage;
 FinishedPageTasks: TLabel;
 FinishedBgShape1: TBevel;
 CBCreateUninstallIcon, CBGameLaunch: Longint;

<event('CurPageChanged')>
Procedure FinishedPageOnActivate(CurPageID: Integer);
begin
 if CurPageID <> FinishedPage.ID then Exit;
 BringToFrontAndRestore;
 WizardForm.BackButton.Visible := False;
 WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish);
 WizardForm.CancelButton.Visible := False;
 WizardForm.NextButton.Left := WizardForm.CancelButton.Left;
end;

<event('NextButtonClick')>
Function FinishedPageOnNextButtonClick(CurPageID: Integer): Boolean;
var
 ErrorCode: Integer;
 UninstallLnk: String;
begin
 Result := True;
 if CurPageID <> FinishedPage.ID then Exit;
 UninstallLnk := ExpandConstant('{userdesktop}\{cm:UninstallProgram,{cm:AppName}}.lnk');
 if FileExists(UninstallLnk) then
  DeleteFile(UninstallLnk);
 if CheckBoxGetChecked(CBCreateUninstallIcon) then
  FileCopy(ExpandConstant('{uninstallexe}\..\{cm:UninstallProgram,{cm:AppName}}.lnk'), UninstallLnk, False);
 if CheckBoxGetChecked(CBGameLaunch) then
  ShellExec('', 'WorldOfTanks.exe', '', ExpandConstant('{app}'), SW_SHOW, ewNoWait, ErrorCode);
end;

<event('CurUninstallStepChanged')>
procedure FinishedUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
 if CurUninstallStep = usUninstall then
  DeleteFile(ExpandConstant('{userdesktop}\{cm:UninstallProgram,{cm:AppName}}.lnk'));
end;

<event('InitializeWizard')>
Procedure InitializeFinishedPage();
begin
 FinishedPage := CreateCustomPage(wpInstalling, '', '');

 FinishedPageTasks := TLabel.Create(FinishedPage);
 with FinishedPageTasks do begin
  Parent := FinishedPage.Surface;
  SetBounds(ScaleX(16), ScaleY(8 + 8), 0, 0);
  Font.Size := 11;
  Font.Style := [fsBold];
 end;

 FinishedPageTasks.Caption := CustomMessage('createUninstallIconButtonText');
 CBCreateUninstallIcon := CheckBoxCreate(
  FinishedPage.Surface.Handle,
  ScaleX(22),
  FinishedPageTasks.Top + FinishedPageTasks.Height + ScaleY(8),
  FinishedPageTasks.Width,
  ScaleY(22),
  'data\img\gui\window\checkBox.png', 0, 2);
 CheckBoxSetText(CBCreateUninstallIcon, FinishedPageTasks.Caption);
 CheckBoxSetFont(CBCreateUninstallIcon, BotvaFont.Handle);
 CheckBoxSetFontColor(CBCreateUninstallIcon, clWhite, $CCCCCC, $D9D9D9, clGray);
 CheckBoxSetChecked(
  CBCreateUninstallIcon, FileExists(ExpandConstant('{userdesktop}\{cm:UninstallProgram,{cm:AppName}}.lnk')));

 FinishedPageTasks.Caption := CustomMessage('launchGameButtonText');
 CBGameLaunch := CheckBoxCreate(
  FinishedPage.Surface.Handle,
  ScaleX(22),
  FinishedPageTasks.Top + FinishedPageTasks.Height + ScaleY(8 + 22 + 8),
  FinishedPageTasks.Width,
  ScaleY(22),
  'data\img\gui\window\checkBox.png', 0, 2);
 CheckBoxSetText(CBGameLaunch, FinishedPageTasks.Caption);
 CheckBoxSetFont(CBGameLaunch, BotvaFont.Handle);
 CheckBoxSetFontColor(CBGameLaunch, clWhite, $CCCCCC, $D9D9D9, clGray);
 FinishedPageTasks.Caption := CustomMessage('finishedPageTasksText');

 FinishedBgShape1:=TBevel.Create(FinishedPage);
 with FinishedBgShape1 do begin
  Parent := FinishedPage.Surface;
  Shape := bsFrame;
  SetBounds(
   ScaleX(8),
   ScaleY(8),
   WizardForm.ClientWidth - ScaleX(16),
   FinishedPageTasks.Top + FinishedPageTasks.Height + ScaleY(8 + 22 + 8 + 22));
 end;

 FinishedFilesLog := TNewListBox.Create(FinishedPage);
 with FinishedFilesLog do begin
  Parent := FinishedPage.Surface;
  BorderStyle := bsSingle;
  Font.Size := 7;
  Font.Style := [];
  Style := lbStandard;
  Left := FinishedBgShape1.Left;
  Top := FinishedBgShape1.Top + FinishedBgShape1.Height + ScaleY(8);
  Width := FinishedBgShape1.Width;
  Height := WizardForm.InnerNotebook.Height - Top;
 end;
end;