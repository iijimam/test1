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

        インデックス定義なしの計測
        ```
        USER>do ##class(Test.Speed).LOADDATA()
        LOAD DATA実行時間全体：.856731
        ```

        インデックス付与後の計測（約1.7倍処理時間増える）
        ```
        USER>do ##class(Test.Speed).LOADDATA()
        LOAD DATA実行時間全体：1.484072
        ```
        


    - 2. 次の計測の為テーブルデータ削除

        ```
        truncate table Test.VegetableMarket
        ```

    - 3. SQLのユーティリティ（%SQL.Import.Mgr使用）

        インデックス無しの計測
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

        インデックス付与後の計測（約1.2倍処理時間増える）
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
        実行時間全体：9.461168        
        ```

        ＜メモ＞元のサンプルがファイルインスタンスに%FileCharacterStreamを使っていて、%Stream.FileCharacterに変更したら、8000件程度のデータ量だけど2秒ほど速くなった

    - 4. %SQL.Util.Procedures で計測

        https://jp.community.intersystems.com/node/499691

        このユーティリティを使ってテーブル定義を作るのでインデックスを事前に定義できない

        注意：このクラスの機能を使ってテーブル定義を作っておかないと、中で使用するImport()メソッドがテーブルに提供されない。1度入れたデータを入れ直すには向いているけど、追記できない。（Import()の処理で既存データあった場合消去してる）

        ```
        USER>do ##class(Test.Speed).SQLUtilProcedures()
        実行時間全体：3.540528
        ```
        1度truncateした後もう1度実行（テーブル定義がある状態での実行なのでテーブル作成がない）
        ```
        USER>do ##class(Test.Speed).SQLUtilProcedures()
        実行時間全体：3.304381
        ```
        データがある状態で実行すると既存を削除してるので時間かかる
        ```
        USER>do ##class(Test.Speed).SQLUtilProcedures()
        実行時間全体：4.382148
        ```
