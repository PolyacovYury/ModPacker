// © Kotyarko_O, 2020 \\

[CustomMessages]
en.descriptionMemoDefaultText=Move the cursor over an item in the list to see its description and preview.
ru.descriptionMemoDefaultText=Наведите курсор на компонент в списке, чтобы увидеть его описание и скриншот.
en.descriptionMemoItemUnavailable=%nTemporary unavailable.
ru.descriptionMemoItemUnavailable=%nВременно недоступно.
en.descriptionMemoItemUsed=%nMod will be used by (an)other mod(s).
ru.descriptionMemoItemUsed=%nМод необходим для работы других модов.
en.soundPreviewVolumeWarning=To avoid playing an unexpectedly loud sound, check your system volume level.%nAlso note that Setup has own volume level (at window bottom).
ru.soundPreviewVolumeWarning=Во избежание неожиданно громкого звука проверьте выставленную в системе громкость.%nТакже обратите внимание на ползунок громкости в нижней части окна установщика.
en.soundPreviewVolume=Volume: %d%%
ru.soundPreviewVolume=Громкость: %d%%

[Files]
Source: "data\img\gui\pages\4_components\preview_default.png"; DestDir: "data\img\gui\pages\4_components\"; Flags: solidbreak nocompression ignoreversion dontcopy;

[Code]
<event('CurPageChanged')>
Procedure ComponentsPageOnActivate(PageID: Integer);
begin
 WizardForm.ComponentsDiskSpaceLabel.Visible := PageID = wpSelectComponents;
 if PageID <> wpSelectComponents then Exit;
 WizardForm.Update();
 SetButtonsEnabled(False);
 if not CheckPageDep(ComponentsPageActiveIndex) then
  ChangeActiveComponentsIndex(False)
 else
  ActivateCurrentPage(False);
 SetButtonsEnabled(True);
end;

<event('BackButtonClick')>
Function ComponentsPageOnBackButtonClick(PageID: Integer): Boolean;
begin
 Result := True;
 SetButtonsEnabled(False);
 InvalidateHardDep();
 SetButtonsEnabled(True);
 if PageID <> wpSelectComponents then Exit;
 SetButtonsEnabled(False);
 Result := ChangeActiveComponentsIndex(False);
 SetButtonsEnabled(True);
end;

<event('NextButtonClick')>
Function ComponentsPageOnNextButtonClick(PageID: Integer): Boolean;
begin
 Result := True;
 SetButtonsEnabled(False);
 InvalidateHardDep();
 SetButtonsEnabled(True);
 if PageID <> wpSelectComponents then Exit;
 SetButtonsEnabled(False);
 Result := ChangeActiveComponentsIndex(True);
 SetButtonsEnabled(True);
end;

<event('InitializeWizard')>
Procedure InitializeComponentsPage();
var
 I, Index: Integer;
