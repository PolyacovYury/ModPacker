// © Kotyarko_O, 2020 \\

[Files]
//Source: "files\previews\*"; Excludes: "*.psd"; Flags: recursesubdirs nocompression dontcopy;

[Code]
Const
 GWL_EXSTYLE = -20;
 WS_EX_COMPOSITED = $02000000;

Type
 TPreviewImagePos = record
  Top, Left, Width, Height: Integer;
 end;

 TItemInfo = record
  Image, Desc: String;
 end;

 TOldProcInfo = record
  Proc: LongInt;
  Box: TNewCheckListBox;
 end;

 TListsItemsInfo = Array of Array of TItemInfo;
 TListOldProc = Array of TOldProcInfo;

Var
 DescriptionMemo: TMemo;
 PreviewImage: Longint;
 PreviewImagePos: TPreviewImagePos;
 ListsItemsInfo: TListsItemsInfo;
 ListOldProc: TListOldProc;

Function IsItemInBlackList(const ItemName: String): Boolean;
begin
 Result := False;
  #ifdef Updater
 if Pos(ItemName, ItemsBlackList) > 0 then
  Result := True;
 #endif
end;

Procedure SetCheckListBoxItemsInfo(const CheckListBoxTag: Integer);
begin
 SetArrayLength(ListsItemsInfo, GetArrayLength(ListsItemsInfo) + 1);
end;

Procedure SetItemInfo(const CheckListBoxTag: Integer; const AItemName, ImageName: String);
var
 DescName: String;
 Idx: Integer;
begin
 Idx := GetArrayLength(ListsItemsInfo[CheckListBoxTag]);
 SetArrayLength(ListsItemsInfo[CheckListBoxTag], Idx + 1);
 ListsItemsInfo[CheckListBoxTag][Idx].Image := ImageName;
 DescName := AItemName;
 StringChange(DescName, 'item', 'desc');
 ListsItemsInfo[CheckListBoxTag][Idx].Desc := CustomMessage(DescName);
end;

Function AddCheckBoxExt(CheckListBox: TNewCheckListBox; ItemName: String; Level: Integer; Enabled: Boolean; FontStyle: TFontStyles; ImageName: String): Integer;
begin
 Result := CheckListBox.AddCheckBox(CustomMessage(ItemName), '', Level, False, not IsItemInBlackList(ItemName) and Enabled, True, True, nil);
 CheckListBox.ItemFontStyle[Result] := FontStyle;
 SetItemInfo(CheckListBox.Tag, ItemName, ImageName);
end;

Function AddRadioButtonExt(CheckListBox: TNewCheckListBox; ItemName: String; Level: Integer; Enabled: Boolean; FontStyle: TFontStyles; ImageName: String): Integer;
begin
 Result := CheckListBox.AddRadioButton(CustomMessage(ItemName), '', Level, False, not IsItemInBlackList(ItemName) and Enabled, nil);
 CheckListBox.ItemFontStyle[Result] := FontStyle;
 SetItemInfo(CheckListBox.Tag, ItemName, ImageName);
end;

Procedure SetCheckListBoxBGBMP(CheckListBox: TNewCheckListBox);
begin
 SetWindowLong(CheckListBox.Handle, GWL_EXSTYLE, GetWindowLong(CheckListBox.Handle, GWL_EXSTYLE) or WS_EX_COMPOSITED);
end;

////

Procedure InitializeComponentsInfo();
begin
 with PreviewImagePos do
 begin
  Left := ScaleX(475);
  Top := ScaleY(92);
  Width := ScaleX(275);
  Height := ScaleY(295);
 end;

 DescriptionMemo := TMemo.Create(WizardForm);
 with DescriptionMemo do
 begin
  Parent := WizardForm;
  SetBounds(PreviewImagePos.Left - ScaleX(1), PreviewImagePos.Top + PreviewImagePos.Height + ScaleY(2), PreviewImagePos.Width + ScaleX(2), ScaleY(92));
  ReadOnly := True;
  HideSelection := True;
  Text := CustomMessage('descriptionMemoDefaultText');
  Font.Color := clWhite;
  Font.Size := 9;
  //DragMode := dmAutomatic;
 end;
end;

Procedure SetPreviewImage(const ImageName: String; const IsRelease: Boolean);
begin
 if IsRelease then
  ImgRelease(PreviewImage);
 PreviewImage := ImgLoad(WizardForm.Handle, ImageName, PreviewImagePos.Left, PreviewImagePos.Top, PreviewImagePos.Width, PreviewImagePos.Height, True, False);
end;

