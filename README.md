# LOAD DATAとSQLのユーティリティで計測

## 確認手順

- 1)　テーブル作成

    以下実行

    ```
    do ##class(Test.Speed).create()
    ```

- 2) LOAD DATAのための前準備

    Language GatewayのJavaを使っているので、以下管理ポータルで事前に開始しておく
    （開始してなかったら勝手に起動するけど初期起動に少し時間かかるので開始しておくとよい）

    [システム管理] > [構成] > [接続性] > [External Language Servers]


- 3) 計測開始！

    - 1. LOAD DATA

        例
        ```
        USER>do ##class(Test.Speed).LOADDATA()
        LOAD DATA実行時間全体：.856731
        ```

    - 2. 次の計測の為テーブルデータ削除

        ```
        truncate table Test.VegetableMarket
        ```

    - 3. SQLのユーティリティ（%SQL.Import.Mgr使用）

        例
        ```
        USER>do ##class(Test.Speed).SQLUtil()
        adding YYYY
        adding MM
        adding DD
        adding City
        adding Itemname
        adding productionsite
        adding amount
        adding Price
        
        Importing data................................................................................
        Building indices...
        Import complete: 80655 rows inserted into Test.VegetableMarket
        実行時間全体：7.662481
        ```

        ＜メモ＞元のサンプルがファイルインスタンスに%FileCharacterStreamを使っていて、%Stream.FileCharacterに変更したら、8000件程度のデータ量だけど2秒ほど速くなった
