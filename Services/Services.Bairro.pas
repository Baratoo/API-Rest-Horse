unit Services.Bairro;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TServicesBairro = class(TDataModule)
    mtBairro: TFDMemTable;
    mtBairroID: TIntegerField;
    mtBairroNome: TStringField;
  private
  public
    function listar : TDataSet;
  end;

implementation

{$R *.dfm}

{ TServicesBairro }

function TServicesBairro.listar: TDataSet;
var
  I :Integer;
begin
  mtBairro.Open;
  Result := mtBairro;
  for I := 1 to 200 do
  begin
    mtBairro.Append;
    mtBairroNome.AsString := 'Bairro ' + I.ToString;
    mtBairro.Post;
  end;
end;

end.
