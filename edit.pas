unit edit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, Spin;

type
  TfrmEdit = class(TForm)
    Panel1: TPanel;
    btnDraw: TButton;
    Label1: TLabel;
    spnNum_Points: TSpinEdit;
    grdEdit: TStringGrid;
    btnLoad: TButton;
    btnSave: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure btnDrawClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure spnNum_PointsChange(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    PathName : string;
    Procedure ChangeGrid;
    Procedure ReadPoints;
  end;

var
  frmEdit: TfrmEdit;

implementation

uses Main, Inifiles;

{$R *.DFM}


Procedure TfrmEdit.ChangeGrid;
Var i : integer;
begin
 With grdEdit do
  begin
   rowcount := spnNum_points.value+1;
   For i := 1 to spnNum_points.value do
    begin
     cells[0,i] := chr(i+96)+':';
    end;
  end;
end;


Procedure TfrmEdit.ReadPoints;
Var i,j : integer;
begin
 frmDraw3D.Num_Points := spnNum_points.value;
 with grdedit do
 For i := 1 to spnNum_points.value do
  begin
   for j := 1 to 3 do
    FrmDraw3D.Points3D[i][j] := strtoint(cells[j,i]);
   FrmDraw3D.connect[i] := cells[4,i];
  end;
end;

procedure TfrmEdit.btnDrawClick(Sender: TObject);
begin
  ReadPoints;
  frmDraw3D.show;
  frmDraw3D.drawpoints;
end;

procedure TfrmEdit.FormCreate(Sender: TObject);
begin
 With grdEdit do
  begin
   cells[0,0] := 'Point';
   cells[1,0] := 'x';
   cells[2,0] := 'y';
   cells[3,0] := 'z';
   cells[4,0] := 'Connected to:';
   cells[1,1] := '-40';
   cells[2,1] := '0';
   cells[3,1] := '-40';
   cells[1,2] := '40';
   cells[2,2] := '40';
   cells[3,2] := '-40';
   cells[1,3] := '40';
   cells[2,3] := '-40';
   cells[3,3] := '-40';
   cells[1,4] := '0';
   cells[2,4] := '0';
   cells[3,4] := '100';
   cells[4,1] := 'b';
   cells[4,2] := 'c';
   cells[4,3] := 'a';
   cells[4,4] := 'abc';
   ChangeGrid;
  end;
end;

procedure TfrmEdit.spnNum_PointsChange(Sender: TObject);
begin
 ChangeGrid;
end;

procedure TfrmEdit.btnLoadClick(Sender: TObject);
Var MyIniFile : Tinifile;
    i         : integer;
begin
 If opendialog1.execute then
  begin
   PathName := opendialog1.filename;
   caption := 'Edit points and lines ['+extractfilename(PathName)+']';
   MyIniFile := TIniFile.Create(PathName);
   spnNum_points.value := MyInifile.ReadInteger('General', 'Number of points',1);
   For i := 1 to spnNum_points.value do
    with grdedit, MyInifile do
    begin
     cells[1,i] := ReadString('Point'+inttostr(i),'x','');
     cells[2,i] := ReadString('Point'+inttostr(i),'y','');
     cells[3,i] := ReadString('Point'+inttostr(i),'z','');
     cells[4,i] := ReadString('Point'+inttostr(i),'connected to','');
    end;
  MyIniFile.Free;
  end;
end;

procedure TfrmEdit.btnSaveClick(Sender: TObject);
Var MyIniFile : Tinifile;
    i         : integer;
begin
 If Savedialog1.execute then
  begin
   PathName := Savedialog1.filename;
   caption := 'Edit points and lines ['+extractfilename(PathName)+']';
   MyIniFile := TIniFile.Create(PathName);
   MyInifile.WriteInteger('General', 'Number of points',spnNum_points.value);
   For i := 1 to spnNum_points.value do
    with grdedit, MyInifile do
    begin
     WriteString('Point'+inttostr(i),'x',cells[1,i]);
     WriteString('Point'+inttostr(i),'y',cells[2,i]);
     WriteString('Point'+inttostr(i),'z',cells[3,i]);
     WriteString('Point'+inttostr(i),'connected to',cells[4,i]);
    end;
  MyIniFile.Free;
 end;
end;

end.
