unit emr_Common;

interface

uses
  Classes, SysUtils, Vcl.ComCtrls, FireDAC.Comp.Client, System.Generics.Collections,
  emr_BLLServerProxy, FunctionIntf, frm_Hint;

const
  // ����ע���Сд���޸ĺ�Ҫ����sqlite���ж�Ӧ���ֶδ�Сдһ��
  // ���ز���
  PARAM_LOCAL_MSGHOST = 'MsgHost';    // ��Ϣ������IP
  PARAM_LOCAL_MSGPORT = 'MsgPort';    // ��Ϣ�������˿�
  PARAM_LOCAL_BLLHOST = 'BLLHost';    // ҵ�������IP
  PARAM_LOCAL_BLLPORT = 'BLLPort';    // ҵ��������˿�
  PARAM_LOCAL_UPDATEHOST = 'UpdateHost';  // ���·�����IP
  PARAM_LOCAL_UPDATEPORT = 'UpdatePort';  // ���·������˿�
  PARAM_LOCAL_DEPTCODE = 'DeptCode';  // ����
  PARAM_LOCAL_VERSIONID = 'VersionID';  // �汾��
  PARAM_LOCAL_PLAYSOUND = 'PlaySound';  // �����������
  // ����˲���
  PARAM_GLOBAL_HOSPITAL = 'Hospital';  // ҽԺ

