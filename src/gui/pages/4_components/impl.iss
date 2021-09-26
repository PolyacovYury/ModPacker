[Code]
Function GetHoverItemIndex(CheckListBox: TNewCheckListBox; var I: Integer): Boolean;
var
 Point: TPoint;
begin
 GetCursorPos(Point);
 MapWindowPoints(0, CheckListBox.Handle, Point, 1);
 I := SendMessage(CheckListBox.Handle, LB_ITEMFROMPOINT, 0, (Point.X or (Point.Y shl 16)));
 if ((I shr 16) = 1) or ((I and $FFFF) < 0) then
  Exit
 else
  I := I and $FFFF;
 if (I < 0) or (I >= CheckListBox.Items.Count) then
  Exit;
 Result := True;
end;

Procedure SetPreviewImage(const ImageName: String; const IsRelease: Boolean);
begin
 if CompareText(CurrentImage, ImageName) = 0 then
  Exit;
 CurrentImage := ImageName;
 if IsRelease then
  ImgRelease(PreviewImage);
 PreviewImage := ImgLoad(
  WizardForm.SelectComponentsPage.Handle,
  ImageName,
  PreviewImagePos.Left,
  PreviewImagePos.Top,
  PreviewImagePos.Width,
  PreviewImagePos.Height, True, False);
 ImgApplyChanges(WizardForm.SelectComponentsPage.Handle);
end;

Procedure ResetPreviewImage(const Value: Boolean);
begin
 if Value then
  SetPreviewImage('data\img\gui\pages\4_components\preview_default.png', True);
 ImgSetVisibility(PreviewImage, Value);
 ImgApplyChanges(WizardForm.SelectComponentsPage.Handle);
end;

Procedure PlaySound(Sender: TObject);
var
 Index: Integer;
 ItemInfo: TComponentData;
 CheckListBox: TNewCheckListBox;
begin
 CheckListBox := TNewCheckListBox(Sender);
 if not GetHoverItemIndex(CheckListBox, Index) then
  Exit;
 ItemInfo := ComponentData[ComponentsLists[CheckListBox.Tag].ItemsIndex[Index]];
 if Length(ItemInfo.preview_sound) > 0 then begin
  if BassWarningResult <> IDOK then
   BassWarningResult := MsgBox(CustomMessage('soundPreviewVolumeWarning'), mbInformation, MB_OK);
  if BassWarningResult = IDOK then
   if CheckListBox.Checked[Index] then begin
    BassPlaySound(ItemInfo.preview_sound);
    BassVolumeBar.Enabled := True;
   end;
 end else
  BassPlaySound('');
end;

procedure DrawVolume(Image: TBitmapImage; Volume: Integer);
var
  Width: Integer;
begin
  Width := Image.Bitmap.Width * Volume / 100;
  with Image.Bitmap.Canvas do begin
   Pen.Style := psClear;
   Brush.Color := clHighlight;
   Rectangle(1, 1, Width, Image.Bitmap.Height);
   Brush.Color := clBtnFace;
   Rectangle(Width - 1, 1, Image.Bitmap.Width, Image.Bitmap.Height);
   Pen.Style := psSolid;
   Pen.Mode := pmCopy;
   Pen.Color := clBlack;
   Brush.Style := bsClear;
   Rectangle(1, 1, Image.Bitmap.Width, Image.Bitmap.Height);
  end;
end;

Procedure BassVolumeBarOnChange(Sender: TObject);
var
  P: TPoint;
  Image: TBitmapImage;
  Volume: Integer;
begin
  GetCursorPos(P);
  Image := TBitmapImage(Sender);
  ScreenToClient(Image.Parent.Handle, P);
  Volume := ((P.X - Image.Left) * 100 / Image.Width) + 1;
  DrawVolume(Image, Volume);
  BASS_ChannelSetAttribute(BASS_Handle, BASS_ATTRIB_VOL, (Volume / 100.0));
  BassVolumeLbl.Caption := Format(CustomMessage('soundPreviewVolume'), [Volume]);
end;

Procedure AddItemIdx(const CheckListBoxTag, Index: Integer);
var
 Idx: Integer;
begin
 Idx := GetArrayLength(ComponentsLists[CheckListBoxTag].ItemsIndex);
 SetArrayLength(ComponentsLists[CheckListBoxTag].ItemsIndex, Idx + 1);
 ComponentsLists[CheckListBoxTag].ItemsIndex[Idx] := Index;
end;

procedure LocateComponentIndex(DepIndex: Integer; var K: Integer; var Count: Integer);
begin
 Count := -1;
 for K := 0 to GetArrayLength(ComponentsLists) - 1 do
  if ComponentsLists[K].ItemsIndex[GetArrayLength(ComponentsLists[K].ItemsIndex) - 1] >= DepIndex then begin
   Count := DepIndex - ComponentsLists[K].ItemsIndex[0];
   break;
  end;
end;

procedure SetComponentChecked(I: Integer; Checked: Boolean);
var
 K, Count: Integer;
