// © Kotyarko_O, 2020 \\
[Files]
Source: "data\img\gui\logoBtnKr.png"; Flags: dontcopy;
Source: "data\img\gui\logoBtnWot.png"; Flags: dontcopy;

[Code]
Var
 KRLogoBtn, WOTLogoBtn: Longint;

Procedure WidgetsOnClick(hBtn: Longint);
var
 ErrorCode: Integer;
begin
 case hBtn of
  KRLogoBtn: ShellExec('', '{#URL_KoreanRandom}', '', '', SW_SHOW, ewNoWait, ErrorCode);
  WOTLogoBtn: ShellExec('', '{#URL_WGMods}', '', '', SW_SHOW, ewNoWait, ErrorCode);
 end;
end;

<event('InitializeWizard')>
Procedure InitializeWidgets();
begin
 KRLogoBtn := BtnCreate(WizardForm.Handle, ScaleX(8), WizardForm.ClientHeight - ScaleY(44), 40, 40, 'logoBtnKr.png', 0, False);
 BtnSetCursor(KRLogoBtn, GetSysCursorHandle(OCR_HAND));
 BtnSetEvent(KRLogoBtn, BtnClickEventID, WrapBtnCallback(@WidgetsOnClick, 1));

 WOTLogoBtn := BtnCreate(WizardForm.Handle, ScaleX(44), WizardForm.ClientHeight - ScaleY(44), 40, 40, 'logoBtnWot.png', 0, False);
 BtnSetCursor(WOTLogoBtn, GetSysCursorHandle(OCR_HAND));
 BtnSetEvent(WOTLogoBtn, BtnClickEventID, WrapBtnCallback(@WidgetsOnClick, 1));
end;

//https://krinkels.org/threads/botva2.1931/post-31509
[Code]
var
 HintLabel: TLabel;
 HintShape: TBevel;

procedure HintVisible(aVisible: Boolean);
begin
  HintLabel.Visible:=aVisible;
  HintShape.Visible:=aVisible;
end;

procedure WidgetBtnEnter(Sender: hWnd);
begin
 with HintLabel do begin
  case Sender of
   KRLogoBtn: Caption := '{#URL_KoreanRandom}';
   WOTLogoBtn: Caption := '{#URL_WGMods}';
  end;
  HintShape.SetBounds(Left - ScaleX(4), Top - ScaleX(2), HintLabel.Width + ScaleX(8), HintLabel.Height + ScaleY(4));
 end;
 HintVisible(True);
end;

procedure WidgetBtnLeave(Sender: hWnd);
begin
 HintVisible(False);
end;

<event('InitializeWizard')>
Procedure InitializeWidgetHints();
begin
 HintShape:=TBevel.Create(WizardForm);
 with HintShape do begin
  Parent := WizardForm;
 end;

 HintLabel:=TLabel.Create(WizardForm);
 with HintLabel do begin
  Parent := WizardForm;
  Left := ScaleX(10);
  Top := WizardForm.ClientHeight - ScaleY(44) - ScaleY(20);
 end;

 HintVisible(False);
 BtnSetEvent(KRLogoBtn, BtnMouseEnterEventID, WrapBtnCallback(@WidgetBtnEnter, 1));
 BtnSetEvent(KRLogoBtn, BtnMouseLeaveEventID, WrapBtnCallback(@WidgetBtnLeave, 1));
 BtnSetEvent(WOTLogoBtn, BtnMouseEnterEventID, WrapBtnCallback(@WidgetBtnEnter, 1));
 BtnSetEvent(WOTLogoBtn, BtnMouseLeaveEventID, WrapBtnCallback(@WidgetBtnLeave, 1));
end;