type
  TClientParam = class(TObject)  // �ͻ��˲���(��Winƽ̨ʹ��)
  private
    FMsgServerIP, FBLLServerIP, FUpdateServerIP: string;
    FMsgServerPort, FBLLServerPort, FUpdateServerPort: Word;
    FTimeOut: Integer;
  public
    /// <summary> ��Ϣ������IP </summary>
    property MsgServerIP: string read FMsgServerIP write FMsgServerIP;

    /// <summary> ҵ�������IP </summary>
    property BLLServerIP: string read FBLLServerIP write FBLLServerIP;

    /// <summary> ���·�����IP </summary>
    property UpdateServerIP: string read FUpdateServerIP write FUpdateServerIP;

    /// <summary> ��Ϣ�������˿� </summary>
    property MsgServerPort: Word read FMsgServerPort write FMsgServerPort;

    /// <summary> ҵ��������˿� </summary>
    property BLLServerPort: Word read FBLLServerPort write FBLLServerPort;

    /// <summary> ���·������˿� </summary>
    property UpdateServerPort: Word read FUpdateServerPort write FUpdateServerPort;

    /// <summary> ��Ӧ��ʱʱ�� </summary>
    property TimeOut: Integer read FTimeOut write FTimeOut;
  end;

  TBLLServerReadyEvent = reference to procedure(const ABLLServerReady: TBLLServerProxy);
  TBLLServerRunEvent = reference to procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil);

  TOnErrorEvent = procedure(const AErrCode: Integer; const AParam: string) of object;

  TBLLServer = class(TObject)  // ҵ������
  protected
    FOnError: TOnErrorEvent;
    procedure DoServerError(const AErrCode: Integer; const AParam: string);
  public
    /// <summary>
    /// ����һ������˴���
    /// </summary>
    /// <returns></returns>
    class function GetBLLServerProxy: TBLLServerProxy;

    /// <summary>
    /// ��ȡ�����ʱ��
    /// </summary>
    /// <returns></returns>
    class function GetServerDateTime: TDateTime;

    /// <summary>
    /// ��ȡȫ��ϵͳ����
    /// </summary>
    /// <param name="AParamName"></param>
    /// <returns></returns>
    function GetParam(const AParamName: string): string;

    /// <summary>
    /// ��ȡҵ�������Ƿ���ָ��ʱ���ڿ���Ӧ
    /// </summary>
    /// <param name="AMesc"></param>
    /// <returns></returns>
    function GetBLLServerResponse(const AMesc: Word): Boolean;
    property OnError: TOnErrorEvent read FOnError write FOnError;
  end;

  TUpdateFile = class(TObject)  // �洢�����ļ���Ϣ
  private
    FFileName, FRelativePath, FVersion, FHash: string;
    FVerID: Integer;
    FSize: Int64;
    FEnforce: Boolean;
  public
    constructor Create; overload;
    constructor Create(const AFileName, ARelativePath, AVersion, AHash: string;
      const ASize: Int64; const AVerID: Integer; const AEnforce: Boolean); overload;
    destructor Destroy;

    /// <summary> �ļ��� </summary>
    property FileName: string read FFileName write FFileName;

    /// <summary> ���·�� </summary>
    property RelativePath: string read FRelativePath write FRelativePath;

    /// <summary> �ļ��汾�� </summary>
    property Version: string read FVersion write FVersion;

    /// <summary> �ļ�Hashֵ </summary>
    property Hash: string read FHash write FHash;

    /// <summary> �ļ���С </summary>
    property Size: Int64 read FSize write FSize;

    /// <summary> �ļ��汾��(�Ƚ��ļ��汾��ʹ��) </summary>
    property VerID: Integer read FVerID write FVerID;

    /// <summary> �ļ��Ƿ�ǿ������ </summary>
    property Enforce: Boolean read FEnforce write FEnforce;
  end;

  TCustomUserInfo = class(TObject)
  strict private
    FID: string;  // �û�ID
    FNameEx: string;  // �û���
    FDeptID: string;  // �û���������ID
    FDeptName: string;  // �û�������������
  protected
    procedure Clear; virtual;
    procedure SetUserID(const Value: string); virtual;
  public
    property ID: string read FID write SetUserID;
    property NameEx: string read FNameEx write FNameEx;
    property DeptID: string read FDeptID write FDeptID;
    property DeptName: string read FDeptName write FDeptName;
  end;

  TUserInfo = class(TCustomUserInfo)  // ��¼�û���Ϣ
  private
    FGroupDeptIDs: string;  // �û����й������Ӧ����
    FFunCDS: TFDMemTable;
    procedure IniUserInfo;  //�����û�������Ϣ
    procedure IniFuns;  // ����ָ���û����н�ɫ��Ӧ�Ĺ���
    procedure IniGroupDepts;  // ����ָ���û����й������Ӧ�Ŀ���
  protected
    procedure SetUserID(const Value: string); override;  // �û����н�ɫ��Ӧ�Ĺ���
    procedure Clear; override;
    /// <summary>
    /// �жϵ�ǰ�û��Ƿ���ĳ����Ȩ�ޣ���������ж�ADeptID�Ƿ��ڵ�ǰ�û�ʹ�øù���Ҫ��Ŀ��ҷ�Χ
    /// ��APerID�Ƿ��ǵ�ǰ�û�
    /// </summary>
    /// <param name="AFunID">����ID</param>
    /// <param name="ADeptID">����ID</param>
    /// <param name="APerID">�û�ID</param>
    /// <returns>True: �д�Ȩ��</returns>
    function FunAuth(const AFunID, ADeptID: Integer; const APerID: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    {���ڲ�ͬҽԺά���Ĺ��ܲ�ͬ��������ݿ���ͬһ����ID��Ӧ�Ŀ����ǲ�ͬ�Ĺ��ܣ�
       ���Դ��벻���ù���ID��Ϊ�����ж��Ƿ���Ȩ�ޣ���ʹ�ÿ����õĿؼ�������������}
    /// <summary>
    /// ���ݲ�������ID���������ж�ָ������ǿؼ��๦���Ƿ���Ȩ��(�����ڽ��о���������¼�ʱ�ж��û�����Ȩ��)
    /// </summary>
    /// <param name="AFormAuthControls">����������Ȩ�޹����Ŀؼ�����Ӧ�Ĺ���ID</param>
    /// <param name="AControlName">�ؼ�����</param>
    /// <param name="ADeptID">����</param>
    /// <param name="APerID">������</param>
    /// <returns>True: ��Ȩ�޲���</returns>
    function FormUnControlAuth(const AFormAuthControls: TFDMemTable; const AControlName: string;
      const ADeptID: Integer; const APerID: string): Boolean;

    /// <summary>
    /// ����ָ���Ŀ���ID����������Ϣ����ָ��������Ȩ�޿��ƿؼ���״̬(�����ڻ����л���ʱ�����û�����ѡ�л��ߵ�Ȩ�����ô���ؼ�״̬)
    /// </summary>
    /// <param name="AForm">����</param>
    /// <param name="ADeptID">����ID</param>
    /// <param name="APersonID">������</param>
    procedure SetFormAuthControlState(const AForm: TComponent; const ADeptID: Integer; const APersonID: string);

    /// <summary> ��ȡָ����������Ȩ�޿��ƵĿؼ���Ϣ�����ӵ�ǰ�û�Ȩ����Ϣ(�������û���¼���򿪴����) </summary>
    /// <param name="AForm">����</param>
    /// <param name="AAuthControls">����������Ȩ�޿��ƵĿؼ����ؼ���Ӧ�Ĺ���ID</param>
    procedure IniFormControlAuthInfo(const AForm: TComponent; const AAuthControls: TFDMemTable);

    property FunCDS: TFDMemTable read FFunCDS;
    property GroupDeptIDs: string read FGroupDeptIDs;
  end;

  TPatientInfo = class(TObject)
  private
    FInpNo, FBedNo, FNameEx, FSex, FAge, FDeptName: string;
    FPatID: Cardinal;
    FInHospDateTime, FInDeptDateTime: TDateTime;
    FCareLevel,  // ��������
    FVisitID  // סԺ����
      : Byte;
  protected
    procedure SetInpNo(const AInpNo: string);
  public
    procedure Assign(const ASource: TPatientInfo);
    property PatID: Cardinal read FPatID write FPatID;
    property NameEx: string read FNameEx write FNameEx;
    property Sex: string read FSex write FSex;
    property Age: string read FAge write FAge;
    property BedNo: string read FBedNo write FBedNo;
    property InpNo: string read FInpNo write SetInpNo;
    property InHospDateTime: TDateTime read FInHospDateTime write FInHospDateTime;
    property InDeptDateTime: TDateTime read FInDeptDateTime write FInDeptDateTime;
    property CareLevel: Byte read FCareLevel write FCareLevel;
    property VisitID: Byte read FVisitID write FVisitID;
    property DeptName: string read FDeptName write FDeptName;
  end;

  TRecordDeSetInfo = class(TObject)
  private
    FDesPID: Cardinal;
  public
    property DesPID: Cardinal read FDesPID write FDesPID;
  end;

  TRecordInfo = class(TObject)  // �ܷ�� TTemplateDeSetInfo �ϲ���
  private
    FID,
    FDesID  // ���ݼ�ID
      : Cardinal;
    //FSignature: Boolean;  // �ͷ��Ѿ�ǩ��
    FNameEx: string;
  public
    property ID: Cardinal read FID write FID;
    property DesID: Cardinal read FDesID write FDesID;
    //property Signature: Boolean read FSignature write FSignature;
    property NameEx: string read FNameEx write FNameEx;
  end;

  TDeSetInfo = class(TObject)  // ���ݼ���Ϣ
  public
    const
      // ���ݼ�
      /// <summary> ���ݼ����� </summary>
      CLASS_DATA = 1;
      /// <summary> ���ݼ�ҳü </summary>
      CLASS_HEADER = 2;
      /// <summary> ���ݼ�ҳ�� </summary>
      CLASS_FOOTER = 3;

      // ʹ�÷�Χ 1�ٴ� 2���� 3�ٴ�������
      /// <summary> ģ��ʹ�÷�Χ �ٴ� </summary>
      USERANG_CLINIC = 1;
      /// <summary> ģ��ʹ�÷�Χ ���� </summary>
      USERANG_NURSE = 2;
      /// <summary> ģ��ʹ�÷�Χ �ٴ������� </summary>
      USERANG_CLINICANDNURSE = 3;

      // סԺor���� 1סԺ 2���� 3סԺ������
      /// <summary> סԺ </summary>
      INOROUT_IN = 1;
      /// <summary> ���� </summary>
      INOROUT_OUT = 2;
      /// <summary> סԺ������ </summary>
      INOROUT_INOUT = 3;
  public
    ID, PID, GroupClass,  // ģ����� 1���� 2ҳü 3ҳ��
    GroupType,  // ģ������ 1���ݼ�ģ�� 2������ģ��
    UseRang,  // ʹ�÷�Χ 1�ٴ� 2���� 3�ٴ�������
    InOrOut  // סԺor���� 1סԺ 2���� 3סԺ������
      : Integer;
    GroupName: string;

    const
      Proc = 13;
  end;

  TTemplateInfo = class(TObject)  // ģ����Ϣ
    ID, Owner, OwnerID, DesID: Integer;
    NameEx: string;
  end;

  TUpdateHint = procedure(const AHint: string) of object;
  THintProcesEvent = reference to procedure(const AUpdateHint: TUpdateHint);

  procedure HintFormShow(const AHint: string; const AHintProces: THintProcesEvent);

  /// <summary>
  /// ͨ������ָ��ҵ�����ִ��ҵ��󷵻صĲ�ѯ����
  /// </summary>
  /// <param name="ABLLServerReady">׼������ҵ��</param>
  /// <param name="ABLLServerRun">����ִ��ҵ��󷵻ص�����</param>
  procedure BLLServerExec(const ABLLServerReady: TBLLServerReadyEvent; const ABLLServerRun: TBLLServerRunEvent);

    /// <summary>
  /// ��ȡ����˵�ǰ���µĿͻ��˰汾��
  /// </summary>
  /// <param name="AVerID">�汾ID(��Ҫ���ڱȽϰ汾)</param>
  /// <param name="AVerStr">�汾��(��Ҫ������ʾ�汾��Ϣ)</param>
  procedure GetLastVersion(var AVerID: Integer; var AVerStr: string);

  /// <summary>
  /// ����ָ���ĸ�ʽ�������
  /// </summary>
  /// <param name="AFormatStr">��ʽ</param>
  /// <param name="ASize">����</param>
  /// <returns>��ʽ��������</returns>
  function FormatSize(const AFormatStr: string; const ASize: Int64): string;

  function TreeNodeIsTemplate(const ANode: TTreeNode): Boolean;
  function TreeNodeIsRecordDeSet(const ANode: TTreeNode): Boolean;
  function TreeNodeIsRecord(const ANode: TTreeNode): Boolean;
  procedure GetTemplateContent(const ATempID: Cardinal; const AStream: TStream);
  procedure GetRecordContent(const ARecordID: Cardinal; const AStream: TStream);
  function GetDeSets: TObjectList<TDeSetInfo>;
  function GetDeSet(const AID: Integer): TDeSetInfo;
  function SignatureInchRecord(const ARecordID: Integer; const AUserID: string): Boolean;
  function GetInchRecordSignature(const ARecordID: Integer): Boolean;

var
  GClientParam: TClientParam;
  GRunPath: string;

implementation

uses
  Variants, emr_MsgPack, emr_BLLConst, emr_Entry, FireDAC.Stan.Intf, FireDAC.Stan.StorageBin;

var
  FDeSetInfos: TObjectList<TDeSetInfo>;

function GetDeSets: TObjectList<TDeSetInfo>;
begin
  if FDeSetInfos <> nil then
    Result := FDeSetInfos
  else
  begin
    BLLServerExec(
      procedure(const ABLLServerReady: TBLLServerProxy)
      begin
        ABLLServerReady.Cmd := BLL_GETDATAELEMENTSETROOT;  // ��ȡ���ݼ�(��Ŀ¼)��Ϣ
        ABLLServerReady.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
      end,
      procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
      var
        vDeSetInfo: TDeSetInfo;
      begin
        if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        begin
          raise Exception.Create(ABLLServer.MethodError);
          Exit;
        end;

        if AMemTable <> nil then
        begin
          FDeSetInfos := TObjectList<TDeSetInfo>.Create;

          with AMemTable do
          begin
            First;
            while not Eof do
            begin
              vDeSetInfo := TDeSetInfo.Create;
              vDeSetInfo.ID := FieldByName('id').AsInteger;
              vDeSetInfo.PID := FieldByName('pid').AsInteger;
              vDeSetInfo.GroupClass := FieldByName('Class').AsInteger;
              vDeSetInfo.GroupType := FieldByName('Type').AsInteger;
              vDeSetInfo.GroupName := FieldByName('Name').AsString;
              FDeSetInfos.Add(vDeSetInfo);

              Next;
            end;
          end;
        end;
      end);
  end;
end;

procedure HintFormShow(const AHint: string; const AHintProces: THintProcesEvent);
var
  vFrmHint: TfrmHint;
begin
  vFrmHint := TfrmHint.Create(nil);
  try
    vFrmHint.lblHint.Caption := AHint;
    vFrmHint.Show;

    AHintProces(vFrmHint.UpdateHint);
  finally
    FreeAndNil(vFrmHint);
  end;
end;

function GetDeSet(const AID: Integer): TDeSetInfo;
var
  i: Integer;
begin
  Result := nil;
  
  if FDeSetInfos = nil then
    GetDeSets;

  for i := 0 to FDeSetInfos.Count - 1 do
  begin
    if FDeSetInfos[i].ID = AID then
    begin
      Result := FDeSetInfos[i];
      Break;
    end;
  end;
end;

function SignatureInchRecord(const ARecordID: Integer; const AUserID: string): Boolean;
begin
  Result := False;

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_INCHRECORDSIGNATURE;  // סԺ����ǩ��
      ABLLServerReady.ExecParam.I['RID'] := ARecordID;
      ABLLServerReady.ExecParam.S['UserID'] := AUserID;
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        raise Exception.Create(ABLLServer.MethodError);
    end);

  Result := True;
