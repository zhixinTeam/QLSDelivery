        ��  ��                  �  0   ��
 R O D L F I L E                     <?xml version="1.0" encoding="utf-8"?>
<Library Name="MyLibrary" UID="{C9714D0F-BE9C-4E22-AD7A-AFEC3EA58BDC}" Version="3.0">
<Services>
<Service Name="RemService" UID="{A41AA3E0-92A5-401C-829C-254577E92169}">
<Interfaces>
<Interface Name="Default" UID="{6E787EC4-8E42-4530-AD4A-06726D310F3E}">
<Documentation><![CDATA[Service RemService. This service has been automatically generated using the RODL template you can find in the Templates directory.]]></Documentation>
<Operations>
<Operation Name="GetServerTime" UID="{6C3E320B-C251-494D-95B1-8081AFF08095}">
<Parameters>
<Parameter Name="Result" DataType="DateTime" Flag="Result">
</Parameter>
</Parameters>
</Operation>
<Operation Name="DL2WRZSINFO" UID="{501477B6-E8C1-4212-AE53-B2A3BF91A510}">
<Parameters>
<Parameter Name="Result" DataType="Integer" Flag="Result">
</Parameter>
<Parameter Name="BusinessType" DataType="Widestring" Flag="In" >
</Parameter>
<Parameter Name="XMLPrimaryKey" DataType="Widestring" Flag="In" >
</Parameter>
</Parameters>
</Operation>
</Operations>
</Interface>
</Interfaces>
</Service>
</Services>
<Structs>
</Structs>
<Enums>
</Enums>
<Arrays>
</Arrays>
</Library>
