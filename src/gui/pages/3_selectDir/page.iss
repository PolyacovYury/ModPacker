// © Kotyarko_O, 2020 \\

[CustomMessages]
en.applicationNotFound=Required World of Tanks files not found in the chosen directory.
ru.applicationNotFound=Необходимые файлы World of Tanks не найдены в выбранной папке.
en.applicationWrongDir=Selected install directory%nis not a World of Tanks client root directory.%n%nPlease, select a World of Tanks root directory%n(contains folders like "mods" and "res_mods").
ru.applicationWrongDir=Выбранная папка установки не является%nкорневой папкой клиента игры World of Tanks.%n%nПожалуйста, выберите корневую папку World of Tanks%n(содержит такие папки, как "mods" и "res_mods").
en.applicationIncompleteType=Game client installation/update must be finished before continuing this Setup.
ru.applicationIncompleteType=Необходимо завершить установку/обновление клиента, прежде чем продолжить установку.
en.applicationPatchIncompatible=Incompatible game client version: %s%nThis Setup requires version {#GameVersion}.
ru.applicationPatchIncompatible=Неподходящая версия установленного клиента: %s%nСборка предназначена для патча {#GameVersion}.

en.cleanProfileButtonText=Clear game client profile (reset client settings and caches)
ru.cleanProfileButtonText=Очистить папку профиля игрового клиента (сброс индивидуальных настроек и кэша)

[Files]
Source: "data\img\gui\pages\3_selectDir\directory.png"; DestDir: "data\img\gui\pages\3_selectDir\"; Flags: ignoreversion nocompression dontcopy;

[Code]
Var
 SelectDirPageImg, CBCleanProfile: Longint;
 FindWOTBuff: String;
 DirWOTList: TComboBox;
 DirBrowseButton: TButton;
 DirBgShape1: TBevel;

Procedure UpdateDirWOTList();
var
 ClientsCount, Index, ListIndex: Integer;
 Str: String;
begin
 ListIndex := DirWOTList.ItemIndex;
 ClientsCount := WOT_GetClientsCount();
 DirWOTList.Items.Clear();
 if ClientsCount > 0 then begin
  for Index := 0 to ClientsCount - 1 do begin
   WOT_GetClientVersionW(FindWOTBuff, 1024, Index);
   Str := Copy(FindWOTBuff, 0, Pos(#0, FindWOTBuff));
   case WOT_GetClientBranch(Index) of
    1: Insert(' Release: ', Str, Pos(#0, Str));
    2: Insert(' Common Test: ', Str, Pos(#0, Str));
    3: Insert(' Super Test: ', Str, Pos(#0, Str));
    4: Insert(' Sandbox: ', Str, Pos(#0, Str));
   end;
   WOT_GetClientPathW(FindWOTBuff, 1024, Index);
   Insert(FindWOTBuff, Str, Pos(#0, Str));
   DirWOTList.Items.Add(Str);
  end;
 end;
 DirWOTList.Items.Add(SetupMessage(msgWizardSelectDir));
 DirWOTList.ItemIndex := ListIndex;
end;

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
  UpdateDirWOTList();
  DirWOTList.ItemIndex := Index;
 end else begin
  MsgBox(CustomMessage('applicationNotFound'), mbError, MB_OK);
  if DirWOTList.Items.Strings[0] <> SetupMessage(msgWizardSelectDir) then
   DirWOTList.ItemIndex := 0;
 end;
end;

Procedure WOTListOnChange(Sender: TObject);
begin
 if (
   (Sender = DirBrowseButton)
   or ((Sender = DirWOTList) and (DirWOTList.ItemIndex = (DirWotList.Items.Count - 1)))
 ) then begin
  WizardForm.DirBrowseButton.OnClick(WizardForm.DirBrowseButton);
  WOTListAddClient(WizardForm.DirEdit.Text);
 end;
 WOT_GetClientPathW(FindWOTBuff, 1024, DirWOTList.ItemIndex);
 WizardForm.DirEdit.Text := FindWOTBuff;
end;

procedure InitializeFindWOT();
begin
 SetLength(FindWOTBuff, 1024);
 UpdateDirWOTList();
 WOTListAddClient(WizardForm.DirEdit.Text);
 if DirWOTList.ItemIndex = -1 then
  DirWOTList.ItemIndex := 0;
 DirWOTList.OnChange(DirWOTList);
end;

<event('CurPageChanged')>
Procedure SelectDirPageOnActivate(PageID: Integer);
begin
 if PageID <> wpSelectDir then Exit;
 InitializeFindWOT();
end;

<event('NextButtonClick')>
Function SelectDirPageOnNextButtonClick(PageID: Integer): Boolean;
var
 PatchVersion, AppType: String;
begin
 Result := True;
 if PageID <> wpSelectDir then Exit;
 if CMDCheckParams(CMD_NoSearchGameFiles) then begin
  Exit;
 end;
 if not (
   FileExists(WizardDirValue() + '\WorldOfTanks.exe')
   and FileExists(WizardDirValue() + '\version.xml')
   and FileExists(WizardDirValue() + '\app_type.xml')
 ) then begin
  MsgBox(CustomMessage('applicationWrongDir'), mbError, MB_OK);
  Result := False;
 end else begin
  XMLFileReadValue(WizardDirValue() + '\app_type.xml', 'protocol\app_type', AppType);
  Result := AppType <> 'incomplete';
  if not Result then
   MsgBox(CustomMessage('applicationIncompleteType'), mbError, MB_OK)
  else begin
   XMLFileReadValue(WizardDirValue() + '\version.xml', 'version.xml\version', PatchVersion);
   Delete(PatchVersion, Pos('v', PatchVersion), 2);
   Delete(PatchVersion, Pos('#', PatchVersion) - 1, 10);
   Result := CompareStr(PatchVersion, '{#GameVersion}') = 0;
   if not Result then
    MsgBox(Format(CustomMessage('applicationPatchIncompatible'), [PatchVersion]), mbError, MB_OK);
  end;
 end;
end;

<event('InitializeWizard')>
Procedure InitializeSelectDirPage();
var
 RTFStr: AnsiString;
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

//FindWOT
 DirWOTList := TComboBox.Create(WizardForm.SelectDirPage);
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
//FindWOT end

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
 LoadStringFromFile(ExpandConstant('{tmp}\' + Format('data\lang\%s\info_before.rtf', [ActiveLanguage()])), RTFStr);
 with TRichEditViewer.Create(WizardForm.SelectDirPage) do begin  // WizardForm.InfoBeforeMemo refuses to work properly
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
  RTFText := RTFStr;
 end;
 ImgApplyChanges(WizardForm.SelectDirPage.Handle);
end;