end;

function GetInchRecordSignature(const ARecordID: Integer): Boolean;
var
  vSignatureCount: Integer;
begin
  Result := False;
  vSignatureCount := 0;

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETINCHRECORDSIGNATURE;  // ��ȡסԺ����ǩ����Ϣ
      ABLLServerReady.ExecParam.I['RID'] := ARecordID;
      ABLLServerReady.BackDataSet := True;
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        raise Exception.Create(ABLLServer.MethodError);

      if AMemTable <> nil then
        vSignatureCount := AMemTable.RecordCount;
    end);

  Result := vSignatureCount > 0;
end;

function TreeNodeIsTemplate(const ANode: TTreeNode): Boolean;
begin
  Result := (ANode <> nil) and (TObject(ANode.Data) is TTemplateInfo);
end;

function TreeNodeIsRecordDeSet(const ANode: TTreeNode): Boolean;
begin
  Result := (ANode <> nil) and (TObject(ANode.Data) is TRecordDeSetInfo);
end;

function TreeNodeIsRecord(const ANode: TTreeNode): Boolean;
begin
  Result := (ANode <> nil) and (TObject(ANode.Data) is TRecordInfo);
end;

procedure GetTemplateContent(const ATempID: Cardinal; const AStream: TStream);
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETTEMPLATECONTENT;  // ��ȡģ������ӷ����ģ��
      ABLLServerReady.ExecParam.I['TID'] := ATempID;
      ABLLServerReady.AddBackField('content');
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        raise Exception.Create(ABLLServer.MethodError);

      ABLLServer.BackField('content').SaveBinaryToStream(AStream);
    end);
