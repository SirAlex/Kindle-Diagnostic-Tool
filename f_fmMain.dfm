object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Sir Alex'#39's Kindle Diagnostic Tool : v1.0a'
  ClientHeight = 510
  ClientWidth = 687
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 444
    Top = 25
    Width = 4
    Height = 466
    Align = alRight
    ExplicitLeft = 474
    ExplicitTop = 1
    ExplicitHeight = 469
  end
  object pnLog: TPanel
    Left = 0
    Top = 25
    Width = 444
    Height = 466
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 0
    ExplicitLeft = 32
    ExplicitTop = 112
    ExplicitWidth = 345
    ExplicitHeight = 305
    object log: TMemo
      Left = 2
      Top = 2
      Width = 440
      Height = 462
      Align = alClient
      BorderStyle = bsNone
      Lines.Strings = (
        'Program log:')
      TabOrder = 0
      ExplicitTop = -2
    end
  end
  object pnInfo: TPanel
    Left = 448
    Top = 25
    Width = 239
    Height = 466
    Align = alRight
    BevelInner = bvLowered
    PopupMenu = ppmCopyInfo
    TabOrder = 1
    ExplicitTop = 0
    ExplicitHeight = 471
    object cxLabel1: TLabel
      Left = 6
      Top = 72
      Width = 61
      Height = 13
      Caption = 'Drive Letter:'
      Transparent = True
    end
    object lbDriveLetterVal: TLabel
      Left = 77
      Top = 72
      Width = 15
      Height = 13
      Caption = '---'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lbModel: TLabel
      Left = 6
      Top = 49
      Width = 32
      Height = 13
      Caption = 'Model:'
      Transparent = True
    end
    object lbModelVal: TLabel
      Left = 48
      Top = 49
      Width = 15
      Height = 13
      Caption = '---'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lbPass: TLabel
      Left = 6
      Top = 26
      Width = 99
      Height = 13
      Caption = 'Recovery password:'
      Transparent = True
    end
    object lbPassVal: TLabel
      Left = 115
      Top = 26
      Width = 15
      Height = 13
      Caption = '---'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lbSN: TLabel
      Left = 6
      Top = 3
      Width = 70
      Height = 13
      Caption = 'Serial Number:'
      Transparent = True
    end
    object lbSNVal: TLabel
      Left = 86
      Top = 3
      Width = 15
      Height = 13
      Caption = '---'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      OnClick = lbSNValClick
    end
  end
  object sBar: TStatusBar
    Left = 0
    Top = 491
    Width = 687
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitLeft = 352
    ExplicitTop = 256
    ExplicitWidth = 0
  end
  object ActionMainMenuBar1: TActionMainMenuBar
    Left = 0
    Top = 0
    Width = 687
    Height = 25
    UseSystemFont = False
    ActionManager = acmMain
    Caption = 'ActionMainMenuBar1'
    Color = clMenuBar
    ColorMap.HighlightColor = clWhite
    ColorMap.UnusedColor = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Spacing = 0
    ExplicitLeft = 2
    ExplicitTop = 2
    ExplicitWidth = 440
    ExplicitHeight = 29
  end
  object aclMain: TActionList
    Left = 88
    Top = 136
    object acRefresh: TAction
      Caption = '&Refresh'
      ImageIndex = 0
      OnExecute = acRefreshExecute
    end
    object acCopyInfo: TAction
      Caption = 'Copy all info to clipboard'
      OnExecute = acCopyInfoExecute
    end
    object acEject: TAction
      Caption = '&Eject Kindle'
      ImageIndex = 1
      OnExecute = acEjectExecute
      OnUpdate = acEjectUpdate
    end
    object FileExit1: TFileExit
      Category = 'File'
      Caption = 'E&xit'
      Hint = 'Exit|Quits the application'
      ImageIndex = 43
    end
  end
  object tmrRefresh: TTimer
    Enabled = False
    Left = 40
    Top = 200
  end
  object ppmCopyInfo: TPopupMenu
    Left = 136
    Top = 136
    object Copytoclipboard1: TMenuItem
      Action = acCopyInfo
    end
  end
  object acmMain: TActionManager
    ActionBars = <
      item
        Items = <
          item
            Action = FileExit1
            ImageIndex = 43
          end>
      end
      item
        Items = <
          item
            Items = <
              item
                Action = acRefresh
                ImageIndex = 0
              end
              item
                Action = acEject
                ImageIndex = 1
              end
              item
                Caption = '-'
              end
              item
                Action = FileExit1
                ImageIndex = 43
              end>
            Caption = '&File'
          end>
        ActionBar = ActionMainMenuBar1
      end>
    LinkedActionLists = <
      item
        ActionList = aclMain
        Caption = 'Main Actions'
      end>
    Left = 40
    Top = 136
    StyleName = 'Platform Default'
  end
end
