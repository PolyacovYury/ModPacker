// © Kotyarko_O, 2020 \\

#include "findwot.iss"

//wpSelectDir page is skipped (see "ShouldSkipPage" below)
//so, {app} will defined with static path ([Setup]-setting)
//it's recommended to use only WizardForm.DirEdit.Text and WizardDirValue() in SelectDirPage

[CustomMessages]
en.applicationWrongDir=Selected install directory%nis not a World of Tanks client root directory.%n%nPlease, select a World of Tanks root directory%n(contains folders like "mods" and "res_mods").
ru.applicationWrongDir=Выбранная папка установки не является%nкорневой папкой клиента игры World of Tanks.%n%nПожалуйста, выберите корневую папку World of Tanks%n(содержит такие папки, как "mods" и "res_mods").
en.applicationIncompleteType=Game client installation/update must be finished before continuing this Setup.
ru.applicationIncompleteType=Необходимо завершить установку/обновление клиента, прежде чем продолжить установку.
en.applicationPatchIncompatible=Incompatible game client version: %s%nThis Setup requires version {#GameVersion}
ru.applicationPatchIncompatible=Неподходящая версия установленного клиента: %s%nСборка предназначена для патча {#GameVersion}

en.cleanProfileButtonText=Clear game client profile (reset client settings and caches).
ru.cleanProfileButtonText=Очистка профиля игрового клиента (сброс индивидуальных настроек и кэша).

[Files]
Source: "data\img\gui\pages\3_selectDir\directory.png"; DestDir: "data\img\gui\pages\3_selectDir\"; Flags: dontcopy;


[Code]
Var
 SelectDirPage: TWizardPage;
 DiskSpaceLabel: TLabel;
 SelectDirPageImg, CBCleanProfile: Longint;
 DirBgShape1: TBevel;
 InfoBeforeRichViewer: TRichEditViewer;

Procedure SetSelectDirPageVisibility(Value: Boolean);
begin
 ImgSetVisibility(SelectDirPageImg, Value);
 DiskSpaceLabel.Visible := Value;
 WOTList.Visible := Value;
 DirBrowseButton.Visible := Value;
 CheckBoxSetVisibility(CBCleanProfile, Value);
 DirBgShape1.Visible := Value;
 InfoBeforeRichViewer.Visible := Value;
 ImgApplyChanges(WizardForm.Handle);
end;

Procedure SelectDirPageOnActivate(Sender: TWizardPage);
begin
 InitializeFindWOT();
 SetSelectDirPageVisibility(True);
end;

Function SelectDirPageOnBackButtonClick(Sender: TWizardPage): Boolean;
begin
 Result := True;
 SetSelectDirPageVisibility(False);
end;

Function SelectDirPageOnNextButtonClick(Sender: TWizardPage): Boolean;
var
 PatchVersion, AppType: String;
begin
 Result := True;
 if CMDCheckParams(CMD_NoSearchGameFiles) then begin
  SetSelectDirPageVisibility(False);
  Exit;
 end;
 if not FilesExists([WizardDirValue() + '\WorldOfTanks.exe', WizardDirValue() + '\version.xml', WizardDirValue() + '\app_type.xml']) then begin
  //MsgBoxEx(WizardForm.Handle, CustomMessage('applicationWrongDir'), CustomMessage('warning'), MB_OK or MB_ICONWARNING, 0, 0);
  MsgBox(CustomMessage('applicationWrongDir'), mbError, MB_OK);
  Result := False;
 end else begin
  XMLFileReadValue(WizardDirValue() + '\app_type.xml', 'protocol\app_type', AppType);
  Result := AppType <> 'incomplete';
  if not Result then
   //MsgBoxEx(WizardForm.Handle, CustomMessage('applicationIncompleteType'), CustomMessage('warning'), MB_ICONWARNING or MB_OK, 0, 0)
   MsgBox(CustomMessage('applicationIncompleteType'), mbError, MB_OK)
  else begin
   XMLFileReadValue(WizardDirValue() + '\version.xml', 'version.xml\version', PatchVersion);
   Delete(PatchVersion, Pos('v', PatchVersion), 2);
   Delete(PatchVersion, Pos('#', PatchVersion) - 1, 10);
   Result := CompareStr(PatchVersion, '{#GameVersion}') = 0;
   if not Result then
    //MsgBoxEx(WizardForm.Handle, Format(CustomMessage('applicationPatchIncompatible'), [PatchVersion]), CustomMessage('warning'), MB_OK or MB_ICONWARNING, 0, 0);
    MsgBox(Format(CustomMessage('applicationPatchIncompatible'), [PatchVersion]), mbError, MB_OK);
  end;
 end;
 if Result then
  SetSelectDirPageVisibility(False);
end;

<event('ShouldSkipPage')>
Function SelectDirShouldSkipPage(CurPageID: Integer): Boolean;
begin
 Result := False;
 case CurPageID of
  wpSelectDir: Result := True;
 end;
end;

<event('InitializeWizard')>
Procedure InitializeSelectDirPage();
var
  RTFStr: AnsiString;
begin
 SelectDirPage := CreateCustomPage(LicensePage.ID, '', '');
 with SelectDirPage do begin
  OnActivate := @SelectDirPageOnActivate;
  OnBackButtonClick := @SelectDirPageOnBackButtonClick;
  OnNextButtonClick := @SelectDirPageOnNextButtonClick;
 end;

 SelectDirPageImg := ImgLoad(WizardForm.Handle, 'data\img\gui\pages\3_selectDir\directory.png', ScaleX(16), ScaleY(80 + 24), ScaleX(80), ScaleY(80), True, True);

 DiskSpaceLabel := TLabel.Create(SelectDirPage);
 with DiskSpaceLabel do begin
  Parent := WizardForm;
  SetBounds(ScaleX(80 + 8), ScaleY(80 + 20), 0, 0);
  AutoSize := True;
  Transparent := True;
  Font.Size := 10;
  Caption := WizardForm.DiskSpaceLabel.Caption;
 end;

//FindWOT
 WOTList := TComboBox.Create(SelectDirPage);
 with WOTList do begin
  Parent := WizardForm;
  SetBounds(DiskSpaceLabel.Left, DiskSpaceLabel.Top + DiskSpaceLabel.Height + ScaleY(12), ScaleX(480), WizardForm.DirEdit.Height + ScaleY(5));
  Font.Size := 9;
  OnChange := @WOTListOnChange;
 end;

 DirBrowseButton := TButton.Create(SelectDirPage);
 with DirBrowseButton do begin
  Parent := WizardForm;
  SetBounds(WOTList.Left + WOTList.Width + ScaleX(10), WOTList.Top, ScaleX(85), WizardForm.DirBrowseButton.Height);
  Caption := WizardForm.DirBrowseButton.Caption;
  OnClick := @WOTListOnChange;
 end;
//FindWOT end

 DiskSpaceLabel.Caption := CustomMessage('cleanProfileButtonText');
 CBCleanProfile := CheckBoxCreate(WizardForm.Handle, WOTList.Left, WOTList.Top + WOTList.Height + ScaleY(8), DiskSpaceLabel.Width + ScaleX(22), ScaleY(22), 'data\img\gui\window\checkBox.png', 0, 2);
  CheckBoxSetText(CBCleanProfile, DiskSpaceLabel.Caption);
  CheckBoxSetFont(CBCleanProfile, BotvaFont.Handle);
  CheckBoxSetFontColor(CBCleanProfile, clWhite, $CCCCCC, $D9D9D9, clGray);

 DiskSpaceLabel.Caption := WizardForm.DiskSpaceLabel.Caption;
 DirBgShape1:=TBevel.Create(WizardForm);
 with DirBgShape1 do begin
  Parent := WizardForm;
  Shape := bsFrame;
  SetBounds(ScaleX(8), ScaleY(80 + 8), WizardForm.ClientWidth - ScaleX(16), ScaleY(80 + 24));
 end;
 if not FileExists(ExpandConstant('{tmp}\' + Format('data\lang\%s\info_before.rtf', [ActiveLanguage()]))) then
  ExtractTemporaryFiles(Format('data\lang\%s\info_before.rtf', [ActiveLanguage()]));
 LoadStringFromFile(ExpandConstant('{tmp}\' + Format('data\lang\%s\info_before.rtf', [ActiveLanguage()])), RTFStr);
 InfoBeforeRichViewer := TRichEditViewer.Create(WizardForm);
 with InfoBeforeRichViewer do begin
  Parent := WizardForm;
  BorderStyle := bsSingle;
  TabStop := False;
  ReadOnly := True;
  BorderStyle := bsSingle;
  BevelKind := bkTile;
  Color := clGray;
  Font.Size := 14;
  ScrollBars := ssVertical;
  SetBounds(ScaleX(8), DirBgShape1.Top + DirBgShape1.Height + ScaleY(16), WizardForm.ClientWidth - ScaleX(16), ScaleY(477 - 16) - DirBgShape1.Top - DirBgShape1.Height);
  RTFText := RTFStr;
 end;
 SetSelectDirPageVisibility(False);
end;