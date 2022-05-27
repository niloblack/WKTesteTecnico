unit Model.Produtos;

interface

type
  TModelProdutos = class
  private
    FCodigo: Integer;
    FDescricao: string;
    FPrecoVenda: Double;

  published
    property Codigo: Integer read FCodigo write FCodigo;
    property Descricao: string read FDescricao write FDescricao;
    property PrecoVenda: Double read FPrecoVenda write FPrecoVenda;

  end;

implementation

{ TModelProdutos }

end.