end;

procedure GetRecordContent(const ARecordID: Cardinal; const AStream: TStream);
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETINCHRECORDCONTENT;  // ��ȡģ������ӷ����ģ��
      ABLLServerReady.ExecParam.I['RID'] := ARecordID;
      ABLLServerReady.AddBackField('content');
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        raise Exception.Create(ABLLServer.MethodError);

      ABLLServer.BackField('content').SaveBinaryToStream(AStream);
    end);
end;

procedure GetLastVersion(var AVerID: Integer; var AVerStr: string);
var
  vVerID: Integer;
  vVerStr: string;
begin
  vVerID := 0;
  vVerStr := '';
  BLLServerExec(
    procedure(const ABllServerReady: TBLLServerProxy)
    begin
      ABllServerReady.Cmd := BLL_GETLASTVERSION;  // ��ȡҪ���������°汾��
      ABllServerReady.AddBackField('id');
      ABllServerReady.AddBackField('Version');
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then
        raise Exception.Create(ABLLServer.MethodError);

      vVerID := ABLLServer.BackField('id').AsInteger;  // �汾ID
      vVerStr := ABLLServer.BackField('Version').AsString;  // �汾��
    end);
  AVerID := vVerID;
  AVerStr := vVerStr;
end;

function FormatSize(const AFormatStr: string; const ASize: Int64): string;
begin
  Result := '';
  if ASize < 1024 then  // �ֽ�
    Result := ASize.ToString + 'B'
  else
  if (ASize >= 1024) and (ASize < 1024 * 1024) then  // KB
    Result := FormatFloat(AFormatStr, ASize / 1024) + 'KB'
  else  // MB
    Result := FormatFloat(AFormatStr, ASize / (1024 * 1024)) + 'MB';
