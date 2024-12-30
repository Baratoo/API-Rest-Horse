object ServicesBairro: TServicesBairro
  OldCreateOrder = False
  Height = 150
  Width = 215
  object mtBairro: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 104
    Top = 48
    object mtBairroID: TIntegerField
      AutoGenerateValue = arAutoInc
      FieldName = 'ID'
    end
    object mtBairroNome: TStringField
      FieldName = 'Nome'
      Size = 100
    end
  end
end