begin
 LocateComponentIndex(I, K, Count);
 if Checked then begin
  if ComponentData[I].checkablealone then begin
   WizardForm.ComponentsList.CheckItem(I, coCheck);
   ComponentsLists[K].List.CheckItem(Count, coCheck);
  end else begin
   WizardForm.ComponentsList.CheckItem(I, coCheckWithChildren);
   ComponentsLists[K].List.CheckItem(Count, coCheckWithChildren);
  end;
 end else begin
  WizardForm.ComponentsList.CheckItem(I, coUncheck);
  if Count > -1 then  // page component
   ComponentsLists[K].List.CheckItem(Count, coUncheck);
 end;
end;

function CheckPageDep(I: Integer): Boolean;
var
 J, K, Index: Integer;
begin
 Result := True;
 Index := ComponentsLists[I].ItemsIndex[0] - 1;
 if (GetArrayLength(ComponentData[Index].dep_hard) > 0) then begin
  for J := 0 to GetArrayLength(ComponentData[Index].dep_hard) - 1 do
  if not WizardIsComponentSelected(ComponentData[Index].dep_hard[J]) then begin
   Result := False;
   SetComponentChecked(Index, False);
   for K := 0 to ComponentsLists[I].List.Items.Count - 1 do begin
    ComponentsLists[I].List.Checked[K] := False;
    ComponentsLists[I].List.ItemEnabled[K] := True;
   end;
  end;
 end;
end;

procedure InvalidateHardDep();
var
 I, J, K, DepIndex, Count: Integer;
 dep: String;
 encountered: TStrings;
begin
 encountered := TStringList.Create();
 for I := 0 to GetArrayLength(ComponentsLists) - 1 do
  for J := 0 to GetArrayLength(ComponentsLists[I].ItemsIndex) - 1 do
   ComponentsLists[I].List.ItemEnabled[J] := True;
 for I := 0 to GetArrayLength(ComponentData) - 1 do begin
  if GetArrayLength(ComponentData[I].dep_hard) > 0 then
  if WizardIsComponentSelected(ComponentIDs[I]) then
  for J := 0 to GetArrayLength(ComponentData[I].dep_hard) - 1 do begin
   dep := ComponentData[I].dep_hard[J];
   if encountered.IndexOf(dep) > -1 then
    continue;
   encountered.add(dep);
   DepIndex := ComponentIDs.IndexOf(dep);
   SetComponentChecked(DepIndex, True);
   LocateComponentIndex(DepIndex, K, Count);
   ComponentsLists[K].List.ItemEnabled[Count] := False;
  end;
 end;
 encountered.Free();
 WizardForm.Update();
end;

procedure CheckSoftDep(CheckListBoxTag: Integer; Clicked: Integer);
var
 I, J, K, DepIndex, Count: Integer;
 ParentID: String;
begin
 if not ((Clicked > -1) and (GetArrayLength(ComponentsLists[CheckListBoxTag].ItemsIndex) > Clicked)) then
  Exit;
 I := ComponentsLists[CheckListBoxTag].ItemsIndex[Clicked];
 if not WizardIsComponentSelected(ComponentIDs[I]) then
  Exit;
 if GetArrayLength(ComponentData[I].dep_soft) > 0 then
 for J := 0 to GetArrayLength(ComponentData[I].dep_soft) - 1 do begin
  DepIndex := ComponentIDs.IndexOf(ComponentData[I].dep_soft[J]);
  SetComponentChecked(DepIndex, True);
  LocateComponentIndex(DepIndex, K, Count);
  CheckSoftDep(K, Count);
 end;
 ParentID := ExtractFileDir(ComponentIDs[I]);
 if ParentID <> '' then begin
  LocateComponentIndex(ComponentIDs.IndexOf(ParentID), K, Count);
  CheckSoftDep(K, Count);
 end;
end;

procedure SetButtonsEnabled(Enabled: Boolean);
begin
 if Enabled then begin
  WizardForm.BackButton.Enabled := True;
  WizardForm.BackButton.Cursor := crDefault;
  WizardForm.NextButton.Enabled := True;
  WizardForm.NextButton.Cursor := crDefault;
 end else begin
  WizardForm.BackButton.Enabled := False;
  WizardForm.BackButton.Cursor := crHourGlass;
  WizardForm.NextButton.Enabled := False;
  WizardForm.NextButton.Cursor := crHourGlass;
 end;
 WizardForm.Update();
end;

procedure ComponentsListOnClick(Sender: TObject);
var
 Index: Integer;
 CheckListBox: TNewCheckListBox;
begin
 PlaySound(Sender);
 CheckListBox := TNewCheckListBox(Sender);
 if not GetHoverItemIndex(CheckListBox, Index) then
  Exit;
 SetComponentChecked(ComponentsLists[CheckListBox.Tag].ItemsIndex[Index], CheckListBox.Checked[Index]);
 CheckSoftDep(CheckListBox.Tag, Index);
 InvalidateHardDep();
 WizardForm.ComponentsList.OnClickCheck(WizardForm.ComponentsList);
