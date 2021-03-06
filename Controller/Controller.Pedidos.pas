unit Controller.Pedidos;

interface

uses
  System.SysUtils,
  System.Classes,
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

    procedure PesquisarPorNumero(Numero: Integer);
    procedure Inserir();
    function Deletar(Numero: Integer):Boolean;
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

procedure TControllerPedidos.PesquisarPorNumero(Numero: Integer);
begin
  if Numero <= 0 then
  begin
    raise Exception.Create('Entre com um n?mero v?lido!');
  end;

  TConexao.GetInstance().FDTrans.StartTransaction;
  try
    FQrPedido.Close;
    FQrPedido.SQL.Clear;
    FQrPedido.SQL.Add(' SELECT p.numero, p.data_emissao, p.codigo_cliente, c.nome, c.cidade, c.uf, p.valor_total ');
    FQrPedido.SQL.Add(' FROM tb_pedidos p, tb_clientes c ');
    FQrPedido.SQL.Add(' WHERE p.numero = :numero ');
    FQrPedido.SQL.Add(' AND p.codigo_cliente = c.codigo ');
    FQrPedido.Params[0].AsInteger := Numero;
    FQrPedido.Open;

    FQrItensPedido.Close;
    FQrItensPedido.SQL.Clear;
    FQrItensPedido.SQL.Add(' SELECT i.codigo_produto, i.quantidade, i.valor_unitario, i.valor_total, p.descricao ');
    FQrItensPedido.SQL.Add(' FROM tb_itens_pedidos i, tb_produtos p ');
    FQrItensPedido.SQL.Add(' WHERE i.numero_pedido = :numero_pedido ');
    FQrItensPedido.SQL.Add(' AND i.codigo_produto = p.codigo ');
    FQrItensPedido.Params[0].AsInteger := Numero;
    FQrItensPedido.Open;

    if TConexao.GetInstance().FDTrans.Active then
      TConexao.GetInstance().FDTrans.Commit;

    FModel.Numero        := FQrPedido.Fields[0].AsInteger;
    FModel.DataEmissao   := FQrPedido.Fields[1].AsDateTime;
    FModel.CodigoCliente := FQrPedido.Fields[2].AsInteger;
    FModel.NomeCliente   := FQrPedido.Fields[3].AsString;
    FModel.CidadeCliente := FQrPedido.Fields[4].AsString;
    FModel.UFCliente     := FQrPedido.Fields[5].AsString;
    FModel.ValorTotal    := FQrPedido.Fields[6].AsFloat;

    FQrItensPedido.First;
    while FQrItensPedido.Eof = False do
    begin
      with FModel.Itens.Add do
      begin
        CodigoProduto    := FQrItensPedido.Fields[0].AsInteger;
        DescricaoProduto := FQrItensPedido.Fields[4].AsString;
        Quantidade       := FQrItensPedido.Fields[1].AsFloat;
        ValorUnitario    := FQrItensPedido.Fields[2].AsFloat;
        ValorTotal       := FQrItensPedido.Fields[3].AsFloat;
      end;

      FQrItensPedido.Next;
    end;
  except
    on Ex: EFDDBEngineException do
    begin
      if TConexao.GetInstance().FDTrans.Active then
        TConexao.GetInstance().FDTrans.Rollback;

      case Ex.Kind of
        ekServerGone:
          begin
            raise Exception.Create('N?o foi poss?vel se conectar com o servidor de dados!');
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
    FQrPedido.SQL.Add(' SELECT LAST_INSERT_ID(); ');
    FQrPedido.Params[0].AsInteger := FModel.CodigoCliente;
    FQrPedido.Params[1].AsFloat   := FModel.ValorTotal;
    FQrPedido.Open;

    // Pegar o c?digo do pedido e jogar no campo
    Self.Model.Numero := StrToIntDef(FQrPedido.Fields[0].AsString, 0);

    for I := 0 to Pred(FModel.Itens.Count) do
    begin
      FQrItensPedido.Close;
      FQrItensPedido.SQL.Clear;
      FQrItensPedido.SQL.Add(' INSERT INTO tb_itens_pedidos(numero_pedido, ');
      FQrItensPedido.SQL.Add(' codigo_produto, quantidade, valor_unitario, ');
      FQrItensPedido.SQL.Add(' valor_total) VALUES ( ');
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
            raise Exception.Create('N?o foi poss?vel se conectar com o servidor de dados!');
          end;

        else
          begin
            raise Exception.Create('Ocorreu um erro durante a inser??o!');
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

function TControllerPedidos.Deletar(Numero: Integer):Boolean;
var
  I: Integer;
begin
  Result := False;
  TConexao.GetInstance().FDTrans.StartTransaction;
  try
    FQrPedido.Close;
    FQrPedido.SQL.Clear;
    FQrPedido.SQL.Add(' DELETE FROM tb_pedidos WHERE numero = :numero ');
    FQrPedido.Params[0].AsInteger := Numero;
    FQrPedido.ExecSQL;

    if TConexao.GetInstance().FDTrans.Active then
      TConexao.GetInstance().FDTrans.Commit;

    Result := FQrPedido.RowsAffected > 0;    
  except
    on Ex: EFDDBEngineException do
    begin
      if TConexao.GetInstance().FDTrans.Active then
        TConexao.GetInstance().FDTrans.Rollback;

      case Ex.Kind of
        ekServerGone:
          begin
            raise Exception.Create('N?o foi poss?vel se conectar com o servidor de dados!');
          end;

        else
          begin
            raise Exception.Create('Ocorreu um erro durante a exclus?o!');
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
