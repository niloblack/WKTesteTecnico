unit Config.Conexao;

interface

uses
    IniFiles,
    SysUtils,
    Forms,
    FireDAC.Comp.Client,
    Dialogs,
    StrUtils,
    Threading,
    Data.DB,
    FireDAC.Stan.Intf,
    FireDAC.Stan.Option,
    FireDAC.Comp.DataSet,
    FireDAC.Stan.Error,
    FireDAC.UI.Intf,
    FireDAC.Phys.Intf,
    FireDAC.Stan.Def,
    FireDAC.Stan.Pool,
    FireDAC.Stan.Async,
    FireDAC.Phys,
    FireDAC.VCLUI.Wait,
    FireDAC.Phys.FBDef,
    FireDAC.Phys.MySQLDef,
    FireDAC.Phys.IBBase,
    FireDAC.Phys.FB,
    FireDAC.Phys.MySQL,
    FireDAC.Comp.UI,
    FireDAC.Stan.Param,
    FireDAC.DatS,
    FireDAC.DApt.Intf,
    FireDAC.DApt;

type
   TConexao = class(TObject)
    strict private
     class var FInstance: TConexao;
     constructor CreatePrivate();

   private
      FPath: string;
      FServidor: string;
      FPorta: integer;
      FDatabase: string;
      FSenha: string;
      FUsuario: string;
      FDriver: string;
      FSecao: string;

   protected
      FDConnection1: TFDConnection;
      FDTransaction1: TFDTransaction;
      FDGUIxWaitCursor1: TFDGUIxWaitCursor;
      FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;

   public
      property Path : string read FPath write FPath;
      property Servidor : string read FServidor write FServidor;
      property Porta : integer read FPorta write FPorta;
      property Database : string read FDatabase write FDatabase;
      property Senha : string read FSenha write FSenha;
      property Usuario : string read FUsuario write FUsuario;
      property Driver : string read FDriver write FDriver;
      property Secao : string read FSecao write FSecao;

      property FDConn: TFDConnection read FDConnection1;
      property FDTrans: TFDTransaction read FDTransaction1;

      constructor Create();
      class function GetInstance(): TConexao;
      class procedure ClearInstance; static;

      procedure LerINI(); virtual;
      procedure Conectar(); virtual;
   end;

implementation

constructor TConexao.Create();
begin
  raise Exception.Create('Para obter uma instância de TConexao, use TConexao.GetInstance');
end;

class function TConexao.GetInstance: TConexao;
begin
  if not Assigned(FInstance) then
    FInstance := TConexao.CreatePrivate;

  Result := FInstance;
end;

constructor TConexao.CreatePrivate();
var
  Path: string;
  Secao: string;
begin
  inherited Create;

  FDConnection1 := TFDConnection.Create(nil);
  FDConnection1.LoginPrompt := False;

  FDTransaction1 := TFDTransaction.Create(nil);
  FDTransaction1.Connection := FDConnection1;

  FDGUIxWaitCursor1 := TFDGUIxWaitCursor.Create(nil);
  FDGUIxWaitCursor1.Provider := 'Forms';

  FDPhysMySQLDriverLink1 := TFDPhysMySQLDriverLink.Create(nil);

  Path := ExtractFilePath(Application.ExeName) + 'Configuracao.ini';
  Secao := 'DATABASE';

  if FileExists(Path) then
  begin
     Self.Path := Path;
     Self.Secao := Secao;
     Conectar();
  end
    else
      raise Exception.Create('Arquivo INI para configuração não encontrado.'#13#10'Aplicação será finalizada.');
end;

procedure TConexao.Conectar();
begin
  LerINI();

  try
    FDConnection1.Connected := False;
    FDConnection1.LoginPrompt := False;
    FDConnection1.Params.Clear;
    FDConnection1.Params.Add('server='+ FServidor);
    FDConnection1.Params.Add('user_name='+ FUsuario);
    FDConnection1.Params.Add('password='+ FSenha);
    FDConnection1.Params.Add('port='+ IntToStr(FPorta));
    FDConnection1.Params.Add('Database='+ FDatabase);
    FDConnection1.Params.Add('DriverID='+ FDriver);
    FDConnection1.Connected := True;
  except
    on e:exception do
    begin
      FDConnection1.Connected := False;
      raise Exception.Create('Ocorreu um erro ao carregar parâmetros de conexão com o banco de dados!');
    end;
  end;
end;

class procedure TConexao.ClearInstance;
begin
  FInstance := nil;
end;

procedure TConexao.LerINI();
var
  ArqIni : TIniFile;
begin
  ArqIni := TIniFile.Create(Path);
  try
    Servidor := ArqIni.ReadString(Secao, 'ip', '');
    Database := ArqIni.ReadString(Secao, 'host', '');
    Porta    := ArqIni.ReadInteger(Secao, 'port', 0);
    Usuario  := ArqIni.ReadString(Secao, 'user', '');
    Senha    := ArqIni.ReadString(Secao, 'password', '');
    Driver   := ArqIni.ReadString(Secao, 'drivername', '');
  finally
     ArqIni.Free;
  end;
end;

end.
