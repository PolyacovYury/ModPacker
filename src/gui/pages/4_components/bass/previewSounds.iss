// © Kotyarko_O, 2020 \\
// "PlaySound" author: Sherogat \\

[Files]
Source: "src\gui\pages\4_components\bass\bass.dll"; Flags: dontcopy;

[CustomMessages]
en.soundPreview=Sound preview
ru.soundPreview=Прослушивание звуков
en.soundPreviewVolumeWarning=To avoid playing an unexpectedly loud sound, check your system volume level.%nAlso note that Setup has own volume level (at window bottom).
ru.soundPreviewVolumeWarning=Во избежание неожиданно громкого звучания, обратите внимание на выставленную громкость в системе.%nТакже, обратите внимание на ползунок громкости в нижней части окна установщика.
en.soundPreviewVolume=Volume: %d%%
ru.soundPreviewVolume=Громкость: %d%%

[Code]
Const
 LB_ITEMFROMPOINT = $01A9;
 BASS_ATTRIB_VOL = 2;
 BASS_DEFAULT_DEVICE = -1;

Type
 TComponentSound = record
  SoundName: String;
  Index: Integer;
 end;

Var
 CompSounds: Array of TComponentSound;
 BassVolumeBar: TBitmapImage;
 BassVolumeLbl: TLabel;
 BassWarningResult: Integer;
 BASS_Handle: DWORD;

Function BASS_Init(Device: Integer; Freq, Flags: DWORD; Win: HWND; CLSID: Integer): Boolean; external 'BASS_Init@files:BASS.dll stdcall';
Function BASS_StreamCreateFile(Mem: BOOL; Filename: PAnsiChar; Offset1, Offset2, Length1, Length2, Flags: DWORD): Longword; external 'BASS_StreamCreateFile@files:BASS.dll stdcall';
Function BASS_StreamFree(Handle: Longword): BOOL; external 'BASS_StreamFree@files:BASS.dll stdcall';
Function BASS_ChannelPlay(Handle: DWORD; Restart: BOOL): Boolean; external 'BASS_ChannelPlay@files:BASS.dll stdcall';
function BASS_ChannelSetAttribute(Handle, Flags: DWORD; Value: Single): Boolean; external 'BASS_ChannelSetAttribute@files:BASS.dll stdcall';
Function BASS_Start(): Boolean; external 'BASS_Start@files:BASS.dll stdcall';
Function BASS_Stop(): Boolean; external 'BASS_Stop@files:BASS.dll stdcall';
Function BASS_Free(): Boolean; external 'BASS_Free@files:BASS.dll stdcall';

Procedure BassPlaySound(Filename: AnsiString);
begin
 if BASS_Handle <> -1 then
 begin
  BASS_Stop();
  BASS_StreamFree(BASS_Handle);
  BASS_Handle := -1;
 end;
 BASS_Handle := BASS_StreamCreateFile(False, PAnsiChar(Filename), 0, 0, 0, 0, 0);
 BASS_Start();
 BASS_ChannelPlay(BASS_Handle, False);
end;

Procedure PlaySound(Sender: TObject);
var
 Point: TPoint;
 I, F, Index: Integer;
 CheckListBox: TNewCheckListBox;