end;

{ TUserInfo }

procedure TUserInfo.Clear;
begin
  inherited Clear;
  FGroupDeptIDs := '';
  if not FFunCDS.IsEmpty then  // �������
    FFunCDS.EmptyDataSet;
end;

constructor TUserInfo.Create;
begin
  FFunCDS := TFDMemTable.Create(nil);
end;

destructor TUserInfo.Destroy;
begin
  FFunCDS.Free;
  inherited;
end;

function TUserInfo.FormUnControlAuth(const AFormAuthControls: TFDMemTable;
  const AControlName: string; const ADeptID: Integer;
  const APerID: string): Boolean;
begin

end;

function TUserInfo.FunAuth(const AFunID, ADeptID: Integer;
  const APerID: string): Boolean;
begin
  Result := False;
end;

procedure TUserInfo.IniFormControlAuthInfo(const AForm: TComponent;
  const AAuthControls: TFDMemTable);
//var
//  i: Integer;
begin
  // �Ƚ��ؼ���Ȩ�������ͷŷ�ֹ��һ�ε���ϢӰ�챾�ε���
//  for i := 0 to AForm.ComponentCount - 1 do
//  begin
//    if (AForm.Components[i] is TControl) and ((AForm.Components[i] as TControl).TagObject <> nil) then
//      (AForm.Components[i] as TControl).TagObject.Free;
//  end;
//
//  if not AAuthControls.IsEmpty then  // ������е�Ȩ�޿ؼ�����
//    AAuthControls.EmptyDataSet;
//
//  BLLServerExec(
//    procedure(const ABLLServer: TBLLServerProxy)
//    var
//      vExecParam: TMsgPack;
//    begin
//      ABLLServer.Cmd := BLL_GETCONTROLSAUTH;  // ��ȡָ��������������Ȩ�޿��ƵĿؼ�
//      vExecParam := ABLLServer.ExecParam;
//      vExecParam.S['FormName'] := AForm.Name;  // ������
//      ABLLServer.BackDataSet := True;
//    end,
//    procedure(const ABLLServer: TBLLServerProxy)
//
//    var
//      vHasAuth: Boolean;
//      vControl: TControl;
//      vCustomFunInfo: TCustomFunInfo;
//    begin
//      if not ABLLServer.MethodRunOk then
//        raise Exception.Create('�쳣����ȡ������Ȩ�޿��ƿؼ�����');
//
//      if not VarIsEmpty(ABLLServer.BLLDataSet) then  // ����Ȩ�޿��ƵĿؼ�����Ϊ��Ȩ��״̬
//      begin
//        AAuthControls.Data := ABLLServer.BLLDataSet;  // �洢��ǰ����������Ȩ�޹����Ŀؼ����ؼ���Ӧ�Ĺ���ID
//        AAuthControls.First;
//        while not AAuthControls.Eof do
//        begin
//          vHasAuth := False;
//          vControl := GetControlByName(AForm, AAuthControls.FieldByName('ControlName').AsString);
//          if vControl <> nil then  // �ҵ���Ȩ�޿��ƵĿؼ�
//          begin
//            // ���ƿؼ���״̬
//            if not GUserInfo.FunCDS.IsEmpty then  // ��ǰ�û��й���Ȩ������
//            begin
//              if GUserInfo.FunCDS.Locate('FunID', AAuthControls.FieldByName('FunID').AsInteger,
//                [TLocateOption.loCaseInsensitive])
//              then  // ��ǰ�û��д˹��ܵ�Ȩ��
//              begin
//                // ���ݵ�ǰ�û�ʹ�ô˹��ܵ�Ȩ�޷�Χ���ÿؼ���Ȩ������
//                if vControl.TagObject <> nil then  // ����ؼ���Ȩ�����������ͷ�
//                  vControl.TagObject.Free;
//
//                // ����ǰ�û�ʹ�øÿؼ���Ȩ�޷�Χ�󶨵��ؼ���
//                vCustomFunInfo := TCustomFunInfo.Create;
//                vCustomFunInfo.FunID := AAuthControls.FieldByName('FunID').AsInteger;
//                vCustomFunInfo.VisibleType := AAuthControls.FieldByName('VisibleType').AsInteger;
//                vCustomFunInfo.RangeID := GUserInfo.FunCDS.FieldByName('RangeID').AsInteger;
//                vCustomFunInfo.RangeDepts := GUserInfo.FunCDS.FieldByName('RangeDept').AsString;
//                vControl.TagObject := vCustomFunInfo;
//
//                vHasAuth := True;
//              end;
//            end;
//
//            if vHasAuth then  // �й��ܵ�Ȩ��
//            begin
//              vControl.Visible := True;
//              vControl.Enabled := True;
//            end
//            else  // ��ǰ�û��޴˹��ܵ�Ȩ��
//            begin
//              if AAuthControls.FieldByName('VisibleType').AsInteger = 0 then  // ��Ȩ��ʱ����ʾ
//                vControl.Visible := False
//              else
//              if AAuthControls.FieldByName('VisibleType').AsInteger = 1 then  // ��Ȩ��ʱ������
//              begin
//                vControl.Visible := True;
//                vControl.Enabled := False;
//              end;
//            end;
//          end;
//
//          AAuthControls.Next;
//        end;
//      end;
//    end);
end;

