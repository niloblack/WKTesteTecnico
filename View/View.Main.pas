unit View.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  dxGDIPlusClasses, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.Buttons,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, StrUtils;

type
  TTipoOperacao = (toInsercao, toEdicao);
  TFrmMain = class(TForm)
    pnlMenu: TPanel;
    imgCandidato: TImage;
    lblNome: TLabel;
    lblDescricaoCandidato: TLabel;
    bvl01: TBevel;
    lblQuestoes: TLabel;
    bvl02: TBevel;
    mmMiniCurriculo: TMemo;
    imgWK: TImage;
    pnlPedido: TPanel;
    pnlTopo: TPanel;
    lblTipo: TLabel;
    DBGrdItensPedido: TDBGrid;
    edtClienteSelecionado: TEdit;
    edtCodigoProduto: TEdit;
    edtQuantidade: TEdit;
    edtValorUnitario: TEdit;
    btnIncluirProduto: TButton;
    lblProduto: TLabel;
    lblItensPedido: TLabel;
    bvl03: TBevel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    bvl04: TBevel;
    lblTotalPedido: TLabel;
    lblRS: TLabel;
    lblValorTotalPedido: TLabel;
    btnGravarPedido: TButton;
    FDMT_ItensPedido: TFDMemTable;
    DS_ItensPedido: TDataSource;
    FDMT_ItensPedidodescricao_produto: TStringField;
    FDMT_ItensPedidocodigo_produto: TIntegerField;
    FDMT_ItensPedidoquantidade: TFloatField;
    FDMT_ItensPedidovalor_unitario: TFloatField;
    FDMT_ItensPedidovalor_total: TFloatField;
    FDMT_ItensPedidovalor_total_pedido: TAggregateField;
    edtCodigoCliente: TEdit;
    edtCidadeCliente: TEdit;
    edtUFCliente: TEdit;
    procedure FormActivate(Sender: TObject);
    procedure btnIncluirProdutoClick(Sender: TObject);
    procedure edtCodigoProdutoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtQuantidadeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtValorUnitarioKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtCodigoProdutoExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DBGrdItensPedidoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnGravarPedidoClick(Sender: TObject);
    procedure edtCodigoClienteExit(Sender: TObject);
    procedure edtCodigoClienteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FCodigoClienteSelecionado: string;
    procedure PesquisarProduto(Codigo: Integer);
    procedure PrepararCampos(Tipo: TTipoOperacao = toInsercao);
    procedure InserirProduto();
    procedure AlterarProduto();
    procedure PesquisarCliente(Codigo: Integer);
  public
    { Public declarations }
    property CodigoClienteSelecionado: string read FCodigoClienteSelecionado write FCodigoClienteSelecionado;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  Controller.Clientes,
  Controller.Produtos,
  Controller.Pedidos;