begin
 GetCursorPos(Point);
 CheckListBox := TNewCheckListBox(Sender);
 MapWindowPoints(0, CheckListBox.Handle, Point, 1);

 I := SendMessage(CheckListBox.Handle, LB_ITEMFROMPOINT, 0, (Point.X or (Point.Y shl 16)));
 if ((I shr 16) = 1) or ((I and $FFFF) < 0) then
  Exit
 else
  I := I and $FFFF;
 if (I < 0) or (I >= CheckListBox.Items.Count) then
  Exit;

 Index := I;

 F := -1;
 for I := 0 to GetArrayLength(CompSounds) - 1 do
  if Index = CompSounds[I].Index then
  begin
   F := I;
   Break;
  end;

 if F >= 0 then
 begin
  if BassWarningResult <> IDOK then
   BassWarningResult := MsgBox(CustomMessage('soundPreview') + #13#10 + CustomMessage('soundPreviewVolumeWarning'), mbInformation, MB_OK);
  if BassWarningResult = IDOK then
   if CheckListBox.Checked[CompSounds[F].Index] then
    if FileExists(CompSounds[F].SoundName) then
    begin
     BassPlaySound(CompSounds[F].SoundName);
     BassVolumeBar.Enabled := True;
    end;
 end;
end;

Procedure AddItemSound(CheckListBox: TNewCheckListBox; ItemName, Filename: String);
var
 I: Integer;
begin
 ExtractTemporaryFile(Filename);
 I := GetArrayLength(CompSounds);
 SetArrayLength(CompSounds, I + 1);
 CompSounds[I].Index := CheckListBox.Items.IndexOf(CustomMessage(ItemName));
 CompSounds[I].SoundName := ExpandConstant('{tmp}\' + Filename);
 CheckListBox.OnClick := @PlaySound;
end;

procedure DrawVolume(Image: TBitmapImage; Volume: Integer);
var
  Canvas: TCanvas;
  Width: Integer;
begin
  Canvas := Image.Bitmap.Canvas;

  Canvas.Pen.Style := psClear;

  Width := Image.Bitmap.Width * Volume / 100

  Canvas.Brush.Color := clHighlight;
  Canvas.Rectangle(1, 1, Width, Image.Bitmap.Height);

  Canvas.Brush.Color := clBtnFace;
  Canvas.Rectangle(Width - 1, 1, Image.Bitmap.Width, Image.Bitmap.Height);

  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Mode := pmCopy;
  Canvas.Pen.Color := clBlack;
  Canvas.Brush.Style := bsClear;
  Canvas.Rectangle(1, 1, Image.Bitmap.Width, Image.Bitmap.Height);
end;

Procedure BassVolumeBarOnChange(Sender: TObject);
var
  P: TPoint;
  Image: TBitmapImage;
  Volume: Integer;
begin
  { Calculate where in the bar did user click to }
  GetCursorPos(P);
  Image := TBitmapImage(Sender);
  ScreenToClient(Image.Parent.Handle, P);
  Volume := ((P.X - Image.Left) * 100 / Image.Width) + 1;
  DrawVolume(Image, Volume);
  BASS_ChannelSetAttribute(BASS_Handle, BASS_ATTRIB_VOL, (Volume / 100.0));
  BassVolumeLbl.Caption := Format(CustomMessage('soundPreviewVolume'), [Volume]);
end;

Procedure InitializeSounds();
begin
 BassVolumeBar := TBitmapImage.Create(WizardForm);
 with BassVolumeBar do
 begin
  Parent := WizardForm;
  SetBounds(ScaleX(300), WizardForm.BackButton.Top + ScaleY(12), ScaleX(120), ScaleY(10));
  BackColor := clWhite;
  Bitmap.Width := BassVolumeBar.Width;
  Bitmap.Height := BassVolumeBar.Height;
  OnClick := @BassVolumeBarOnChange;
 end;
 DrawVolume(BassVolumeBar, 10);

 BassVolumeLbl := TLabel.Create(WizardForm);
 with BassVolumeLbl do
 begin
  Parent := WizardForm;
  SetBounds(BassVolumeBar.Left + ScaleX(5), BassVolumeBar.Top - ScaleY(12), 0, 0);
  AutoSize := True;
  WordWrap := False;
  Caption := Format(CustomMessage('soundPreviewVolume'), [10]);
 end;

 BASS_Init(BASS_DEFAULT_DEVICE, 44100, 0, 0, 0);
 BASS_Handle := -1;
 BASS_ChannelSetAttribute(BASS_Handle, BASS_ATTRIB_VOL, (10 / 100.0));
 BassVolumeBar.Visible := False;
 BassVolumeLbl.Visible := False;
end;

<event('DeinitializeSetup')>
Procedure DeinitializeSounds();
begin
 BASS_Stop();
 BASS_Free();
end;