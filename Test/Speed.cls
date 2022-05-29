Class Test.Speed
{

ClassMethod create()
{
    &sql(CREATE TABLE Test.VegetableMarket
        (YYYY INT, MM INT, DD INT, City VARCHAR(10), 
        Itemname VARCHAR(50), productionsite VARCHAR(50), amount NUMERIC, Price NUMERIC)
    )
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

}
