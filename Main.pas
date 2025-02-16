unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Math, Buttons;

type
  TfrmDraw3D = class(TForm)
    Image1: TImage;
    Panel2: TPanel;
    btnEdit: TButton;
    btnX_rot: TSpeedButton;
    btnY_rot: TSpeedButton;
    btnRot_z: TSpeedButton;
    edtPhi: TEdit;
    edtAlpha: TEdit;
    edtTheta: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnComposite: TButton;
    cbRepeat: TCheckBox;
    btnAbout: TButton;
    cbLabels: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnX_rotClick(Sender: TObject);
    procedure btnY_rotClick(Sender: TObject);
    procedure btnRot_zClick(Sender: TObject);
    procedure btnCompositeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure cbLabelsClick(Sender: TObject);
  private
    { Private declarations }
    BackBmp, FrontBMP : Tbitmap;
  public
    { Public declarations }
    Repeating : boolean;
    Num_points : integer;
    Points3D : Array[1..100] of Matrix_3by1;
    Connect : Array[1..100] of string;
    Function Rot_x(phi : extended) : Matrix_3by3;
    Function Rot_y(alpha : extended) : Matrix_3by3;
    Function Rot_z(theta : extended) : Matrix_3by3;
    Procedure DrawPoints;
  end;

var
  frmDraw3D: TfrmDraw3D;

implementation

uses edit, rbGraphics, about;

{$R *.DFM}


Procedure TfrmDraw3D.DrawPoints;
Var i, j, k : integer;
 function xpt(i : integer): integer;
  begin
   result := (backbmp.width div 2) +RayRound(points3D[i][1])
  end;
 function ypt(i : integer) : integer;
  begin
   result := (backbmp.height div 2) - RayRound(points3D[i][2])
  end;
 procedure draw_axes;
 begin
  With backbmp do
   begin
    canvas.pen.color := clgreen;
    canvas.pen.width := 1;
    canvas.font.name := 'Times New Roman';
    canvas.font.size := 20;
    canvas.font.style := [fsItalic, fsbold];
    canvas.font.color := clgreen;
    canvas.textout(width div 2 + 14, -8, 'y');
    canvas.textout(width -14, height div 2, 'x');
    canvas.moveto(0,height div 2);
    canvas.lineto(width, height div 2);
    DrawArrow(Canvas,width-10,height div 2, 10, 0, clgreen);
    canvas.moveto(width div 2, 0);
    canvas.lineto(width div 2, height);
    DrawArrow(Canvas,width div 2,10, 10, pi/2, clgreen);
   end;
 end;
begin
 with backbmp.canvas do
  begin
   Brush.color := clwhite;
   fillrect(Rect(0,0,width,height));
   draw_axes;
   for i := 1 to Num_points do
    begin
     pen.width := 1;
     pen.color := clblue;
     font.color := clgreen;
     font.size := 15;
     For j := 1 to length(connect[i]) do
      begin
       k := ord(connect[i][j])-96;
       moveto(xpt(i), ypt(i));
       lineto(xpt(k), ypt(k));
      end;
     pen.width := 3;
     pen.color := clblack;
     ellipse(xpt(i), ypt(i), xpt(i)+1, ypt(i)+1);
     If cblabels.checked then textout(xpt(i), ypt(i), chr(i+96));
    end;
  end;
 image1.canvas.draw(0,0,BackBMP);
 image1.refresh;
end;

Function TfrmDraw3D.Rot_x(phi : extended) : Matrix_3by3;
begin
 Result[1,1] := 1;
 Result[1,2] := 0;
 Result[1,3] := 0;
 Result[2,1] := 0;
 Result[2,2] := cos(phi);
 Result[2,3] := -sin(phi);
 Result[3,1] := 0;
 Result[3,2] := sin(phi);
 Result[3,3] := cos(phi);
end;

