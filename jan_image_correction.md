# jan_image_correctionメモ

必要なモジュール

- ImageMagick6

## 使い方

jan_image_correction.sh ディレクトリ...

ディレクトリには jangetter -g で取得したディレクトリを指定する。

以下のことを行い、`_edit` をつけたディレクトリを作成する。

- イメージが JPEG でない場合には JPEG へ変換する
- イメージのサイズが縦が長い場合、幅と同じサイズの画像に変換する
- data.json, index.html を補正
- index2.htmlを作成(画像のサイズをそのまま表示、画像に枠線を付けて表示)