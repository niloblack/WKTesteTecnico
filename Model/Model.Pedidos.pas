unit Model.Pedidos;

interface

uses
  System.Classes,
  Model.ItensPedidos;

type
  TItensPedidosCollection = class;

  TModelPedidos = class
  private
    FNumero: Integer;
    FDataEmissao: TDate;
    FCodigoCliente: Integer;
    FValorTotal: Double;
    FItens: TItensPedidosCollection;
    FNomeCliente: string;
    FCidadeCliente: string;
    FUFCliente: string;

  published
    property Numero: Integer read FNumero write FNumero;
    property DataEmissao: TDate read FDataEmissao write FDataEmissao;
    property CodigoCliente: Integer read FCodigoCliente write FCodigoCliente;
    property NomeCliente: string read FNomeCliente write FNomeCliente;
    property CidadeCliente: string read FCidadeCliente write FCidadeCliente;
    property UFCliente: string read FUFCliente write FUFCliente;
    property ValorTotal: Double read FValorTotal write FValorTotal;
    property Itens: TItensPedidosCollection read FItens write FItens;

  public
    constructor Create;
    destructor Destroy; override;

  end;

  TItensPedidosCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TModelItensPedidos;
    procedure SetItem(Index: Integer; Value: TModelItensPedidos);
  public
    constructor Create(AOwner: TModelPedidos);
    function Add: TModelItensPedidos;
    property Items[Index: Integer]: TModelItensPedidos read GetItem write SetItem; default;
  end;

implementation

{ TModelPedidos }

constructor TModelPedidos.Create;
begin
  inherited;
  FItens := TItensPedidosCollection.Create(Self);
end;

destructor TModelPedidos.Destroy;
begin
  FItens.Free;
  inherited;
end;

{ TItensPedidosCollection }

function TItensPedidosCollection.Add: TModelItensPedidos;
begin
  Result := TModelItensPedidos(inherited Add);
  Result.create;
end;

constructor TItensPedidosCollection.Create(
  AOwner: TModelPedidos);
begin
  inherited Create(TModelItensPedidos);
end;

function TItensPedidosCollection.GetItem(Index: Integer): TModelItensPedidos;
begin
  Result := TModelItensPedidos(inherited GetItem(Index));
end;

procedure TItensPedidosCollection.SetItem(Index: Integer;
  Value: TModelItensPedidos);
begin
  inherited SetItem(Index, Value);
end;

end.
