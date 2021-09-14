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

procedure SetComponentChecked(I: Integer; Checked: Boolean);
var
 ComponentID: String;
begin
 ComponentID := ComponentIDs[I];
 if not Checked then
  ComponentID := '!' + ComponentID;
 WizardSelectComponents(ComponentID);
 if Checked then
  if ComponentData[I].checkablealone then
   WizardForm.ComponentsList.CheckItem(I, coCheck)
  else
   WizardForm.ComponentsList.CheckItem(I, coCheckWithChildren)
 else
  WizardForm.ComponentsList.CheckItem(I, coUncheck);
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
   for K := 0 to ComponentsLists[I].List.Items.Count - 1 do
    ComponentsLists[I].List.Checked[K] := False;
  end;
 end;
end;

procedure ProcessDepClick(Sender: TObject);
var
 I, J, K, DepIndex, Count, Clicked: Integer;
 CheckListBox: TNewCheckListBox;
begin
 for I := 0 to GetArrayLength(ComponentsLists) - 1 do
  for J := 0 to GetArrayLength(ComponentsLists[I].ItemsIndex) - 1 do
   ComponentsLists[I].List.ItemEnabled[J] := True;
 for I := 0 to GetArrayLength(ComponentData) - 1 do begin
  if GetArrayLength(ComponentData[I].dep_hard) > 0 then
  if WizardForm.ComponentsList.Checked[I] then
  for J := 0 to GetArrayLength(ComponentData[I].dep_hard) - 1 do begin
   DepIndex := -1;
   for K := 0 to GetArrayLength(ComponentIDs) - 1 do
    if ComponentIDs[K] = ComponentData[I].dep_hard[J] then begin
     DepIndex := K;
     break;
    end;
   SetComponentChecked(DepIndex, True);
   Count := 0;
   for K := 0 to GetArrayLength(ComponentsLists) - 1 do
    if ComponentsLists[K].ItemsIndex[GetArrayLength(ComponentsLists[K].ItemsIndex) - 1] >= DepIndex then begin
     Count := DepIndex - ComponentsLists[K].ItemsIndex[0];
     break;
    end;
   ComponentsLists[K].List.Checked[Count] := True;
   ComponentsLists[K].List.ItemEnabled[Count] := False;
  end;
 end;
 CheckListBox := TNewCheckListBox(Sender);
 if not GetHoverItemIndex(CheckListBox, Clicked) then
  Exit;
 for I := 0 to GetArrayLength(ComponentData) - 1 do begin
  if GetArrayLength(ComponentsLists[CheckListBox.Tag].ItemsIndex) > Clicked then
  if ComponentsLists[CheckListBox.Tag].ItemsIndex[Clicked] = I then
  if GetArrayLength(ComponentData[I].dep_soft) > 0 then
  if WizardForm.ComponentsList.Checked[I] then
  for J := 0 to GetArrayLength(ComponentData[I].dep_soft) - 1 do begin
   DepIndex := -1;
   for K := 0 to GetArrayLength(ComponentIDs) - 1 do
    if ComponentIDs[K] = ComponentData[I].dep_soft[J] then begin
     DepIndex := K;
     break;
    end;
   SetComponentChecked(DepIndex, True);
   Count := 0;
   for K := 0 to GetArrayLength(ComponentsLists) - 1 do
    if ComponentsLists[K].ItemsIndex[GetArrayLength(ComponentsLists[K].ItemsIndex) - 1] >= DepIndex then begin
     Count := DepIndex - ComponentsLists[K].ItemsIndex[0];
     break;
    end;
   ComponentsLists[K].List.Checked[Count] := True;
  end;
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
 ProcessDepClick(Sender);
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
 WizardForm.BackButton.Visible := not Elevated or (ComponentsPageActiveIndex > 0);
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
  if IsForward then
   Result := not CheckPageDep(ComponentsPageActiveIndex) and (ComponentsPageActiveIndex < TargetIdx)
  else
   Result := not CheckPageDep(ComponentsPageActiveIndex) and (ComponentsPageActiveIndex > TargetIdx);
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
  if (uMsg = WM_MOUSEMOVE) or (uMsg = WM_MOUSEHOVER) then
   if not OnItemsListMouseMove(ComponentsLists[I].List) then
    OnItemsListMouseLeave();
  if uMsg = WM_MOUSELEAVE then
   OnItemsListMouseLeave();
  Result := CallWindowProc(ComponentsLists[I].OldProc, hwnd, uMsg, wParam, lParam);
  Break;
 end;
end;

Procedure InitCheckBoxList(CheckListBox: TNewCheckListBox);
begin
 ComponentsLists[CheckListBox.Tag].OldProc := SetWindowLong(CheckListBox.Handle, GWL_WNDPROC, CreateCallback(@ProcessListWnd));
 SetWindowLong(CheckListBox.Handle, GWL_EXSTYLE, GetWindowLong(CheckListBox.Handle, GWL_EXSTYLE) or WS_EX_COMPOSITED);
 CheckListBox.OnClick := @ComponentsListOnClick;
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
