program API_REST;

{$APPTYPE CONSOLE}

{$R *.res}

uses Horse, Horse.Jhonson, Horse.BasicAuthentication, Horse.Commons , System.JSON, System.SysUtils;

var
  App : THorse;
  Users : TJSONArray;

begin

  App := THorse.Create;

  App.Use(Jhonson);
  App.Use(HorseBasicAuthentication(
  function(const AUsername, APassword: string): Boolean
    begin
      Result := AUsername.Equals('user') and APassword.Equals('password');
    end));

  Users := TJSONArray.Create;

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



