unit Model.Clientes;

interface

type
  TModelClientes = class
  private
    FCodigo: Integer;
    FNome: string;
    FCidade: string;
    FUF: string;

  published
    property Codigo: Integer read FCodigo write FCodigo;
    property Nome: string read FNome write FNome;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write FUF;

  end;

implementation

{ TModelClientes }

end.