procedure TFrmMain.DBGrdItensPedidoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (FDMT_ItensPedido.RecordCount > 0) then
  begin
    if( MessageDlg('Deseja realmente apagar o registro selecionado?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes ) then
    begin
      Abort;
    end;

    FDMT_ItensPedido.Delete;
  end;

  // Edição
  if (Key = VK_RETURN) and (FDMT_ItensPedido.RecordCount > 0) then
  begin
    FDMT_ItensPedido.Edit;
    PrepararCampos(toEdicao);
  end;
end;

procedure TFrmMain.PrepararCampos(Tipo: TTipoOperacao = toInsercao);
begin
  btnIncluirProduto.Caption := IfThen(Tipo = toInsercao, 'Incluir Produto', 'Confirmar');
  edtCodigoProduto.Enabled := Tipo = toInsercao;
  DBGrdItensPedido.Enabled := Tipo = toInsercao;
  edtCodigoProduto.Text := IfThen(Tipo = toInsercao, '', FDMT_ItensPedidocodigo_produto.AsString);
  edtQuantidade.Text    := IfThen(Tipo = toInsercao, '1,00', FDMT_ItensPedidoquantidade.AsString);
  edtValorUnitario.Text := IfThen(Tipo = toInsercao, '', FDMT_ItensPedidovalor_unitario.AsString);

  if Tipo = toInsercao then
    edtCodigoProduto.SetFocus
      else
        edtQuantidade.SetFocus;
end;

procedure TFrmMain.edtCodigoClienteExit(Sender: TObject);
begin
  if (StrToIntDef(edtCodigoProduto.Text, 0)) > 0 then
  begin
    PesquisarCliente(StrToIntDef(edtCodigoCliente.Text, 0));
    edtClienteSelecionado.SetFocus();
  end;
end;

procedure TFrmMain.edtCodigoClienteKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    edtClienteSelecionado.SetFocus();
  end;
end;

procedure TFrmMain.PesquisarCliente(Codigo: Integer);
var
  ControllerCliente: TControllerClientes;
begin
  ControllerCliente := TControllerClientes.Create();
  try
    try
      ControllerCliente.PesquisarPorCodigo(Codigo);
    except
      on E:Exception do
      begin
        MessageDlg(e.Message, mtError, [mbOk], 0);
      end;
    end;

    if ControllerCliente.Model.Codigo > 0 then
    begin
      FCodigoClienteSelecionado  := IntToStr(ControllerCliente.Model.Codigo);
      edtClienteSelecionado.Text := ControllerCliente.Model.Nome;
      edtCidadeCliente.Text      := ControllerCliente.Model.Cidade;
      edtUFCliente.Text          := ControllerCliente.Model.UF;
    end
      else
      begin
        FCodigoClienteSelecionado := '';
        edtClienteSelecionado.Text := 'Cliente não selecionado';
        edtCidadeCliente.Text := '';
        edtUFCliente.Text := '';
      end;
  finally
    ControllerCliente.Free;
  end;
end;

procedure TFrmMain.edtCodigoProdutoExit(Sender: TObject);
begin
  if (StrToIntDef(edtCodigoProduto.Text, 0)) > 0 then
  begin
    PesquisarProduto(StrToIntDef(edtCodigoProduto.Text, 0));
    edtQuantidade.SetFocus();
  end;
end;

procedure TFrmMain.edtCodigoProdutoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    edtQuantidade.SetFocus();
  end;
end;

procedure TFrmMain.PesquisarProduto(Codigo: Integer);
var
  ControllerProduto: TControllerProdutos;
begin

  ControllerProduto := TControllerProdutos.Create();
  try
    try
      ControllerProduto.PesquisarPorCodigo(Codigo);
    except
      on E:Exception do
      begin
        MessageDlg(e.Message, mtError, [mbOk], 0);
      end;
    end;

    if ControllerProduto.Model.Codigo > 0 then
    begin
      edtValorUnitario.Text := FormatFloat('#0.00', ControllerProduto.Model.PrecoVenda);
    end
      else
      begin
        MessageDlg('Nenhum produto encontrado com esse código!', mtWarning, [mbOk], 0);
        edtCodigoProduto.SetFocus();
        Abort;
      end;
  finally
    ControllerProduto.Free;
  end;
end;

procedure TFrmMain.edtQuantidadeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    edtValorUnitario.SetFocus();
  end;
end;

procedure TFrmMain.edtValorUnitarioKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    btnIncluirProduto.Click();
  end;
end;

procedure TFrmMain.btnGravarPedidoClick(Sender: TObject);
var
  ControllerPedido: TControllerPedidos;
begin
  if Trim(Self.CodigoClienteSelecionado) = EmptyStr then
  begin
    MessageDlg('Selecione o cliente antes de gravar o pedido!', mtWarning, [mbOk], 0);
    edtCodigoProduto.SetFocus;
    Abort;
  end;

  if FDMT_ItensPedido.RecordCount = 0 then
  begin
    MessageDlg('Não há itens a ser lançados!', mtWarning, [mbOk], 0);
    edtCodigoProduto.SetFocus;
    Abort;
  end;

  ControllerPedido := TControllerPedidos.Create();
  try
    ControllerPedido.Model.CodigoCliente := StrToInt(Self.CodigoClienteSelecionado);
    ControllerPedido.Model.ValorTotal    := FDMT_ItensPedidovalor_total_pedido.AsFloat;

    FDMT_ItensPedido.First;
    while FDMT_ItensPedido.Eof = False do
    begin
      with ControllerPedido.Model.Itens.Add do
      begin
        CodigoProduto := FDMT_ItensPedidocodigo_produto.AsInteger;
        Quantidade    := FDMT_ItensPedidoquantidade.AsFloat;
        ValorUnitario := FDMT_ItensPedidovalor_unitario.AsFloat;
        ValorTotal    := FDMT_ItensPedidovalor_total_pedido.AsFloat;
      end;

      FDMT_ItensPedido.Next;
    end;

    ControllerPedido.Inserir();
  finally
    ControllerPedido.Free;
  end;
end;

procedure TFrmMain.btnIncluirProdutoClick(Sender: TObject);
begin
  if StrToIntDef(edtCodigoProduto.Text, 0) = 0 then
  begin
    MessageDlg('Entre com um código válido para o produto!', mtWarning, [mbOk], 0);
    edtCodigoProduto.SetFocus();
    Abort;
  end;

  if StrToFloatDef(edtQuantidade.Text, 0) = 0 then
  begin
    MessageDlg('Entre com uma quantidade válida para o produto!', mtWarning, [mbOk], 0);
    edtQuantidade.SetFocus();
    Abort;
  end;

  if StrToFloatDef(edtValorUnitario.Text, 0) = 0 then
  begin
    MessageDlg('Entre com um valor válido para o produto!!', mtWarning, [mbOk], 0);
    edtValorUnitario.SetFocus();
    Abort;
  end;

  // Se for edição fa
  if FDMT_ItensPedido.State = dsEdit then
  begin
    AlterarProduto();
  end
    else
    begin
      InserirProduto();
    end;
end;

procedure TFrmMain.InserirProduto();
var
  ControllerProduto: TControllerProdutos;
begin
  ControllerProduto := TControllerProdutos.Create();
  try
    try
      ControllerProduto.PesquisarPorCodigo(StrToIntDef(edtCodigoProduto.Text, 0));
    except
      on E:Exception do
      begin
        MessageDlg(e.Message, mtError, [mbOk], 0);
      end;
    end;

    if ControllerProduto.Model.Codigo = 0 then
    begin
      MessageDlg('Nenhum produto encontrado com esse código!', mtWarning, [mbOk], 0);
      edtCodigoProduto.SetFocus();
      Abort;
    end;

    FDMT_ItensPedido.Append;
    FDMT_ItensPedidocodigo_produto.AsInteger   := ControllerProduto.Model.Codigo;
    FDMT_ItensPedidodescricao_produto.AsString := ControllerProduto.Model.Descricao;
    FDMT_ItensPedidoquantidade.AsFloat         := StrToFloatDef(edtQuantidade.Text, 0);
    FDMT_ItensPedidovalor_unitario.AsFloat     := StrToFloatDef(edtValorUnitario.Text, 0);
    FDMT_ItensPedidovalor_total.AsFloat        := StrToFloatDef(edtQuantidade.Text, 0) * StrToFloatDef(edtValorUnitario.Text, 0);
    FDMT_ItensPedido.Post;

    // Atualiza o label de valor total
    lblValorTotalPedido.Caption := FormatFloat(',0.00', StrToFloatDef(FDMT_ItensPedidovalor_total_pedido.AsString, 0));

    PrepararCampos(toInsercao);
  finally
    ControllerProduto.Free;
  end;
end;

procedure TFrmMain.AlterarProduto();
var
  ControllerProduto: TControllerProdutos;
begin
  FDMT_ItensPedidoquantidade.AsFloat         := StrToFloatDef(edtQuantidade.Text, 0);
  FDMT_ItensPedidovalor_unitario.AsFloat     := StrToFloatDef(edtValorUnitario.Text, 0);
  FDMT_ItensPedidovalor_total.AsFloat        := StrToFloatDef(edtQuantidade.Text, 0) * StrToFloatDef(edtValorUnitario.Text, 0);
  FDMT_ItensPedido.Post;

  // Atualiza o label de valor total
  lblValorTotalPedido.Caption := FormatFloat(',0.00', StrToFloatDef(FDMT_ItensPedidovalor_total_pedido.AsString, 0));
  PrepararCampos(toInsercao);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  FDMT_ItensPedido.Open;
  FDMT_ItensPedido.EmptyDataSet;
end;

procedure TFrmMain.FormActivate(Sender: TObject);
begin
  if edtCodigoProduto.Enabled then
    edtCodigoProduto.SetFocus;
end;

end.