procedure TUserInfo.IniFuns;
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    var
      vExecParam: TMsgPack;
    begin
      ABLLServerReady.Cmd := BLL_GETUSERFUNS;  // ��ȡ�û����õ����й���
      vExecParam := ABLLServerReady.ExecParam;
      vExecParam.S[TUser.ID] := ID;
      ABLLServerReady.BackDataSet := True;
    end,
    procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServerRun.MethodRunOk then
        raise Exception.Create(ABLLServerRun.MethodError); // Exit;  // ShowMessage(ABLLServer.MethodError);

      if AMemTable <> nil then
      begin
        FFunCDS.Close;
        FFunCDS.Data := AMemTable.Data;
      end;
    end);
end;

procedure TUserInfo.IniGroupDepts;
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    var
      vExecParam: TMsgPack;
    begin
      ABLLServerReady.Cmd := BLL_GETUSERGROUPDEPTS;  // ��ȡָ���û����й������Ӧ�Ŀ���
      vExecParam := ABLLServerReady.ExecParam;
      vExecParam.S[TUser.ID] := ID;
      ABLLServerReady.BackDataSet := True;
    end,
    procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServerRun.MethodRunOk then
        raise Exception.Create(ABLLServerRun.MethodError);  //Exit;  // ShowMessage(ABLLServer.MethodError);

      if AMemTable <> nil then
      begin
        AMemTable.First;
        while not AMemTable.Eof do  // ��������
        begin
          if FGroupDeptIDs = '' then
            FGroupDeptIDs := AMemTable.FieldByName(TUser.DeptID).AsString
          else
            FGroupDeptIDs := FGroupDeptIDs + ',' + AMemTable.FieldByName(TUser.DeptID).AsString;

          AMemTable.Next;
        end;
      end;
    end);
