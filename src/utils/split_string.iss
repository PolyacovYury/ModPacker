[Code]
// https://stackoverflow.com/a/37916394
function StrSplit(Text: String; Separator: String): TStrings;
var
  p: Integer;
begin
  Result := TStringList.Create();
  while Length(Text) > 0 do begin
    p := Pos(Separator,Text);
    if p > 0 then begin
      Result.Append(Copy(Text, 1, p-1));
      Text := Copy(Text, p + Length(Separator), Length(Text));
    end else begin
      Result.Append(Text);
      Text := '';
    end;
  end;
end;
