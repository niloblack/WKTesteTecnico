unit Controller.Pedidos;


interface

uses
  System.SysUtils,
  System.Classes,
  //System.Generics.Collections,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.Stan.Option,
  Config.Conexao,
  Model.Pedidos;

type
  TControllerPedidos = class
  private
    FModel: TModelPedidos;
    FQrPedido: TFDQuery;
    FQrItensPedido: TFDQuery;
  published
    property Model: TModelPedidos read FModel write FModel;
    property QrPedido: TFDQuery read FQrPedido write FQrPedido;
    property QrItensPedido: TFDQuery read FQrItensPedido write FQrItensPedido;
  public
    constructor Create;
    destructor Destroy; override;

    procedure PesquisarPorCodigo(Codigo: Integer);
    procedure Inserir();
  end;

implementation

{ TControllerProdutos }

constructor TControllerPedidos.Create;
begin
  FModel := TModelPedidos.Create();

  QrPedido := TFDQuery.Create(TConexao.GetInstance().FDConn);
  QrPedido.Connection := TConexao.GetInstance().FDConn;
  QrPedido.Transaction := TConexao.GetInstance().FDTrans;

  QrItensPedido := TFDQuery.Create(TConexao.GetInstance().FDConn);
  QrItensPedido.Connection := TConexao.GetInstance().FDConn;
  QrItensPedido.Transaction := TConexao.GetInstance().FDTrans;
end;

destructor TControllerPedidos.Destroy;
begin
  if FModel <> nil then
    FreeAndNil(FModel);

  inherited;
end;

procedure TControllerPedidos.PesquisarPorCodigo(Codigo: Integer);
begin
  if Codigo <= 0 then
  begin
    raise Exception.Create('Entre com um código válido!');
  end;

  TConexao.GetInstance().FDTrans.StartTransaction;
  try
    FQrPedido.Close;
    FQrPedido.SQL.Clear;
    FQrPedido.SQL.Add(' SELECT p.codigo, p.descricao, p.preco_venda ');
    FQrPedido.SQL.Add(' FROM tb_produtos p ');
    FQrPedido.SQL.Add(' WHERE codigo = :codigo ');
    FQrPedido.Params[0].AsInteger := Codigo;
    FQrPedido.Open;

    if TConexao.GetInstance().FDTrans.Active then
      TConexao.GetInstance().FDTrans.Commit;

//    FModel.Codigo     := QrPedido.Fields[0].AsInteger;
//    FModel.Descricao  := QrPedido.Fields[1].AsString;
//    FModel.PrecoVenda := QrPedido.Fields[2].AsFloat;
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

procedure TControllerPedidos.Inserir();
var
  I: Integer;
begin
  TConexao.GetInstance().FDTrans.StartTransaction;
  try
    FQrPedido.Close;
    FQrPedido.SQL.Clear;
    FQrPedido.SQL.Add(' INSERT INTO tb_pedidos(data_emissao, codigo_cliente, valor_total) ');
    FQrPedido.SQL.Add(' VALUES ( ');
    FQrPedido.SQL.Add(' CURRENT_DATE(), ');
    FQrPedido.SQL.Add(' :codigo_cliente, ');
    FQrPedido.SQL.Add(' :valor_total); ');
    FQrPedido.Params[0].AsInteger := FModel.CodigoCliente;
    FQrPedido.Params[1].AsFloat   := FModel.ValorTotal;
    FQrPedido.ExecSQL;

    // Pegar o código do pedido e jogar no campo
    Self.Model.Numero := 0;

    for I := 0 to Pred(FModel.Itens.Count) do
    begin
      FQrItensPedido.Close;
      FQrItensPedido.SQL.Clear;
      FQrItensPedido.SQL.Add(' INSERT INTO tb_itens_pedidos(numero_pedido, ');
      FQrItensPedido.SQL.Add(' codigo_produto, quantidade, valor_unitario, ');
      FQrItensPedido.SQL.Add(' valor_total) VALUES (, ');
      FQrItensPedido.SQL.Add(' :numero_pedido, ');
      FQrItensPedido.SQL.Add(' :codigo_produto, ');
      FQrItensPedido.SQL.Add(' :quantidade, ');
      FQrItensPedido.SQL.Add(' :valor_unitario, ');
      FQrItensPedido.SQL.Add(' :valor_total); ');
      FQrItensPedido.Params[0].AsInteger := FModel.Numero;
      FQrItensPedido.Params[1].AsFloat   := FModel.Itens.Items[I].CodigoProduto;
      FQrItensPedido.Params[2].AsFloat   := FModel.Itens.Items[I].Quantidade;
      FQrItensPedido.Params[3].AsFloat   := FModel.Itens.Items[I].ValorUnitario;
      FQrItensPedido.Params[4].AsFloat   := FModel.Itens.Items[I].ValorTotal;
      FQrItensPedido.ExecSQL;
    end;

    if TConexao.GetInstance().FDTrans.Active then
      TConexao.GetInstance().FDTrans.Commit;
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
            raise Exception.Create('Ocorreu um erro durante a inserção!');
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
