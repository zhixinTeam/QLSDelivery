//----------------------------------- ͨ�� -------------------------------------
{.$DEFINE DEBUG}
//����ģʽ

{.$DEFINE TrialVersion}
//���ð汾

{$DEFINE UseReport}
//����֧��

{.$DEFINE RandomID}
//ʹ��������

{$DEFINE cxLibrary42}
//Ver4.2���뻷��

{.$DEFINE EnableBackupDB}
//�������ݿ�֧��
{.$DEFINE EnableDoubleDB}
//˫���ݿ�֧��

//---------------------------------- �м�� ------------------------------------
{.$DEFINE ClientMon}
//�����ػ��ͻ���

{$DEFINE HardMon}
//����Ӳ���ػ�

{.$DEFINE GenRODL}
//����RODL��Դ

{$DEFINE COM_MIT}
//����ϵͳģʽ

//ͨ���м��
{$IFDEF COM_MIT}
  {$DEFINE DBPool}
  //�������ݿ�֧��
  {.$DEFINE ChannelPool}
  //����ͨ��֧��
  {.$DEFINE AutoChannel}
  //����ͨ��ƽ��
  {.$DEFINE SAP}
  //����SAP֧��
  {.$DEFINE ClientMon}
  //֧���ػ�����
{$ENDIF}

//--------------------------------- �ض�ϵͳ -----------------------------------
{.$DEFINE COMMON}
//ͨ�ð汾

{$DEFINE QLS}
//�ض�ϵͳ

//����ɽ
{$IFDEF QLS}
  {$DEFINE COMMON}
  //ͨ�ð汾
  {$DEFINE AppAtTaskBar}
  //״̬����ʾ
  {$DEFINE HYRFID201}
  //�����ͷ
  {$DEFINE GLPURCH} 
  //���˲ɹ�
  {.$DEFINE YDKP} 
  //���ǡ��ĺӡ�������ƽ����Ʊ
  {.$DEFINE XHPZ} 
  //�ĺӡ�������ƽ��Ƥ��
  {.$DEFINE ZXKP} 
  //����
  {.$DEFINE GGJC} 
  //�ʹȡ����������Զ�����
  {.$DEFINE CXSY} 
  //�����������
  {.$DEFINE LZST} 
  //��������ˮ���ȵ�
{$ENDIF}