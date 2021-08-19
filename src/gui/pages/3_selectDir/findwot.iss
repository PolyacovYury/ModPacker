// This file is part of the Findwot project.
//
// Copyright (c) 2016-2017 Findwot contributors.
//
// Findwot is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation, version 3.
//
// Findwot is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
[CustomMessages]
en.applicationNotFound=Required World of Tanks files not found in the chosen directory.
ru.applicationNotFound=Необходимые файлы World of Tanks не найдены в выбранной папке.

[Files]
Source: "src\gui\pages\3_selectDir\findwot.dll"; Flags: dontcopy;

[Code]
Procedure WGC_GetInstallPathW(Buffer: String; BufferSize: Integer);
external 'WGC_GetInstallPathW@files:findwot.dll cdecl';

Function WGC_IsInstalled(): Boolean;
external 'WGC_IsInstalled@files:findwot.dll cdecl';

Function WOT_AddClientW(ClientPath: String): Integer;
external 'WOT_AddClientW@files:findwot.dll cdecl';

Procedure WOT_GetPreferredClientPathW(Buffer: String; BufferSize: Integer);
external 'WOT_GetPreferredClientPathW@files:findwot.dll cdecl';

Function WOT_GetClientsCount(): Integer;
external 'WOT_GetClientsCount@files:findwot.dll cdecl';

Function WOT_GetClientBranch(ClientIndex: Integer): Integer;
external 'WOT_GetClientBranch@files:findwot.dll cdecl';

Function WOT_GetClientType(ClientIndex: Integer): Integer;
external 'WOT_GetClientType@files:findwot.dll cdecl';

Procedure WOT_GetClientLocaleW(Buffer: String; BufferSize: Integer; ClientIndex: Integer);
external 'WOT_GetClientLocaleW@files:findwot.dll cdecl';

Procedure WOT_GetClientPathW(Buffer: String; BufferSize: Integer; ClientIndex: Integer);
external 'WOT_GetClientPathW@files:findwot.dll cdecl';

Procedure WOT_GetClientVersionW(Buffer: String; BufferSize: Integer; ClientIndex: Integer);
external 'WOT_GetClientVersionW@files:findwot.dll cdecl';

Procedure WOT_GetClientExeVersionW(Buffer: String; BufferSize: Integer; ClientIndex: Integer);
external 'WOT_GetClientExeVersionW@files:findwot.dll cdecl';

Var
 WOTList: TComboBox;
 DirBrowseButton: TButton;
 FindWOTBuff: String;

Procedure WOTListUpdate();
var
 ClientsCount, Index, ListIndex: Integer;
 Str: String;
begin
 ListIndex := WOTList.ItemIndex;
 ClientsCount := WOT_GetClientsCount();

 WOTList.Items.Clear();

 if ClientsCount > 0 then begin
  for Index := 0 to ClientsCount - 1 do begin
   WOT_GetClientVersionW(FindWOTBuff, 1024, Index);
   Str := Copy(FindWOTBuff, 0, Pos(#0, FindWOTBuff));

   case WOT_GetClientBranch(Index) of
    1: Insert(' Release: ', Str, Pos(#0, Str));
    2: Insert(' Common Test: ', Str, Pos(#0, Str));
    3: Insert(' Super Test: ', Str, Pos(#0, Str));
    4: Insert(' Sandbox: ', Str, Pos(#0, Str));
   end;

   WOT_GetClientPathW(FindWOTBuff, 1024, Index);
   Insert(FindWOTBuff, Str, Pos(#0, Str));

   WOTList.Items.Add(Str);
  end;
 end;

 WOTList.Items.Add(SetupMessage(msgWizardSelectDir));
 WOTList.ItemIndex := ListIndex;
end;

Procedure WOTListAddClient(ClientPath: String);
var
 Index: Integer;
begin
 if Length(ClientPath) = 0 then begin
  WOTList.ItemIndex := -1;
  Exit;
 end;

 Index := WOT_AddClientW(ClientPath);
 if Index >= 0 then begin
  WOTListUpdate();
  WOTList.ItemIndex := Index;
 end else begin
  MsgBox(CustomMessage('applicationNotFound'), mbError, MB_OK);
  if WOTList.Items.Strings[0] <> SetupMessage(msgWizardSelectDir) then
   WOTList.ItemIndex := 0;
 end;
end;

Procedure WOTListOnChange(Sender: TObject);
begin
 case Sender of
  DirBrowseButton: begin
   WizardForm.DirBrowseButton.OnClick(nil);
   WOTListAddClient(WizardForm.DirEdit.Text);
  end;
  WOTList: begin
   if WOTList.Text = SetupMessage(msgWizardSelectDir) then begin
    WizardForm.DirBrowseButton.OnClick(nil);
    WOTListAddClient(WizardForm.DirEdit.Text);
   end;
  end;
 end;
 WOT_GetClientPathW(FindWOTBuff, 1024, WOTList.ItemIndex);
 WizardForm.DirEdit.Text := FindWOTBuff;
end;

Procedure InitializeFindWOT();
begin
 SetLength(FindWOTBuff, 1024);
 WOTListUpdate();

 if WOTList.ItemIndex = -1 then
  WOTList.ItemIndex := 0;
 WOTList.OnChange(nil);
end;