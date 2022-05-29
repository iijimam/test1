Class Test.Speed
{

ClassMethod create()
{
    &sql(CREATE TABLE Test.VegetableMarket
        (YYYY INT, MM INT, DD INT, City VARCHAR(10), 
        Itemname VARCHAR(50), productionsite VARCHAR(50), amount NUMERIC, Price NUMERIC)
    )
    &sql(CREATE INDEX YYYYIdx ON Test.VegetableMarket (YYYY))
    &sql(CREATE INDEX MMIdx ON Test.VegetableMarket (MM))
    &sql(CREATE INDEX DDIdx ON Test.VegetableMarket (DD))
    &sql(CREATE INDEX CityIdx ON Test.VegetableMarket (City))
    &sql(CREATE INDEX ItemnameIdx ON Test.VegetableMarket (Itemname))
    &sql(CREATE INDEX productionsiteIdx ON Test.VegetableMarket (productionsite))
}

ClassMethod LOADDATA()
{
    set starttime=$ZH
    set sql="LOAD DATA FROM FILE 'C:\WorkSpace\test1\VegetableMarket-2.csv' INTO Test.VegetableMarket"
    set stmt=##class(%SQL.Statement).%New()
    set st=stmt.%Prepare(sql)
    set rset=stmt.%Execute()
    set totaltime=$ZH-starttime
    write "LOAD DATA実行時間全体：",totaltime,!
}

ClassMethod SQLUtil()
{
    set starttime=$ZH
    set file="C:\WorkSpace\test1\VegetableMarket-2.csv"
    set classname="Test.VegetableMarket"
    set st=##class(SQL.Utils).CSVImport(file,classname)
    if $$$ISERR(st){
        write $system.SQL.GetErrorText(st),!
    }
    set totaltime=$ZH-starttime
    write "実行時間全体：",totaltime,!
}

ClassMethod SQLUtilProcedures()
{
    set starttime=$ZH
    set file="C:\WorkSpace\test1\VegetableMarket-2.csv"
    set rowtype="YYYY INT, MM INT, DD INT, City VARCHAR(10),"
    set rowtype=rowtype_"Itemname VARCHAR(50), productionsite VARCHAR(50), amount NUMERIC, Price NUMERIC"
    set classname="Test.VegetableMarket2"
    Do ##class(%SQL.Util.Procedures).CSVTOCLASS(,.rowtype,file,,,,classname,"UTF8") 

    set totaltime=$ZH-starttime
    write "実行時間全体：",totaltime,!
}

}
