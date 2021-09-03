// © Kotyarko_O, 2020 \\

[Files]
Source: "data\img\gui\window\header.jpg"; DestDir: "data\img\gui\window\"; Flags: ignoreversion nocompression dontcopy;

[Code]
Var
 BotvaFont: TFont;
 WizardHeader: Longint;

<event('InitializeWizard')>
Procedure InitializeWindow();
begin
 with WizardForm do begin
  ClientWidth := ScaleX(760);
  ClientHeight := ScaleY(545);
  OuterNotebook.Hide;
  Bevel.Left := 0;
  Bevel.Top := ScaleY(473);
  BackButton.SetBounds(
   ClientWidth - ScaleX(285),
   ClientHeight - ScaleY(38),
   BackButton.Width + ScaleX(5),
   BackButton.Height + ScaleY(3));
  NextButton.SetBounds(
   ClientWidth - ScaleX(195),
   ClientHeight - ScaleY(38),
   NextButton.Width + ScaleX(5),
   NextButton.Height + ScaleY(3));
  CancelButton.SetBounds(
   ClientWidth - ScaleX(95),
   ClientHeight - ScaleY(38),
   CancelButton.Width + ScaleX(5),
   CancelButton.Height + ScaleY(3));
  Color := clBlack;
 end;
 with WizardForm.InnerNotebook do begin
  Parent := WizardForm;
  Left := 0;
  Top := ScaleY(80);
  ClientWidth := WizardForm.ClientWidth;
  ClientHeight := ScaleY(467) - Top;
 end;

 BotvaFont := TFont.Create();
 with BotvaFont do begin
  Name := 'Tahoma';
  Size := 10;
  Style := [];
 end;

 WizardHeader := ImgLoad(WizardForm.Handle, 'data\img\gui\window\header.jpg', 0, 0, WizardForm.ClientWidth, ScaleY(80), True, True);
 ImgSetVisibility(WizardHeader, True);
 ImgApplyChanges(WizardForm.Handle);
end;