end;

procedure TUserInfo.IniUserInfo;
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    var
      vExecParam: TMsgPack;
    begin
      ABLLServerReady.Cmd := BLL_GETUSERINFO;  // ��ȡָ���û�����Ϣ
      vExecParam := ABLLServerReady.ExecParam;
      vExecParam.S[TUser.ID] := ID;  // �û�ID

      ABLLServerReady.AddBackField(TUser.NameEx);
      ABLLServerReady.AddBackField(TUser.DeptID);
      ABLLServerReady.AddBackField(TUser.DeptName);
    end,

    procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServerRun.MethodRunOk then
        raise Exception.Create(ABLLServerRun.MethodError);  //Exit;

      NameEx := ABLLServerRun.BackField(TUser.NameEx).AsString;  // �û�����
      DeptID := ABLLServerRun.BackField(TUser.DeptID).AsString;  // ��������ID
      DeptName := ABLLServerRun.BackField(TUser.DeptName).AsString;  // ����
    end);
end;

procedure TUserInfo.SetFormAuthControlState(const AForm: TComponent;
  const ADeptID: Integer; const APersonID: string);
//var
//  i: Integer;
//  vControl: TControl;
begin
//  for i := 0 to AForm.ComponentCount - 1 do  // ������������пؼ�
//  begin
//    if AForm.Components[i] is TControl then
//    begin
//      vControl := AForm.Components[i] as TControl;
//      if vControl.TagObject <> nil then
//      begin
//        if Self.FunAuth((vControl.TagObject as TCustomFunInfo).FunID, ADeptID, APersonID) then  // ��Ȩ��
//        begin
//          vControl.Visible := True;
//          vControl.Enabled := True;
//        end
//        else  // û��Ȩ��
//        begin
//          if (vControl.TagObject as TCustomFunInfo).VisibleType = 0 then  // ��Ȩ�ޣ����ɼ�
//            vControl.Visible := False
//          else
//          if (vControl.TagObject as TCustomFunInfo).VisibleType = 1 then  // ��Ȩ�ޣ�������
//          begin
//            vControl.Visible := True;
//            vControl.Enabled := False;
//          end;
//        end;
//      end;
//    end;
//  end;
end;

procedure TUserInfo.SetUserID(const Value: string);
begin
  Clear;
  inherited SetUserID(Value);
  if ID <> '' then
  begin
    IniUserInfo;    // ȡ�û�������Ϣ
    IniGroupDepts;  // ȡ�������Ӧ�����п���
    IniFuns;        // ȡ��ɫ��Ӧ�����й��ܼ���Χ
  end;
end;

{ TBLLServer }

procedure BLLServerExec(const ABLLServerReady: TBLLServerReadyEvent; const ABLLServerRun: TBLLServerRunEvent);
var
  vBLLSrvProxy: TBLLServerProxy;
  vMemTable: TFDMemTable;
  vMemStream: TMemoryStream;
begin
  vBLLSrvProxy := TBLLServer.GetBLLServerProxy;
  try
    ABLLServerReady(vBLLSrvProxy);  // ���õ���ҵ��
    if vBLLSrvProxy.DispatchPack then  // �������Ӧ�ɹ�
    begin
      if vBLLSrvProxy.BackDataSet then  // �������ݼ�
      begin
        vMemTable := TFDMemTable.Create(nil);
        vMemStream := TMemoryStream.Create;
        try
          vBLLSrvProxy.GetBLLDataSet(vMemStream);
          vMemStream.Position := 0;
          vMemTable.LoadFromStream(vMemStream, TFDStorageFormat.sfBinary);
        finally
          FreeAndNil(vMemStream);
        end;
      end
      else
        vMemTable := nil;

      ABLLServerRun(vBLLSrvProxy, vMemTable);  // ����ִ��ҵ��󷵻صĲ�ѯ����
    end;
  finally
    if vMemTable <> nil then
      FreeAndNil(vMemTable);
    FreeAndNil(vBLLSrvProxy);
  end;
