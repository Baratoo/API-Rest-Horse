program API_REST;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  Horse.BasicAuthentication,
  Horse.HandleException,
  Horse.Commons,
  Horse.octetStream,
  Horse.Logger,
  System.JSON,
  Horse.Logger.Provider.LogFile,
  Horse.Paginate,
  Horse.Etag,
  DataSet.Serialize,
  System.SysUtils,
  System.Classes,
  Services.Bairro in 'Services\Services.Bairro.pas' {ServicesBairro: TDataModule};

var
  App : THorse;
  Users : TJSONArray;
  LLogFileConfig : THorseLoggerLogFileConfig;

begin

   LLogFileConfig := THorseLoggerLogFileConfig.New
  .SetLogFormat('[${time}] ${response_status} ${request_method}')
  .SetDir('E:\KaiqueBarato\API Rest');

  THorseLoggerManager.RegisterProvider(THorseLoggerProviderLogFile.New(LLogFileConfig));

  App := THorse.Create;

  App.Use(Paginate);
  App.Use(Jhonson);
  App.Use(ETag);
  App.Use(HandleException);
  App.Use(octetStream);
  App.Use(THorseLoggerManager.HorseCallback);
  App.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
      begin
        Result := AUsername.Equals('root') and APassword.Equals('root');
      end));

  Users := TJSONArray.Create;

  //Como ficaria a URL com os parametros:
  //' /Bairros?limit=10&page=1 '
  App.Get('/Bairros',
    procedure(Req: THorseRequest; Res: THorseResponse; Next : TProc)
    var
      LService : TServicesBairro;
    begin
      LService := TServicesBairro.Create(nil);
      try
        Res.Send<TJSONArray>(LService.listar.ToJSONArray())
      finally
        LService.Free;
      end;
    end);

  App.Get('/exception',
    procedure(Req: THorseRequest; Res: THorseResponse; Next : TProc)
    var
      LConteudo :TJSONObject;
    begin
        raise EHorseException.New.Error('ERROR');
        LConteudo := TJSONObject.Create;
        LConteudo.AddPair('Nome', 'Kaique');
        Res.Send(LConteudo);
    end);

  App.Get('/stream',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LStream: TFileStream;
    begin
      LStream := TFileStream.Create('E:\KaiqueBarato\API Rest\img\Penguins.jpg', fmOpenRead);
      Res.Send<TStream>(LStream);
    end);

  App.Post('/stream',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LStream: TMemoryStream;
    begin
      LStream := req.Body<TMemoryStream>;
      LStream.SaveToFile('E:\KaiqueBarato\API Rest\img\CopyPenguins.jpg');
      Res.Send('Imagem salva!').Status(201);
    end);

  App.Get('/usersEtag',
    procedure(Req: THorseRequest; Res: THorseResponse; Next : TProc)
    begin
      Res.Send<TJSONObject>(TJSONObject.Create.AddPair('Login', 'Kaique'));
    end);

  App.Get('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next : TProc)
    begin
      Res.Send<TJSONAncestor>(Users.Clone);
    end);

  App.Post('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next : TProc)
    var
      User : TJSONObject;
    begin
      User := Req.Body<TJSONObject>.Clone as TJSONObject;
      Users.AddElement(User);
      Res.Send<TJSONAncestor>(User.Clone).Status(THTTPStatus.Created);
    end);

  App.Delete('/users/:id',
    procedure(Req: THorseRequest; Res: THorseResponse; Next : TProc)
    var
      id :Integer;
    begin
      id := Req.Params.Items['id'].ToInteger;
      Users.Remove(Pred(id)).Free;
      Res.Send<TJSONAncestor>(Users.Clone).Status(THTTPStatus.NoContent);
    end);


  App.Listen(9000);

end.




