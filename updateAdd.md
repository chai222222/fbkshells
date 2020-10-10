#

企業様から頂いた JAN を元に zaico へ登録するための手順

## 前提

[kintone](https://fs2002.cybozu.com/k/34/show#record=4&l.view=5118079&l.q=f5118048%2520in%2520%28LOGINUSER%28%29%29&l.sort_0=f5118042&l.order_0=DESC&l.next=0&l.prev=5)

への返信で書いたけども、fdkcacheedit は、出発が現状の zaico の情報を自動で編集したい、また csv で編集したい、ということからキャッシュを編集するためのところになっているので追加できない。
どちらかというと jangetter と同じように新規 jan データを追加する操作は jangetter のデータを作成すれば良いので、jangetter の json を作成することとする。

## 使い方

fbkshellsで `git clone` して最新状態にする。

```sh
fbkcsv2json.sh < 商品マスタUTF8_フィルタ済み_名前変換済み.CSV > data.json
```

これにより `商品マスタUTF8_フィルタ済み_名前変換済み.CSV` 内の csv を元に jangetter の json 出力と同じ結果を得ることができる。
このあとに

```sh
zaicoregister  -c -m updateAdd data.json
```

とすることにより、更新・追加ができる。

```sh
zaicoregister --dryrun -c -m updateAdd data.json
```

で実際に登録しないで何が更新・登録できるかが確認できる。
