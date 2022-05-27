program WKTechnology;

uses
  Vcl.Forms,
  Config.Conexao in 'Config\Config.Conexao.pas',
  View.Main in 'View\View.Main.pas' {FrmMain},
  Controller.Produtos in 'Controller\Controller.Produtos.pas',
  Controller.Pedidos in 'Controller\Controller.Pedidos.pas',
  Model.Produtos in 'Model\Model.Produtos.pas',
  Model.Pedidos in 'Model\Model.Pedidos.pas',
  Model.ItensPedidos in 'Model\Model.ItensPedidos.pas',
  Controller.Clientes in 'Controller\Controller.Clientes.pas',
  Model.Clientes in 'Model\Model.Clientes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