Procedure ResetPreviewImage(const Value: Boolean);
begin
 if Value then
  SetPreviewImage('KMP.png', False);
 ImgSetVisibility(PreviewImage, Value);
end;

// https://stackoverflow.com/a/37355366, https://stackoverflow.com/a/64086762
Function _OnItemMouseMove(Sender: TObject): Boolean;
var
 Point: TPoint;
 I, Index: Integer;
 ItemInfo: TItemInfo;
 CheckListBox: TNewCheckListBox;
begin
 GetCursorPos(Point);
 CheckListBox := TNewCheckListBox(Sender);
 MapWindowPoints(0, CheckListBox.Handle, Point, 1);

 I := SendMessage(CheckListBox.Handle, LB_ITEMFROMPOINT, 0, (Point.X or (Point.Y shl 16)));
 if ((I shr 16) = 1) or ((I and $FFFF) < 0) then begin
  Result := False;
  Exit;
 end else
  I := I and $FFFF;
 if (I < 0) or (I >= CheckListBox.Items.Count) then begin
  Result := False;
  Exit;
 end;

 Index := I;
 ItemInfo := ListsItemsInfo[CheckListBox.Tag][Index];
 SetPreviewImage(ItemInfo.Image, True);
 DescriptionMemo.Text := ItemInfo.Desc;
 if not CheckListBox.ItemEnabled[Index] then
  DescriptionMemo.Text := DescriptionMemo.Text + CustomMessage('descriptionMemoItemUnavailable');
 ImgApplyChanges(WizardForm.Handle);
 Result := True;
end;

Procedure _OnMouseLeave(Sender: TObject);
begin
 SetPreviewImage('KMP.png', True);
 DescriptionMemo.Text := CustomMessage('descriptionMemoDefaultText');
 ImgApplyChanges(WizardForm.Handle);
end;

function ProcessListWnd(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  I: Integer;
begin
  for I := 0 to GetArrayLength(ListOldProc) - 1 do begin
    if ListOldProc[I].Box.Handle <> hwnd then
      Continue;
    if uMsg = WM_MOUSEMOVE then
      if not _OnItemMouseMove(ListOldProc[I].Box) then
        _OnMouseLeave(ListOldProc[I].Box);
    Result := CallWindowProc(ListOldProc[I].Proc, hwnd, uMsg, wParam, lParam);
    Break;
  end;
end;

Procedure SetCheckListBoxEvents(CheckListBox: TNewCheckListBox);
var
 Idx: Integer;
begin
 Idx := GetArrayLength(ListOldProc);
 SetArrayLength(ListOldProc, Idx + 1);
 with ListOldProc[Idx] do begin
  Box := CheckListBox;
  Proc := SetWindowLong(Box.Handle, GWL_WNDPROC, CreateCallback(@ProcessListWnd));
 end;
end;

<event('DeinitializeSetup')>
procedure _Hover__DeinitializeSetup;
var
  I : Integer;
begin
  for I := 0 to GetArrayLength(ListOldProc) - 1 do
    SetWindowLong(ListOldProc[I].Box.Handle, GWL_WNDPROC, ListOldProc[I].Proc);
  SetArrayLength(ListOldProc, 0);
end;

////

Function _IsComponentSelected(const CheckListBox: TNewCheckListBox; Name: String): Boolean;
var
 I, Idx: Integer;
begin
 Result := False;
 try
  if Name = 'CheckForChecked' then
  begin
   for I := 0 to CheckListBox.Items.Count - 1 do
   begin
    Result := CheckListBox.Checked[I];
    if Result then
     Exit;
   end;
  end else
  begin
   Idx := CheckListBox.Items.IndexOf(CustomMessage(Name));
   if Idx = -1 then
   begin
    //MsgBoxEx(WizardForm.Handle, 'There is no such item:' + #13#10 + CustomMessage(Name) + #13#10 + 'In the: ' + CheckListBox.Name, 'Item not found:', MB_ICONWARNING or MB_OK, 0, 0);
    MsgBox('Item not found:' + #13#10 + #13#10 + 'There is no such item:' + #13#10 + CustomMessage(Name) + #13#10 + 'In the: ' + CheckListBox.Name, mbError, MB_OK);
    Exit;
   end else
    Result := CheckListBox.Checked[Idx];
  end;
 except
  //MsgBoxEx(WizardForm.Handle, GetExceptionMessage(), '{#__FILE__}: {#__LINE__}', MB_ICONERROR or MB_OK, 0, 0);
  MsgBox('{#__FILE__}: {#__LINE__}' + #13#10 + GetExceptionMessage(), mbCriticalError, MB_OK);
 end;
end;