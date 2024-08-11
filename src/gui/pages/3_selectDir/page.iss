// © Kotyarko_O, 2020 \\

[CustomMessages]
en.applicationNotFound=Required World of Tanks files not found in the chosen directory.
ru.applicationNotFound=Необходимые файлы World of Tanks не найдены в выбранной папке.
en.applicationPatchIncompatible=Incompatible game client version: %s%nThis Setup requires version {code:GameVersion}.
ru.applicationPatchIncompatible=Неподходящая версия установленного клиента: %s%nСборка предназначена для патча {code:GameVersion}.

en.cleanProfileButtonText=Clear game client profile (reset client settings and caches)
ru.cleanProfileButtonText=Очистить папку профиля игрового клиента (сброс индивидуальных настроек и кэша)

[Files]
Source: "data\img\gui\pages\3_selectDir\directory.png"; DestDir: "data\img\gui\pages\3_selectDir\"; Flags: ignoreversion nocompression dontcopy;

[Code]
Var
 SelectDirPageImg, CBCleanProfile: Longint;
 SelectedWOTVersion: String;
 SelectedWOTIdx: Integer;
 IsWizardInitStarted: Boolean;
 DirWOTList: TNewComboBox;
 DirBrowseButton: TButton;
 DirBgShape1: TBevel;
 FAQRTFViewer: TRichEditViewer;
 FAQRTFStr: AnsiString;

Procedure WOTListAddClient(ClientPath: String);
var
 Index: Integer;
begin
 if Length(ClientPath) = 0 then begin
  DirWOTList.ItemIndex := -1;
  Exit;
 end;
 Index := WOT_AddClientW(ClientPath);
 if Index >= 0 then begin
  WotList_AddClient(DirWOTList, ClientPath);
 end else begin
  MsgBox(CustomMessage('applicationNotFound'), mbError, MB_OK);
  if DirWOTList.Items.Strings[0] <> SetupMessage(msgWizardSelectDir) then
   DirWOTList.ItemIndex := 0;
 end;
end;

Procedure WOTListOnChange(Sender: TObject);
var
 UnicodeStr: string;
begin
 if (
   (Sender = DirBrowseButton) or (Sender = DirWOTList)
 ) then begin
  WotList_OnChange(DirWOTList);
 end;
 UnicodeStr := String(FAQRTFStr);
 StringChangeEx(UnicodeStr, '{code:GameVersion}', ExpandConstant('{code:GameVersion}'), True);
 StringChangeEx(UnicodeStr, '{WOT_dir_basename}', ExtractFileName(WizardDirValue()), True);
 FAQRTFViewer.RTFText := AnsiString(UnicodeStr);
 if not WotList_Selected_VersionMatch(DirWOTList, ExpandConstant('{code:GameVersion}')) then
  MsgBox(ExpandConstant(Format(
   CustomMessage('applicationPatchIncompatible'), [WOT_GetClientVersionW(DirWOTList.ItemIndex)]
  )), mbError, MB_OK);
end;

<event('CurPageChanged')>
Procedure SelectDirPageOnActivate(PageID: Integer);
begin
 if PageID <> wpSelectDir then Exit;
 WOT_LauncherSetDefault(4);
 WotList_Update(DirWOTList);
 WOTListAddClient(WizardForm.DirEdit.Text);
 if DirWOTList.ItemIndex = -1 then
  DirWOTList.ItemIndex := 0;
 DirWOTList.OnChange(DirWOTList);
end;

<event('NextButtonClick')>
Function SelectDirPageOnNextButtonClick(PageID: Integer): Boolean;
begin
 Result := True;
 if PageID <> wpSelectDir then Exit;
 Result := WotList_Selected_VersionMatch(DirWOTList, ExpandConstant('{code:GameVersion}'));
 if not Result then
  MsgBox(ExpandConstant(Format(
   CustomMessage('applicationPatchIncompatible'), [WOT_GetClientVersionW(DirWOTList.ItemIndex)]
  )), mbError, MB_OK);

 Result := Result and CheckForGameRun(DirWOTList);
end;

<event('PrepareToInstall')>
function _CheckForWot__PrepareToInstall(var NeedsRestart: Boolean): String;
begin
 if not CheckForGameRun(DirWOTList) then
   Result := CustomMessage('AccessDenied');
end;

<event('InitializeWizard')>
Procedure InitializeSelectDirPage();
var
 DefDir, S: String;
