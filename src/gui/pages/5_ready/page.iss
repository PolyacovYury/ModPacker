// © Kotyarko_O, 2020 \\

[Code]
<event('CurPageChanged')>
Procedure ReadyPageOnActivate(PageID: Integer);
var
 I, J: Integer;
begin
 if PageID <> wpReady then Exit;
 WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall);
 WizardForm.NextButton.Enabled := False;
 for I := 0 to GetArrayLength(ComponentsLists) - 1 do
  for J := 0 to ComponentsLists[I].List.Items.Count - 1 do
   if ComponentsLists[I].List.Checked[J] then begin
    WizardForm.NextButton.Enabled := True;
    break;
   end;
 WizardForm.ReadyMemo.Text := GetReadyMemoFormat();
end;

<event('NextButtonClick')>
Function ReadyPageOnNextButtonClick(PageID: Integer): Boolean;
begin
 Result := True;
 if PageID <> wpReady then Exit;
 PreparingActions();
end;

<event('InitializeWizard')>
Procedure InitializeReadyPage();
begin
 with WizardForm.ReadyLabel do begin
  Font.Size := 11;
  Font.Style := [fsBold];
  AutoSize := True;
  WordWrap := True;
  Left := ScaleX(8);
  Top := ScaleY(14);
  Width := WizardForm.ClientWidth - Left * 2;
  Caption := SetupMessage(msgReadyLabel2a); // recalculate height
 end;

 with WizardForm.ReadyMemo do begin
  Left := ScaleX(8);
  Top := WizardForm.ReadyLabel.Top + WizardForm.ReadyLabel.Height + ScaleY(14);
  Width := WizardForm.ClientWidth - Left * 2;
  Height := WizardForm.InnerNotebook.Height - Top;
  ScrollBars := ssVertical;
  ReadOnly := True;
  Font.Size := 9;
 end;
end;