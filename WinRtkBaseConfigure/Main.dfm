object fmMain: TfmMain
  Left = 368
  Top = 125
  BorderStyle = bsToolWindow
  Caption = 'Win RtkBase Configure'
  ClientHeight = 420
  ClientWidth = 201
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefaultSizeOnly
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object gbWifi: TGroupBox
    Left = 8
    Top = 104
    Width = 185
    Height = 97
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Wifi'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object lbKey: TLabel
      Left = 8
      Top = 48
      Width = 18
      Height = 13
      Caption = 'Key'
      Enabled = False
    end
    object lbSSID: TLabel
      Left = 8
      Top = 24
      Width = 28
      Height = 13
      Caption = 'SSID:'
      Enabled = False
    end
    object edSSID: TEdit
      Left = 56
      Top = 24
      Width = 121
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 0
      OnChange = SaveChange
    end
    object edKey: TEdit
      Left = 56
      Top = 48
      Width = 121
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 1
    end
    object cbHidden: TCheckBox
      Left = 8
      Top = 72
      Width = 97
      Height = 17
      BiDiMode = bdLeftToRight
      Caption = 'Hidden SSID'
      Enabled = False
      ParentBiDiMode = False
      TabOrder = 2
    end
  end
  object gbSet: TGroupBox
    Left = 8
    Top = 8
    Width = 185
    Height = 89
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Using'
    Color = clBtnFace
    ParentColor = False
    TabOrder = 1
    object cbWifi: TCheckBox
      Left = 8
      Top = 16
      Width = 169
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'WiFi'
      TabOrder = 0
      OnClick = cbWifiClick
    end
    object cbCountry: TCheckBox
      Left = 8
      Top = 40
      Width = 169
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'WiFi Country'
      TabOrder = 1
      OnClick = cbCountryClick
    end
    object cbUser: TCheckBox
      Left = 8
      Top = 64
      Width = 169
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'User'
      TabOrder = 2
      OnClick = cbUserClick
    end
  end
  object gbCountry: TGroupBox
    Left = 8
    Top = 208
    Width = 185
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Wifi Country'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object cbxCountry: TComboBox
      Left = 8
      Top = 24
      Width = 169
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      ItemHeight = 13
      TabOrder = 0
      OnChange = SaveChange
    end
  end
  object gbUser: TGroupBox
    Left = 8
    Top = 272
    Width = 185
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Caption = 'User'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    object lbLogin: TLabel
      Left = 8
      Top = 24
      Width = 26
      Height = 13
      Caption = 'Login'
      Enabled = False
    end
    object lbPwd: TLabel
      Left = 8
      Top = 48
      Width = 41
      Height = 13
      Caption = 'Pasword'
      Enabled = False
    end
    object edLogin: TEdit
      Left = 56
      Top = 24
      Width = 121
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 0
      OnChange = SaveChange
    end
    object edPwd: TEdit
      Left = 56
      Top = 48
      Width = 121
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 1
      OnChange = SaveChange
    end
    object btnSSH: TButton
      Left = 8
      Top = 72
      Width = 169
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Load SSH public key'
      Enabled = False
      TabOrder = 2
      OnClick = btnSSHClick
    end
  end
  object btnSave: TButton
    Left = 8
    Top = 384
    Width = 129
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Save'
    Enabled = False
    TabOrder = 4
    OnClick = btnSaveClick
  end
  object btntQuit: TButton
    Left = 146
    Top = 384
    Width = 47
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = 'Quit'
    ModalResult = 2
    TabOrder = 5
    OnClick = btntQuitClick
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'pub'
    Filter = '*.pub|*.pub|All|*.*'
    Options = [ofReadOnly, ofEnableSizing]
    Title = 'SSH public key'
    Left = 144
    Top = 40
  end
end
