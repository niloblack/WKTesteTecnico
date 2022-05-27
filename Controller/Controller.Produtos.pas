unit Controller.Produtos;

interface

uses
  System.SysUtils,
  //System.Generics.Collections,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Stan.Error,
  FireDAC.Stan.Option,
  Config.Conexao,
  Model.Produtos;

type
  TControllerProdutos = class
  private
    FModel: TModelProdutos;
    FQrProdutos: TFDQuery;
  published
    property Model: TModelProdutos read FModel write FModel;
    property QrProdutos: TFDQuery read FQrProdutos write FQrProdutos;
  public
    constructor Create;
    destructor Destroy; override;

    procedure PesquisarPorCodigo(Codigo: Integer);
  end;

implementation

{ TControllerProdutos }

constructor TControllerProdutos.Create;
begin
  FModel := TModelProdutos.Create();

  QRProdutos := TFDQuery.Create(TConexao.GetInstance().FDConn);
  QrProdutos.Connection := TConexao.GetInstance().FDConn;
  QrProdutos.Transaction := TConexao.GetInstance().FDTrans;
end;

destructor TControllerProdutos.Destroy;
begin
  if FModel <> nil then
    FreeAndNil(FModel);

  inherited;
end;

procedure TControllerProdutos.PesquisarPorCodigo(Codigo: Integer);
begin
  if Codigo <= 0 then
  begin
    raise Exception.Create('Entre com um código válido!');
  end;

  TConexao.GetInstance().FDTrans.StartTransaction;
  try
    QrProdutos.Close;
    QrProdutos.SQL.Clear;
    QrProdutos.SQL.Add(' SELECT p.codigo, p.descricao, p.preco_venda ');
    QrProdutos.SQL.Add(' FROM tb_produtos p ');
    QrProdutos.SQL.Add(' WHERE p.codigo = :codigo ');
    QrProdutos.Params[0].AsInteger := Codigo;
    QrProdutos.Open;

    if TConexao.GetInstance().FDTrans.Active then
      TConexao.GetInstance().FDTrans.Commit;

    FModel.Codigo     := QrProdutos.Fields[0].AsInteger;
    FModel.Descricao  := QrProdutos.Fields[1].AsString;
    FModel.PrecoVenda := QrProdutos.Fields[2].AsFloat;
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