begin
 DefDir := ExpandConstant('{param:DIR|}');
 if DefDir <> '' then
  WizardForm.DirEdit.Text := DefDir
 else begin
  S := '';
  if RegQueryStringValue(HKLM, '{#UninstallReg}', '{#UninstallPathReg}', S) or
     RegQueryStringValue(HKCU, '{#UninstallReg}', '{#UninstallPathReg}', S) then begin
   DefDir := StripAndCheckExists(S, True);
   if DefDir = '' then begin // WoT folder was deleted entirely
    RegDeleteKeyIncludingSubkeys(HKLM, '{#UninstallReg}');
    RegDeleteKeyIncludingSubkeys(HKCU, '{#UninstallReg}');
   end;
  end;
  WizardForm.DirEdit.Text := DefDir;
 end;

 WizardForm.DirEdit.Visible := False;
 WizardForm.SelectDirLabel.Visible := False;
 WizardForm.SelectDirBrowseLabel.Visible := False;
 WizardForm.SelectDirBitmapImage.Visible := False;

 SelectDirPageImg := ImgLoad(
  WizardForm.SelectDirPage.Handle,
  'data\img\gui\pages\3_selectDir\directory.png',
  ScaleX(16),
  ScaleY(24),
  ScaleX(80), ScaleY(80), True, True);

 with WizardForm.DiskSpaceLabel do begin
  AutoSize := True;
  Font.Size := 10;
  Left := ScaleX(80 + 8);
  Top := ScaleY(8 + 12);
 end;

 DirWOTList := TNewComboBox.Create(WizardForm.SelectDirPage);
 with DirWOTList do begin
  Parent := WizardForm.SelectDirPage;
  SetBounds(
   WizardForm.DiskSpaceLabel.Left,
   WizardForm.DiskSpaceLabel.Top + WizardForm.DiskSpaceLabel.Height + ScaleY(12),
   ScaleX(480),
   WizardForm.DirBrowseButton.Height);
  Font.Size := 9;
  OnChange := @WOTListOnChange;
 end;

 DirBrowseButton := TButton.Create(WizardForm.SelectDirPage);
 with DirBrowseButton do begin
  Parent := WizardForm.SelectDirPage;
  SetBounds(
   DirWOTList.Left + DirWOTList.Width + ScaleX(10),
   DirWOTList.Top,
   ScaleX(85),
   WizardForm.DirBrowseButton.Height);
  Caption := WizardForm.DirBrowseButton.Caption;
  OnClick := @WOTListOnChange;
 end;
 WizardForm.DirBrowseButton.Visible := False;

 WizardForm.SelectDirBrowseLabel.Caption := CustomMessage('cleanProfileButtonText');
 CBCleanProfile := CheckBoxCreate(
  WizardForm.SelectDirPage.Handle,
  DirWOTList.Left,
  DirWOTList.Top + DirWOTList.Height + ScaleY(8),
  WizardForm.SelectDirBrowseLabel.Width + ScaleX(22),
  ScaleY(22),
  'data\img\gui\window\checkBox.png', 0, 2);
 CheckBoxSetText(CBCleanProfile, WizardForm.SelectDirBrowseLabel.Caption);
 CheckBoxSetFont(CBCleanProfile, BotvaFont.Handle);
 CheckBoxSetFontColor(CBCleanProfile, clWhite, $CCCCCC, $D9D9D9, clGray);

 DirBgShape1:=TBevel.Create(WizardForm.SelectDirPage);
 with DirBgShape1 do begin
  Parent := WizardForm.SelectDirPage;
  Shape := bsFrame;
  SetBounds(
   ScaleX(8),
   ScaleY(8),
   WizardForm.ClientWidth - ScaleX(16),
   DirWOTList.Top + DirWOTList.Height + ScaleY(8) + ScaleY(22) + ScaleY(6));
 end;

 if not FileExists(ExpandConstant('{tmp}\' + Format('data\lang\%s\info_before.rtf', [ActiveLanguage()]))) then
  ExtractTemporaryFiles(Format('data\lang\%s\info_before.rtf', [ActiveLanguage()]));
 LoadStringFromFile(ExpandConstant('{tmp}\' + Format('data\lang\%s\info_before.rtf', [ActiveLanguage()])), FAQRTFStr);
 FAQRTFViewer := TRichEditViewer.Create(WizardForm.SelectDirPage);
 with FAQRTFViewer do begin  // WizardForm.InfoBeforeMemo refuses to work properly
  Parent := WizardForm.SelectDirPage;
  BorderStyle := bsSingle;
  TabStop := False;
  ReadOnly := True;
  BorderStyle := bsSingle;
  BevelKind := bkTile;
  Color := clGray;
  Font.Size := 14;
  ScrollBars := ssVertical;
  Left := DirBgShape1.Left;
  Top := DirBgShape1.Top + DirBgShape1.Height + ScaleY(8);
  Width := DirBgShape1.Width;
  Height := WizardForm.InnerNotebook.Height - Top;
 end;
 ImgApplyChanges(WizardForm.SelectDirPage.Handle);
 IsWizardInitStarted := True;
end;

Function GameVersion(Param: String): String;
var
 Realm: String;
 WOTIdx: Integer;
begin
 Result := SelectedWOTVersion;
 if IsWizardInitStarted and (DirWOTList.ItemIndex >= 0) then
  WOTIdx := DirWOTList.ItemIndex
 else
  WOTIdx := -1;
 if SelectedWOTIdx = WOTIdx then
  Exit;
 SelectedWOTIdx := WOTIdx;
 if WOTIdx >= 0 then
  Realm := AnsiLowercase(WOT_GetClientRealmW(WOTIdx))
 else
  Realm := ActiveLanguage();
 if Realm = 'ru' then
  Result := '{#GameVersionRu}'
 else
  Result := '{#GameVersion}';
 SelectedWOTVersion := Result;
end;
