Include %occStatus

Class SQL.Utils
{

ClassMethod CSVExport(filepath As %String, classname As %String, Delimiter As %String = ",") As %Status [ SqlProc ]
{
	 Set total=0
	 Set mgr = ##class(%SQL.Export.Mgr).%New()
	 Set mobj = ##class(%SQL.Manager.API).%New()
	 Set cl=##class(%Dictionary.CompiledClass).%OpenId(classname)
	 If ('$ISOBJECT(cl)){
  	 	 Write classname_" は存在しません。",!
   		Quit
	 }
	 Set SchemaName = cl.SqlSchemaName
	 Set TableName = cl.SqlTableName
	 Set mgr.FileName = filepath
	 Set mgr.TableName = SchemaName_"."_TableName
	 Set mgr.IQN=$$$BuildIQN(SchemaName,TableName) 
	 Set mgr.ClassName = classname
	 Set mgr.HasHeaders=1
	
	Set mgr.Delimiter = Delimiter
	Set mgr.StringQuote = """"
	// 入力データの日付フォーマットを指定します
	Set mgr.DateFormat = 3   //YYYY-MM-DDの場合は3 YYYYMMDDの場合は8
	Set mgr.TimeFormat = 1 // hh:mm:ss
	// Set mgr.TimeStampFormat = 1 // ODBC format (Import only)
	Set mgr.NoCheck = 1 // disable validation (Import only)
	set mgr.Terminator=$C(10)
	
	set result = ##class(%ResultSet).%New("%SQL.Manager.Catalog:Fields")
	set sc= result.Execute(SchemaName,TableName)
	If $$$ISERR(sc) 
	{
		quit sc
	} 
	
	While result.Next(.sc) 
	{
	  	set colname=result.Data("FIELD_NAME")
	  	set datatype =result.Data("DATATYPE")
	  	Set ok = mobj.CheckIdentifier(.colname)
	  	if ((colname["ID") || (colname ="x__classname")||($E(datatype,1)'="%"))
	  	{}
	  	else
	  	{
		  	w colname_" || "_datatype,!
		  	do mgr.ColumnNames.Insert(""""_colname_"""")
		  	do mgr.ColumnTypes.Insert(..ConvertDataType(datatype))
	  	}

	}
	Set result = mgr.GenerateExportRoutine()
	If result '= 1 Quit result
	Set sta = mgr.OpenExport()
	If $$$ISERR(sta) 
	{
		d $SYSTEM.OBJ.DisplayError(sta)
		quit sta
	} 
	Else 
	{
	  Set sta = mgr.GetExportSize(.size)
	  If size = 0 
	  {
		  quit $$$ERROR("No Data exported")
	  } 
	  Else 
	  {	
	    Set tSC = $$$OK
	    set rs = ##class(%ResultSet).%New()
	    set query ="Select Count(*) As allrows from "_mgr.TableName
	    do rs.Prepare(query)
	    do rs.Execute()
	    do rs.Next()
	    set rows = rs.Data("allrows")
	    
		Set tSC = mgr.ExportRows(rows,.done)

		if $$$ISERR(tSC) quit tSC
	  }
	  Do mgr.CloseExport()
	  Do mgr.DeleteExportRoutine()
	  Quit $$$OK
	  
	}
}

ClassMethod CSVImport(filepath As %String, classname As %String, Delimiter As %String = ",") As %Status [ SqlProc ]
{
		
	k rows,mgr,mobj
	set rows = ##class(SQL.Utils).CountRows(filepath)
 	set total=0
	set mgr = ##class(%SQL.Import.Mgr).%New()
	Set mobj = ##class(%SQL.Manager.API).%New()
	s cl=##class(%Dictionary.CompiledClass).%OpenId(classname)
		if ('$ISOBJECT(cl)){
		w classname_" is not a valid class",!
		quit
	}
	Set SchemaName = cl.SqlSchemaName
	Set TableName = cl.SqlTableName
	
	Set mgr.FileName = filepath	
	
	Set mgr.TableName = cl.SqlSchemaName_"."_cl.SqlTableName
	Set mgr.ClassName =classname
	
	Set mgr.Delimiter = Delimiter
	Set mgr.StringQuote = """"
	Set mgr.DateFormat = 1
	Set mgr.TimeFormat = 1
	// Set mgr.TimeStampFormat = 1
	Set mgr.NoCheck = 1
	Set mgr.HasHeaders = 1 //インポートファイルにヘッダ行がある場合は1
	set mgr.Terminator=$C(10)

	set result = ##class(%ResultSet).%New("%SQL.Manager.Catalog:Fields")
	set sc= result.Execute(SchemaName,TableName)
	If $$$ISERR(sc) 
	{	
		d $SYSTEM.OBJ.DisplayError(sc)
		quit sc
	} 
	
	While result.Next(.sc) 
	{
		set colname=result.Data("FIELD_NAME")
	  	set datatype =result.Data("DATATYPE")
	  	
	  	if ((colname["ID") || (colname ="x__classname")||($E(datatype,1)'="%"))
	  	{
		  
		  	}
	  	else
	  	{
		    w "adding "_colname,!
		  	do mgr.ColumnNames.Insert(""""_colname_"""")
		  	do mgr.ColumnTypes.Insert(..ConvertDataType(datatype))
		  	
	  	}
	}

	//インデックス再構築をインポート後に実行するオプション
	Set mgr.DeferIndices = 1
	//%NOCHECKオプション（一意の値のチェックおよび外部キーの参照整合性チェックをしないオプション）を指定
	set mgr.NoCheck=1
	Quit mgr.Import()
}

ClassMethod CountRows(filepath) As %Integer
{
	set rows=0
	
 	Set stream=##class(%Stream.FileCharacter).%New() 
 	Set stream.Filename=filepath
 	do stream.LineTerminatorSet($C(10))
 	While 'stream.AtEnd 
 	{
 		Set line=stream.Read(1)
 		
		If line[stream.LineTerminator {set rows = $I(rows)}
 	}
 	kill stream
 	//w "found lines: ",rows,!
	quit rows
}

ClassMethod ConvertDataType(datatype As %String) As %String
{
	QUIT:datatype="%Library.Date" "D"
	QUIT:datatype="%Library.Time" "T"
	QUIT:datatype="%Library.TimeStamp" "TS"
	if datatype = "%Library.Integer" || (datatype = "%Library.Boolean") || (datatype = "%Library.Float") || (datatype = "%Library.Numeric") || (datatype = "%Library.SmallInt") || (datatype = "%Library.TinyInt") || (datatype = "%Library.Currency") QUIT "N"
 	QUIT "S"
}

}
