# Simple Widgets for Übersicht

Macのデスクトップカスタマイズツールである[Übersicht](https://github.com/felixhageloh/uebersicht)向けの、シンプルで美しいウィジェット集です。

## 含まれるウィジェット

* **Clock**: 日付付きのシンプルなデジタル時計です。
* **System2**: OSのバージョン、Macのモデル、CPU、メモリ(RAM)、ディスク使用量、IPアドレス、バッテリー残量などのシステム情報を表示します。
* **Memory2**: メモリを多く消費しているプロセスの上位をリアルタイムで表示します。
* **Weather**: 現在地の正確な位置に基づく現在の天気と、明日の天気予報を表示します。

## インストール方法

### 1. Übersichtのインストール
もしまだインストールされていない場合は、[Übersicht](http://tracesof.net/uebersicht/)をダウンロードしてインストールしてください。

### 2. ウィジェットの追加
このリポジトリをダウンロード（またはクローン）することで、あなたのÜbersichtにウィジェットを追加できます。

1. このリポジトリをZipでダウンロードするか、`git clone` します。
2. Übersichtを起動し、メニューバーのアイコン（Uのマーク）から **"Open Widgets Folder"** を選択します。
3. ダウンロードした **`Simple_widgets` フォルダをそのまま**、Übersichtのwidgetsフォルダ（デフォルトでは `~/Library/Application Support/Übersicht/widgets`）の中へ移動してください。

### 3. 天気ウィジェットのセットアップ
天気ウィジェット(`weather-widget`)を機能させるには、外部のコマンドラインツールと無料のAPIキーが必要です。

#### 必要なコマンドラインツール
 ターミナルを開き、[Homebrew](https://brew.sh/) を使って必要なツールをインストールします：
```bash
brew install corelocationcli
brew install jq
```

#### APIキーの取得と設定
1. [OpenWeatherMap](https://openweathermap.org/api) で無料のAPIキーを取得（Sign up）します。
2. テキストエディタで `Simple_widgets/weather-widget/get-weather.sh` を開きます。
3. 4行目付近にある `API_KEY` の値を、ご自身のAPIキーに書き換えて保存してください。
   ```bash
   API_KEY="ここにご自身のAPIキーを貼り付けます"
   ```

#### トラブルシューティング
天気ウィジェットで「Location not found」やエラーが出る場合、macOSの再起動後に位置情報サービスが一時的に不安定になっている可能性があります。
- **位置情報サービスの入れ直し**: `システム設定 > プライバシーとセキュリティ > 位置情報サービス` を一度 **オフ** にしてから、再度 **オン** にしてください。
- **Wi-Fiをオンにする**: 有線LANを使用している場合でも、位置情報の特定にはWi-Fiがオンである必要があります。
*※ 本ウィジェットには、正確な位置情報が取得できない場合にIPアドレスから現在地を自動推定するフォールバック機能が備わっています。*

## カスタマイズについて
これらのウィジェットの見た目は、拡張子が `.coffee` や `.jsx` のファイルを編集することで簡単にカスタマイズできます。フォントや色などのスタイル設定は、ファイル内の `style:` 項目に標準的なCSS（またはStylus）記法で書かれています。
