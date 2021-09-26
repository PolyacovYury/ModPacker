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

[Files]
Source: "src\utils\findwot\findwot.dll"; Flags: ignoreversion nocompression dontcopy;

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
