unit Controller.Clientes;

interface

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Stan.Error,
  FireDAC.Stan.Option,
  Config.Conexao,
  Model.Clientes;

type
  TControllerClientes = class
  private
    FModel: TModelClientes;
    FQrClientes: TFDQuery;
  published
    property Model: TModelClientes read FModel write FModel;
    property QrClientes: TFDQuery read FQrClientes write FQrClientes;
  public
    constructor Create;
    destructor Destroy; override;

    procedure PesquisarPorCodigo(Codigo: Integer);
  end;

implementation

{ TControllerProdutos }

constructor TControllerClientes.Create;
begin
  FModel := TModelClientes.Create();

  QrClientes := TFDQuery.Create(TConexao.GetInstance().FDConn);
  QrClientes.Connection := TConexao.GetInstance().FDConn;
  QrClientes.Transaction := TConexao.GetInstance().FDTrans;
end;

destructor TControllerClientes.Destroy;
begin
  if FModel <> nil then
    FreeAndNil(FModel);

  inherited;
end;

procedure TControllerClientes.PesquisarPorCodigo(Codigo: Integer);
begin
  if Codigo <= 0 then
  begin
    raise Exception.Create('Entre com um código válido!');
  end;

  TConexao.GetInstance().FDTrans.StartTransaction;
  try
    QrClientes.Close;
    QrClientes.SQL.Clear;
    QrClientes.SQL.Add(' SELECT c.codigo, c.nome, c.cidade, c.uf ');
    QrClientes.SQL.Add(' FROM tb_clientes c ');
    QrClientes.SQL.Add(' WHERE c.codigo = :codigo ');
    QrClientes.Params[0].AsInteger := Codigo;
    QrClientes.Open;

    if TConexao.GetInstance().FDTrans.Active then
      TConexao.GetInstance().FDTrans.Commit;

    FModel.Codigo := QrClientes.Fields[0].AsInteger;
    FModel.Nome   := QrClientes.Fields[1].AsString;
    FModel.Cidade := QrClientes.Fields[2].AsString;
    FModel.UF     := QrClientes.Fields[3].AsString;
  except
    on Ex: EFDDBEngineException do
    begin
      if TConexao.GetInstance().FDTrans.Active then
        TConexao.GetInstance().FDTrans.Rollback;

      case Ex.Kind of
        ekServerGone:
          begin
            raise Exception.Create('Não foi possível se conectar com o servidor de dados!');
          end;

        else
          begin
            raise Exception.Create('Ocorreu um erro durante a pesquisa!');
          end;
      end
    end;

    on E: Exception do
    begin
      if TConexao.GetInstance().FDTrans.Active then
        TConexao.GetInstance().FDTrans.Rollback;
      raise Exception.Create(e.Message);
    end;
  end;
end;

end.
