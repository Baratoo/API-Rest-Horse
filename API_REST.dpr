program API_REST;

{$APPTYPE CONSOLE}

{$R *.res}

uses Horse, Horse.Jhonson, Horse.BasicAuthentication, Horse.HandleException,
     Horse.Commons , System.JSON, System.SysUtils, System.Classes;

var
  App : THorse;
  Users : TJSONArray;

begin

  App := THorse.Create;

  App.Use(Jhonson);
  App.Use(HandleException);
  App.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
      begin
        Result := AUsername.Equals('root') and APassword.Equals('root');
      end));

  Users := TJSONArray.Create;

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

    App.Post('/EnviaStream',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      var
        LStream: TMemoryStream;
      begin
        LStream := req.Body<TMemoryStream>;
        LStream.SaveToFile('E:\KaiqueBarato\API Rest\img\CopyPenguins.jpg');
        Res.Send('Imagem salva!').Status(201);
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