Function TfrmDraw3D.Rot_y(alpha : extended) : Matrix_3by3;
begin
 Result[1,1] := cos(alpha);
 Result[1,2] := 0;
 Result[1,3] := -sin(alpha);
 Result[2,1] := 0;
 Result[2,2] := 1;
 Result[2,3] := 0;
 Result[3,1] := sin(alpha);
 Result[3,2] := 0;
 Result[3,3] := cos(alpha);
end;

Function TfrmDraw3D.Rot_z(theta : extended) : Matrix_3by3;
begin
 Result[1,1] := cos(theta);
 Result[1,2] := -sin(theta);
 Result[1,3] := 0;
 Result[2,1] := sin(theta);
 Result[2,2] := cos(theta);
 Result[2,3] := 0;
 Result[3,1] := 0;
 Result[3,2] := 0;
 Result[3,3] := 1;
end;
procedure TfrmDraw3D.FormCreate(Sender: TObject);
begin
 BackBmp := Tbitmap.create;
 FrontBMP := Tbitmap.create;
 BackBmp.width := image1.width;
 FrontBmp.width := image1.width;
 Backbmp.height := image1.height;
 Frontbmp.height := image1.height;
 Image1.Picture.graphic :=Frontbmp;
end;

procedure TfrmDraw3D.FormDestroy(Sender: TObject);
begin
 BackBmp.free;
end;

procedure TfrmDraw3D.FormResize(Sender: TObject);
begin
 BackBmp.width := image1.width;
 FrontBmp.width := image1.width;
 Backbmp.height := image1.height;
 Frontbmp.height := image1.height;
 Image1.Picture.graphic := Frontbmp;
 drawpoints;
end;

procedure TfrmDraw3D.btnEditClick(Sender: TObject);
begin
 cbrepeat.checked := False;
 FrmEdit.show;
end;

procedure TfrmDraw3D.btnX_rotClick(Sender: TObject);
Var i : integer;
    Rot_Matrix : Matrix_3by3;
begin
 Rot_matrix := Rot_x(StrToFloat(edtPhi.text));
 For i := 1 to Num_points do
  Points3D[i] := Mult_Matrix_33by31(Rot_matrix, Points3D[i]);
 DrawPoints;
end;
procedure TfrmDraw3D.btnY_rotClick(Sender: TObject);
Var i : integer;
    Rot_Matrix : Matrix_3by3;
begin
 Rot_matrix := Rot_y(StrToFloat(edtAlpha.text));
 For i := 1 to Num_points do
  Points3D[i] := Mult_Matrix_33by31(Rot_matrix, Points3D[i]);
 DrawPoints;
end;

procedure TfrmDraw3D.btnRot_zClick(Sender: TObject);
Var i : integer;
    Rot_Matrix : Matrix_3by3;
begin
Rot_matrix := Rot_z(StrToFloat(edtTheta.text));
 For i := 1 to Num_points do
  Points3D[i] := Mult_Matrix_33by31(Rot_matrix, Points3D[i]);
 DrawPoints;
end;

procedure TfrmDraw3D.btnCompositeClick(Sender: TObject);
 Var i : integer;
     RotMatrix : Matrix_3by3;
begin
  RotMatrix := Mult_Matrix_33by33(Rot_y(StrToFloat(edtAlpha.text)),
               Rot_x(StrToFloat(edtPhi.text)));
  RotMatrix := Mult_Matrix_33by33(Rot_z(StrToFloat(edttheta.text)),
               RotMatrix);
  Repeat
   For i := 1 to Num_points do
    Points3D[i] := Mult_Matrix_33by31(Rotmatrix, Points3D[i]);
   DrawPoints;
   Application.processmessages;
  until NOT cbrepeat.checked;
end;

procedure TfrmDraw3D.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 cbRepeat.checked := false;
end;

procedure TfrmDraw3D.FormShow(Sender: TObject);
begin
 frmEdit.Readpoints;
 drawpoints;
end;

procedure TfrmDraw3D.btnAboutClick(Sender: TObject);
begin
 frmAbout.showmodal;
end;



procedure TfrmDraw3D.cbLabelsClick(Sender: TObject);
begin
 Drawpoints;
end;

end.