begin
 with PreviewImagePos do begin
  Left := ScaleX(475);
  Top := ScaleY(4);
  Width := ScaleX(275);
  Height := ScaleY(295);
 end;

 ComponentsBGShape1 := TBevel.Create(WizardForm.SelectComponentsPage);
 with ComponentsBGShape1 do begin
  Parent := WizardForm.SelectComponentsPage;
  Shape := bsFrame;
  SetBounds(
   PreviewImagePos.Left - ScaleX(2),
   PreviewImagePos.Top - ScaleY(2),
   PreviewImagePos.Width + ScaleX(4),
   PreviewImagePos.Height + ScaleY(4));
 end;

 DescriptionMemo := TMemo.Create(WizardForm.SelectComponentsPage);
 with DescriptionMemo do begin
  Parent := WizardForm.SelectComponentsPage;
  Left := ComponentsBGShape1.Left;
  Top := ComponentsBGShape1.Top + ComponentsBGShape1.Height + ScaleY(2);
  Width := ComponentsBGShape1.Width;
  Height := WizardForm.InnerNotebook.Height - Top;
  ReadOnly := True;
  HideSelection := True;
  Text := CustomMessage('descriptionMemoDefaultText');
  Font.Color := clWhite;
  Font.Size := 9;
 end;

 BassVolumeBar := TBitmapImage.Create(WizardForm.SelectComponentsPage);
 with BassVolumeBar do begin
  Parent := WizardForm;
  SetBounds(
   ((WizardForm.BackButton.Left - ScaleX(120)) div 2) + ScaleX(120) - ScaleX(60),
   WizardForm.BackButton.Top - ScaleY(2),
   ScaleX(120),
   ScaleY(10));
  BackColor := clWhite;
  Bitmap.Width := BassVolumeBar.Width;
  Bitmap.Height := BassVolumeBar.Height;
  OnClick := @BassVolumeBarOnChange;
 end;
 DrawVolume(BassVolumeBar, 10);

 BassVolumeLbl := TLabel.Create(WizardForm.SelectComponentsPage);
 with BassVolumeLbl do begin
  Parent := WizardForm;
  SetBounds(
   BassVolumeBar.Left + ScaleX(20),
   BassVolumeBar.Top - ScaleY(12),
   0, 0);
  AutoSize := True;
  WordWrap := False;
  Caption := Format(CustomMessage('soundPreviewVolume'), [10]);
 end;

 BASS_Init(BASS_DEFAULT_DEVICE, 44100, 0, 0, 0);
 BASS_Handle := -1;
 BASS_ChannelSetAttribute(BASS_Handle, BASS_ATTRIB_VOL, (10 / 100.0));
 BassVolumeBar.Visible := False;
 BassVolumeLbl.Visible := False;

 ComponentsPageName := TLabel.Create(WizardForm.SelectComponentsPage);
 with ComponentsPageName do begin
  Parent := WizardForm.SelectComponentsPage;
  Font.Size := 12;
  SetBounds(
   ScaleX(8 + 2),
   ScaleY(4),
   0, 0);
 end;
 ComponentsPageActiveIndex := 0;
 Index := -1;
 for I := 0 to WizardForm.ComponentsList.Items.Count - 1 do begin
  if WizardForm.ComponentsList.ItemLevel[I] = 0 then begin
   Index := Index + 1;
   SetArrayLength(ComponentsLists, Index + 1);
   ComponentsPageName.Caption := WizardForm.ComponentsList.ItemCaption[I];
   ComponentsLists[Index].OldProc := -1;
   ComponentsLists[Index].List := TNewCheckListBox.Create(WizardForm.SelectComponentsPage);
   with ComponentsLists[Index].List do begin
    Parent := WizardForm.SelectComponentsPage;
    Left := ScaleX(8);
    Top := ComponentsPageName.Top + ComponentsPageName.Height + ScaleY(8);
    Width := ComponentsBGShape1.Left - Left - ScaleX(2);
    Height := WizardForm.InnerNotebook.Height - Top;
    Offset := 2;
    Tag := Index;
    Font.Size := 9;
    Visible := False;
   end;
   InitCheckBoxList(ComponentsLists[Index].List);
   ComponentsLists[Index].NeedsVolume := False;
  end else begin
   AddItemIdx(ComponentsLists[Index].List.Tag, I);
   if ComponentData[I].exclusive then
    ComponentsLists[Index].List.AddRadioButton(
     ComponentData[I].name, '', WizardForm.ComponentsList.ItemLevel[I] - 1,
     WizardForm.ComponentsList.Checked[I], not ComponentData[I].fixed, WizardForm.ComponentsList.ItemObject[I])
   else
    ComponentsLists[Index].List.AddCheckBox(
     ComponentData[I].name, '', WizardForm.ComponentsList.ItemLevel[I] - 1,
     WizardForm.ComponentsList.Checked[I], not ComponentData[I].fixed, ComponentData[I].checkablealone,
     not ComponentData[I].dontinheritcheck, WizardForm.ComponentsList.ItemObject[I]);
   if Length(ComponentData[I].preview_sound) > 0 then begin
    ComponentsLists[Index].NeedsVolume := True;
    ComponentsLists[Index].List.ItemSubItem[
     GetArrayLength(ComponentsLists[Index].ItemsIndex) - 1] := '🔊 ' + WizardForm.ComponentsList.ItemSubItem[I];
   end else
    ComponentsLists[Index].List.ItemSubItem[
      GetArrayLength(ComponentsLists[Index].ItemsIndex) - 1] := WizardForm.ComponentsList.ItemSubItem[I];
  end;
 end;
 with WizardForm.ComponentsDiskSpaceLabel do begin
  Parent := WizardForm;
  Left := ScaleX(120);
  Top := WizardForm.ClientHeight - ScaleY(24);
  Width := WizardForm.BackButton.Left - Left - ScaleX(12);
 end;
 WizardForm.ComponentsList.Visible := False;
 WizardForm.SelectComponentsLabel.Visible := False;
 InvalidateHardDep();
 WizardForm.ComponentsList.OnClickCheck(WizardForm.ComponentsList);
end;
