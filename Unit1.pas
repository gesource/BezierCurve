unit Unit1;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.ScrollBox,
  FMX.Memo;

type
  TMyPanel = class(TPanel)
  const
    GRAB_SIZE: Integer = 3;
  private
    PointArray: array [0 .. 3] of TPointF;
    FPointNumber: Integer;
    FMoveFlag: Boolean;
    FSelectionPoint: array [0 .. 3] of TSelectionPoint;

    procedure PanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure PanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  protected
    procedure DoPaint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure InitPoint;
  end;

  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { private êÈåæ }
  public
    { public êÈåæ }
    MyPanel: TMyPanel;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
{ TMyPanel }

procedure TForm1.FormCreate(Sender: TObject);
begin
  // TMyPanelÇê∂ê¨ÇµÇƒîzíu
  MyPanel := TMyPanel.Create(Self);
  MyPanel.Parent := Self;
  MyPanel.Position.X := 10;
  MyPanel.Position.Y := 10;
  MyPanel.Width := Self.ClientWidth - 20;
  MyPanel.Height := Self.ClientHeight - 20;
  MyPanel.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop,
    TAnchorKind.akRight, TAnchorKind.akBottom];
  MyPanel.InitPoint;
end;

{ TMyPanel }

constructor TMyPanel.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;
  Self.FPointNumber := -1;
  Self.FMoveFlag := False;
  Self.OnMouseDown := Self.PanelMouseDown;
  Self.OnMouseUp := Self.PanelMouseUp;
  Self.OnMouseMove := Self.PanelMouseMove;
end;

procedure TMyPanel.DoPaint;
var
  Path: TPathData;
  Line1, Line2: TPathData;
begin
  inherited;

  Path := TPathData.Create;
  Path.MoveTo(Self.FSelectionPoint[0].Position.Point);
  Path.CurveTo(Self.FSelectionPoint[1].Position.Point,
    Self.FSelectionPoint[2].Position.Point,
    Self.FSelectionPoint[3].Position.Point);

  Line1 := TPathData.Create;
  Line1.MoveTo(Self.FSelectionPoint[0].Position.Point);
  Line1.LineTo(Self.FSelectionPoint[1].Position.Point);

  Line2 := TPathData.Create;
  Line2.MoveTo(Self.FSelectionPoint[2].Position.Point);
  Line2.LineTo(Self.FSelectionPoint[3].Position.Point);

  Canvas.BeginScene;
  Canvas.Stroke.Color := TAlphaColorRec.Blue;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Thickness := 1;
  Canvas.DrawPath(Path, 1.0);

  Canvas.Stroke.Color := TAlphaColorRec.Black;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Dash := TStrokeDash.Dot;
  Canvas.Stroke.Thickness := 1;
  Canvas.DrawPath(Line1, 1.0);
  Canvas.DrawPath(Line2, 1.0);

  Canvas.EndScene;
  Path.Free;
  Line1.Free;
  Line2.Free;
end;

procedure TMyPanel.InitPoint;
var
  I: Integer;
begin
  Self.PointArray[0] := PointF(50, 50);
  Self.PointArray[1] := PointF(Self.Width - 50, 50);
  Self.PointArray[2] := PointF(50, Self.Height - 50);
  Self.PointArray[3] := PointF(Self.Width - 50, Self.Height - 50);

  for I := 0 to 3 do
  begin
    FSelectionPoint[I] := TSelectionPoint.Create(Self);
    FSelectionPoint[I].Parent := Self;
    FSelectionPoint[I].Position.X := PointArray[I].X;
    FSelectionPoint[I].Position.Y := PointArray[I].Y;
    FSelectionPoint[I].Width := 3;
    FSelectionPoint[I].Height := 3;
    FSelectionPoint[I].HitTest := False;
  end;
end;

procedure TMyPanel.PanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button = TMouseButton.mbLeft then
  begin
    Self.FMoveFlag := True;
  end;
end;

procedure TMyPanel.PanelMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
var
  ARect: TRectF;
  I: Integer;
begin
  if Self.FMoveFlag then
  begin
    if Self.FPointNumber = -1 then
      Exit;
    Self.FSelectionPoint[Self.FPointNumber].Position.X := X;
    Self.FSelectionPoint[Self.FPointNumber].Position.Y := Y;
    Repaint;
  end
  else
  begin
    Self.FPointNumber := -1;
    for I := 0 to 3 do
    begin
      ARect := RectF(Self.FSelectionPoint[I].Position.X - GRAB_SIZE - 1,
        Self.FSelectionPoint[I].Position.Y - GRAB_SIZE - 1,
        Self.FSelectionPoint[I].Position.X + GRAB_SIZE + 1,
        Self.FSelectionPoint[I].Position.Y + GRAB_SIZE + 1);

      if PtInRect(ARect, PointF(X, Y)) then
        Self.FPointNumber := I;
    end;
  end;
end;

procedure TMyPanel.PanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  Self.FMoveFlag := False;
end;

end.
