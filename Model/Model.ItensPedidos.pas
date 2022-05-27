unit Model.ItensPedidos;

interface

uses
  System.Classes;

type
  TModelItensPedidos = class(TCollectionItem)
  private
    FId: Integer;
    FNumeroPedido: Integer;
    FCodigoProduto: Integer;
    FDescricaoProduto: string;
    FQuantidade: Double;
    FValorUnitario: Double;
    FValorTotal: Double;

  published
    property Id: Integer read FId write FId;
    property NumeroPedido: Integer read FNumeroPedido write FNumeroPedido;
    property CodigoProduto: Integer read FCodigoProduto write FCodigoProduto;
    property DescricaoProduto: string read FDescricaoProduto write FDescricaoProduto;
    property Quantidade: Double read FQuantidade write FQuantidade;
    property ValorUnitario: Double read FValorUnitario write FValorUnitario;
    property ValorTotal: Double read FValorTotal write FValorTotal;

  public
    constructor Create; reintroduce;
    destructor Destroy; override;

  end;

implementation

{ TModelItensPedidos }

constructor TModelItensPedidos.Create;
begin

end;

destructor TModelItensPedidos.Destroy;
begin

  inherited;
end;

end.
