// © Kotyarko_O, 2020 \\

[Files]
Source: "data\img\gui\window\WizardHeader.jpg"; Flags: dontcopy;

[Code]
Var
 BotvaFont: TFont;
 WizardHeader: Longint;

<event('InitializeWizard')>
Procedure InitializeWindow();
begin
 with WizardForm do
 begin
  ClientWidth := ScaleX(760);
  ClientHeight := ScaleY(545);
  OuterNotebook.Hide;
  InnerNotebook.Hide;
  Bevel.Hide;
  BackButton.SetBounds(ClientWidth - ScaleX(285), ClientHeight - ScaleY(38), BackButton.Width + ScaleX(5), BackButton.Height + ScaleY(3));
  NextButton.SetBounds(ClientWidth - ScaleX(195), ClientHeight - ScaleY(38), NextButton.Width + ScaleX(5), NextButton.Height + ScaleY(3));
  CancelButton.SetBounds(ClientWidth - ScaleX(95), ClientHeight - ScaleY(38), CancelButton.Width + ScaleX(5), CancelButton.Height + ScaleY(3));
  //Center();
 end;

 BotvaFont := TFont.Create();
 with BotvaFont do
 begin
  Name := 'Tahoma';
  Size := 10;
  Style := [];
 end;

 WizardHeader := ImgLoad(WizardForm.Handle, 'WizardHeader.jpg', 0, 0, WizardForm.ClientWidth, ScaleY(80), True, True);
 ImgSetVisibility(WizardHeader, True);
 ImgApplyChanges(WizardForm.Handle);
end;
