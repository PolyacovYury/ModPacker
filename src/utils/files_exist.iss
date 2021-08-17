// © Kotyarko_O, 2020 \\

[Code]
Function FilesExists(Files: Array of String): Boolean;
var
 I: Integer;
begin
 Result := False;
 for I := 0 to GetArrayLength(Files) - 1 do
  if not FileExists(ExpandConstant(Files[I])) then
   Exit;
 Result := True;
end;