end;

procedure TBLLServer.DoServerError(const AErrCode: Integer;
  const AParam: string);
begin
  if Assigned(FOnError) then
    FOnError(AErrCode, AParam);
end;

class function TBLLServer.GetBLLServerProxy: TBLLServerProxy;
begin
  Result := TBLLServerProxy.CreateEx(GClientParam.BLLServerIP, GClientParam.BLLServerPort);
  Result.TimeOut := GClientParam.TimeOut;
  Result.ReConnectServer;
end;

function TBLLServer.GetBLLServerResponse(const AMesc: Word): Boolean;
var
  vServerProxy: TBLLServerProxy;
begin
  Result := False;
  vServerProxy := TBLLServerProxy.CreateEx(GClientParam.BLLServerIP, GClientParam.BLLServerPort);
  try
    vServerProxy.OnError := DoServerError;
    vServerProxy.TimeOut := AMesc;
    vServerProxy.ReConnectServer;
    Result := vServerProxy.Active;
  finally
    FreeAndNil(vServerProxy);
  end;
end;

function TBLLServer.GetParam(const AParamName: string): string;
var
  vBLLSrvProxy: TBLLServerProxy;
  vExecParam: TMsgPack;
begin
  vBLLSrvProxy := GetBLLServerProxy;
  try
    vBLLSrvProxy.Cmd := BLL_COMM_GETPARAM;  // ���û�ȡ����˲�������
    vExecParam := vBLLSrvProxy.ExecParam;  // ���ݵ�����˵Ĳ������ݴ�ŵ��б�
    vExecParam.S['Name'] := AParamName;
    vBLLSrvProxy.AddBackField('value');

    if vBLLSrvProxy.DispatchPack then  // ִ�з����ɹ�(����������ִ�еĽ��������ʾ����˳ɹ��յ��ͻ��˵��������Ҵ������)
      Result := vBLLSrvProxy.BackField('value').AsString;
  finally
    vBLLSrvProxy.Free;
  end;
end;

class function TBLLServer.GetServerDateTime: TDateTime;
var
  vBLLSrvProxy: TBLLServerProxy;
begin
  vBLLSrvProxy := GetBLLServerProxy;
  try
    vBLLSrvProxy.Cmd := BLL_SRVDT;  // ���û�ȡ�����ʱ�书��
    vBLLSrvProxy.AddBackField('dt');

    if vBLLSrvProxy.DispatchPack then  // ִ�з����ɹ�(����������ִ�еĽ��������ʾ����˳ɹ��յ��ͻ��˵��������Ҵ������)
      Result := vBLLSrvProxy.BackField('dt').AsDateTime;
  finally
    vBLLSrvProxy.Free;
  end;
end;

{ TCustomUserInfo }

procedure TCustomUserInfo.Clear;
begin
  FID := '';
  FNameEx := '';
end;

procedure TCustomUserInfo.SetUserID(const Value: string);
begin
  if FID <> Value then
    FID := Value;
end;

{ TPatientInfo }

procedure TPatientInfo.Assign(const ASource: TPatientInfo);
begin
  FInpNo := ASource.InpNo;
  FBedNo := ASource.BedNo;
  FNameEx := ASource.NameEx;
  FSex := ASource.Sex;
  FAge := ASource.Age;
  FDeptName := ASource.DeptName;
  FPatID := ASource.PatID;
  FInHospDateTime := ASource.InHospDateTime;
  FInDeptDateTime := ASource.InDeptDateTime;
  FCareLevel := ASource.CareLevel;
  FVisitID := ASource.VisitID;
end;

procedure TPatientInfo.SetInpNo(const AInpNo: string);
begin
  if FInpNo <> AInpNo then
  begin
    FInpNo := AInpNo;
  end;
end;

{ TUpdateFile }

constructor TUpdateFile.Create;
begin
  inherited Create;
end;

constructor TUpdateFile.Create(const AFileName, ARelativePath, AVersion,
  AHash: string; const ASize: Int64; const AVerID: Integer;
  const AEnforce: Boolean);
begin
  Create;
  FFileName := AFileName;
  FRelativePath := ARelativePath;
  FVersion := AVersion;
  FHash := AHash;
  FSize := ASize;
  FVerID := AVerID;
  FEnforce := AEnforce;
end;

destructor TUpdateFile.Destroy;
begin
  inherited Destroy;
end;

initialization

finalization
  if FDeSetInfos <> nil then
    FreeAndNil(FDeSetInfos);

end.