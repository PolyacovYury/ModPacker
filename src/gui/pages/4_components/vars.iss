[Code]
Type
 TPreviewImagePos = record
  Top, Left, Width, Height: Integer;
 end;

 TComponentsList = record
  List: TNewCheckListBox;
  ItemsIndex: Array of Integer;
  NeedsVolume: Boolean;
  OldProc: LongInt;
 end;

var
 ComponentsPageName: TLabel;
 ComponentsLists: Array of TComponentsList;
 ComponentsPageActiveIndex: Integer;
 DescriptionMemo: TMemo;
 ComponentsBGShape1: TBevel;
 PreviewImage: Longint;
 PreviewImagePos: TPreviewImagePos;
 CurrentImage: String;
 BassVolumeBar: TBitmapImage;
 BassVolumeLbl: TLabel;
 BassWarningResult: Integer;
