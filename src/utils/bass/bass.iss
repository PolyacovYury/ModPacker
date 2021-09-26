// "PlaySound" author: Sherogat \\

[Files]
Source: "src\utils\bass\bass.dll"; Flags: ignoreversion nocompression dontcopy;

[Code]
Const
 BASS_ATTRIB_VOL = 2;
 BASS_DEFAULT_DEVICE = -1;

Var
 BASS_Handle: DWORD;

Function BASS_Init(Device: Integer; Freq, Flags: DWORD; Win: HWND; CLSID: Integer): Boolean;
 external 'BASS_Init@files:BASS.dll stdcall';
Function BASS_StreamCreateFile(Mem: BOOL; Filename: PAnsiChar; Offset1, Offset2, Length1, Length2, Flags: DWORD): Longword;
 external 'BASS_StreamCreateFile@files:BASS.dll stdcall';
Function BASS_StreamFree(Handle: Longword): BOOL;
 external 'BASS_StreamFree@files:BASS.dll stdcall';
Function BASS_ChannelPlay(Handle: DWORD; Restart: BOOL): Boolean;
 external 'BASS_ChannelPlay@files:BASS.dll stdcall';
function BASS_ChannelSetAttribute(Handle, Flags: DWORD; Value: Single): Boolean;
 external 'BASS_ChannelSetAttribute@files:BASS.dll stdcall';
Function BASS_Start(): Boolean;
 external 'BASS_Start@files:BASS.dll stdcall';
Function BASS_Stop(): Boolean;
 external 'BASS_Stop@files:BASS.dll stdcall';
Function BASS_Free(): Boolean;
 external 'BASS_Free@files:BASS.dll stdcall';

Procedure BassPlaySound(Filename: AnsiString);
begin
 if BASS_Handle <> -1 then begin
  BASS_Stop();
  BASS_StreamFree(BASS_Handle);
  BASS_Handle := -1;
 end;
 if Filename <> '' then begin
  if not FileExists(ExpandConstant('{tmp}\' + Filename)) then
   ExtractTemporaryFiles(Filename);
  BASS_Handle := BASS_StreamCreateFile(False, PAnsiChar(ExpandConstant('{tmp}\' + Filename)), 0, 0, 0, 0, 0);
  BASS_Start();
  BASS_ChannelPlay(BASS_Handle, False);
 end;
end;

<event('DeinitializeSetup')>
Procedure DeinitializeSounds();
begin
 BassPlaySound('');
 BASS_Stop();
 BASS_Free();
end;