end;

Procedure OnItemsListMouseLeave();
begin
 ResetPreviewImage(True);
 DescriptionMemo.Text := CustomMessage('descriptionMemoDefaultText');
 WizardForm.Update();
end;

procedure ActivateCurrentPage(Skipped: Boolean);
begin
 BassPlaySound('');
 ComponentsPageName.Caption := WizardForm.ComponentsList.ItemCaption[ComponentsLists[ComponentsPageActiveIndex].ItemsIndex[0] - 1];
 ComponentsLists[ComponentsPageActiveIndex].List.Visible := True;
 BassVolumeBar.Visible := ComponentsLists[ComponentsPageActiveIndex].NeedsVolume and (not Skipped);
 BassVolumeLbl.Visible := ComponentsLists[ComponentsPageActiveIndex].NeedsVolume and (not Skipped);
 if (ComponentsLists[ComponentsPageActiveIndex].NeedsVolume) and (not Skipped) and (BassWarningResult <> IDOK) then
  BassWarningResult := MsgBox(CustomMessage('soundPreviewVolumeWarning'), mbInformation, MB_OK);
 OnItemsListMouseLeave();
end;

function ChangeActiveComponentsIndex(IsForward: Boolean): Boolean;
var
 TargetIdx, Step: Integer;
begin
 if IsForward then begin
  TargetIdx := (GetArrayLength(ComponentsLists) - 1);
  Step := 1;
 end else begin
  TargetIdx := 0;
  Step := -1;
 end;
 Result := ComponentsPageActiveIndex = TargetIdx;
 ActivateCurrentPage(Result);
 if Result then
  Exit;
 ComponentsLists[ComponentsPageActiveIndex].List.Visible := False;
 Result := True;
 while Result do begin
  ComponentsPageActiveIndex := ComponentsPageActiveIndex + Step;
  Result := not CheckPageDep(ComponentsPageActiveIndex) and ((ComponentsPageActiveIndex * Step) < TargetIdx);
 end;
 ActivateCurrentPage(Result);
end;

// https://stackoverflow.com/a/37355366, https://stackoverflow.com/a/64086762
Function OnItemsListMouseMove(Sender: TObject): Boolean;
var
 Index: Integer;
 ItemInfo: TComponentData;
 CheckListBox: TNewCheckListBox;
begin
 CheckListBox := TNewCheckListBox(Sender);
 Result := GetHoverItemIndex(CheckListBox, Index);
 if not Result then
  Exit;
 ItemInfo := ComponentData[ComponentsLists[CheckListBox.Tag].ItemsIndex[Index]];
 if Length(ItemInfo.preview_image) <> 0 then
  SetPreviewImage(ItemInfo.preview_image, True)
 else
  ResetPreviewImage(True);
 DescriptionMemo.Text := ItemInfo.desc;
 if not CheckListBox.ItemEnabled[Index] then
  if CheckListBox.Checked[Index] then
   DescriptionMemo.Text := DescriptionMemo.Text + CustomMessage('descriptionMemoItemUsed')
  else
   DescriptionMemo.Text := DescriptionMemo.Text + CustomMessage('descriptionMemoItemUnavailable');
 WizardForm.Update();
end;

function ProcessListWnd(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
 I: Integer;
begin
 for I := 0 to GetArrayLength(ComponentsLists) - 1 do begin
  if ComponentsLists[I].List.Handle <> hwnd then
   Continue;
  Result := CallWindowProc(ComponentsLists[I].OldProc, hwnd, uMsg, wParam, lParam);
  if (uMsg = WM_MOUSEMOVE) or (uMsg = WM_MOUSEHOVER) or (uMsg = WM_MOUSEWHEEL) then
   if not OnItemsListMouseMove(ComponentsLists[I].List) then
    OnItemsListMouseLeave();
  if uMsg = WM_MOUSELEAVE then
   OnItemsListMouseLeave();
  Break;
 end;
end;

Procedure InitCheckBoxList(CheckListBox: TNewCheckListBox);
begin
 ComponentsLists[CheckListBox.Tag].OldProc := SetWindowLong(CheckListBox.Handle, GWL_WNDPROC, CreateCallback(@ProcessListWnd));
 SetWindowLong(CheckListBox.Handle, GWL_EXSTYLE, GetWindowLong(CheckListBox.Handle, GWL_EXSTYLE) or WS_EX_COMPOSITED);
 CheckListBox.OnClickCheck := @ComponentsListOnClick;
end;

<event('DeinitializeSetup')>
procedure DeinitializeOldProc;
var
 I: Integer;
begin
 for I := 0 to GetArrayLength(ComponentsLists) - 1 do
 if ComponentsLists[I].OldProc <> -1 then begin
  SetWindowLong(ComponentsLists[I].List.Handle, GWL_WNDPROC, ComponentsLists[I].OldProc);
  ComponentsLists[I].OldProc := -1;
 end;
end;
