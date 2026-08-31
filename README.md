# スクリプトで完全ポータブルな VSCode＋Python＋Copilot を自動生成する

書籍『わかりやすいPython』の読者向けセットアップスクリプトです。
※書籍と関係なく利用する場合は、インストール後にworkspace/.github フォルダを削除してください。

**2026-07版** ｜ 最新版は https://github.com/kawaba/Autosetup-Vscode-python-book で確認してください。
ライセンスは [LICENSE.md](LICENSE.md) をご覧ください。

## セットアップの手順
### 1. インストールなしで使えるPython環境
　Pythonを学ぶためには、**Pythonインタープリタ**はもちろんですが、IDEも必要です。最近は、（IDEではありませんが）**VS Code**がよく使われています。また、学習の初期段階で、小さなコードを試すには、**Jupyter Notebook**がとても便利です。そして、AIも使えないと困りますね。定番は**GitHub Copilot**です。
　そこで、これらをまとめてセットアップするスクリプトを作成しました。完全にポータブルな環境が10～15分程度で生成されます。ポータブルですから、インストールなしで、スクリプトの実行が終わったらそのまま実行できます。**仮想環境も必要ありません**。スクリプトで必要なだけ環境を作れるからです。いくつ環境を作っても、互いに影響しません。

### 2. GitHubからダウンロードしてスクリプトを起動する
スクリプト等はGitHubにあります。次からダウンロードまたはgitで入手してください

- [GitHubを開く](https://github.com/kawaba/autosetup-vscode-python-book)
- [zip形式でダウンロードする](https://github.com/kawaba/autosetup-vscode-python-book/archive/refs/heads/main.zip)

　どこか適切な場所（**ローカルドライブ推奨**）に置いて、**setup.bat**をダブルクリックして実行します。ネットワークの速度にもよりますが、10～15分程度で完了します。具体的には次のようにします。

1) 任意のフォルダにダウンロードします。
2) ダウンロードしたファイルを展開します。
3) 展開したファイルを開き、portable-python-vscodeというフォルダを<br>
   Python環境を置きたいドライブの直下にコピーします。
4) コピー先のportable-python-vscodeを開いて、setup.batファイルを<br>
   ダブルクリックします。<br>インストールがはじまり10～15分後に自動的に完了します。

　実行するスクリプトのファイル構成は次のようです。

```
./portable-python-vscode
  ├─config
  │    ├─xtensions.txt 　　VScode拡張機能のリスト
  │    └─settings.json	　ダミー用
  ├─workspace
  │    ├─.github 　Copolot がコードを生成する時に参照するガイドラインのファイルがある
  │    ├─.vscode
  │    │      ├─locale.json	　　　日本語モードの指定
  │    │      ├─settings.json		VS Code の設定
  │    │      ├─extensions.json 　推奨する拡張機能（ただし、未使用）
  │    │      └─launch.json 　　　デバック実行の設定
  │    └─sample
  │          ├─sample.ipynb　サンプルのJupyter Notebookファイル
  │          └─sample.py	　　サンプルのPythonソースコード
  ├─launch-vscode.bat	　VScode起動用バッチファイル
  ├─setup.bat	　　セットアップ実行用バッチファイル
  └─setup.ps1	　　セットアップスクリプト（本体）
``` 

### 3. セットアップ後のディレクトリとファイルの構成 
完了後のディレクトリとファイル構成は次のようになります。
セットアップ用のファイルは削除されてなくなります。
起動用のバッチファイルhは**launch-vscode.bat**です。

``` 
./portable-python-vscode
  ├─python
  ├─vscode
  ├─workspace
  │    ├─.github Copolot がコードを生成する時に参照するガイドラインのファイルがある
  │    └─sample
  │          ├─sample.ipynb　サンプルのJupyter Notebookファイル
  │          └─sample.py	　　サンプルのPythonソースコード
  └─ launch-vscode.bat			VScode起動用バッチファイル
```   
（注）.vscodeフォルダはworkspace内に残っていますが、VS Code上では表示されないので、上図では表記を省略しています。


### 4. 起動用アイコンの作成
launch-vscode.batは、起動時に、.vscode/settings.json等を読み取って反映します。
必ず**launch-vscode.bat**を使って起動してください。

バッチファイルから起動するのが面倒な場合は、次の手順で起動用アイコンを作るといいでしょう。

1. エクスプローラーで、launch-vscode.batを右ボタンでクリックします。
2. ［その他のオブションを確認］⇒［ショートカットの作成］を選びます。
3. 作成されたショートカットを右ボタンでクリックし［プロパティ］をクリックします。
4. プロパティダイアログが開くので、下の方にある［アイコンの変更］ボタンを押します。
5. アイコンの変更ダイアログが開くので［参照］ボタンを押します。
6. portable-python-vscodeフォルダのvscodeフォルダの中にある［Code.exe］をクリックして［開く］ボタンを押します。
7. ［OK］ボタンを押してプロパティダイアログに戻ります
8. ［OK］ボタンを押します
9. エクスプロラーに戻ります。
10. ショートカットアイコンがVS Codeアイコンに変わっています。
11. ショートカットアイコンをデスクトップにドラッグして離します。

## 使い方
### (1) **launch-vscode.bat**か起動用アイコンをダブルクリックして起動します。
最初の起動では、GitHub Copilotにサインインする画面が表示されますが、後で行うことにして、右上の×印をクリックして閉じます。

![右上の×印をクリック](img/sign-in.png)

<br>ここで、拡張機能がロードされるタイミングが遅れて、英語モードの表示になる場合があります。

<img src="https://k-webs.jp/python/images/english-mode.png" width="900">

<br>英語モードで表示された場合は、一度終了し、もう一度起動し直すと日本語モードで起動します。

 <img src="https://k-webs.jp/python/images/japanese-mode.png" width="900">

### (2) VScodeにPythonインタープリタを認識させます。
①sampleフォルダの中の**sample.py**を開きます
<br>②すると、右下にPythonを選択するウィンドウが開くので、［Python インタープリタの選択］のボタンをクリックします<br>
 　
<img src="https://k-webs.jp/python/images/select-interpreter.png" width="900">
 
<br>ダイアログが開くので［インタープリターパスを入力］をクリックします。

<img src="https://k-webs.jp/python/images/enter-path.png" width="900">

<br>入力欄の下の［検索］をクリックしてpython.exeを探します。

<img src="https://k-webs.jp/python/images/find-path.png" width="900">

<br>表示されるファイルダイアログで、portable-python-vscode/python/にあるpython.exeを選択して、
<br>［インタープリターの選択］ボタンを押します。

<img src="https://k-webs.jp/python/images/select-python.png" width="600">

<br>VS Codeに戻るので、［Pythonインタープリターの選択］ダイアログを閉じます。
<br>下端の青いバーに［Python 3.13.13］のようにPythonインタプリターの表示があることを確認してください。

<img src="https://k-webs.jp/python/images/close-dialog.png" width="900">

<br>以上でPythonが使えるようになったので、これ以降は自由にコードを書いて実行できます。
<br>なお、sample.ipynbファイルは、Jupyter Notebookのファイルです。開いて確認してください。

<img src="https://k-webs.jp/python/images/jupyter.png" width="900">
![Jupyter Notebook](img/jupyter.png.png)

### (3) GitHub Copilotを使えるようにする

次は、AIエージェントを使えるようにしましょう。
<br>**GitHub設定ガイド**を見て、GitHubのアカウントを作成し、Copilotを使えるようにしてください。

![GitHub設定ガイド](img/github-guide.png)

<br>
<br>


## セットアップされる内容
　VScodeと重要な拡張機能、そして、Pythonインタプリターと主要なライブラリをセットアップします。Pythonライブラリは多くの分野を網羅しています。下記のライブラリのリストを見てください。
 　VScodeの拡張機能はミニマムなセットです。開発する分野に応じて、VScodeのメニューから必要な拡張機能を追加してください。
 　
### PythonとVScode
- Python 3.13.13 (Embeddable版)
- Visual Studio Code (Portable版)
　
### インストールされるVS Code拡張機能一覧

#### Python開発

| 拡張機能名 | 説明 |
|---|---|
| Python | Python言語サポート |
| Pylance | Python言語サーバー（高速・高機能） |
| Python Debugger | Pythonデバッガー |
| Python Environments Manager | Python環境管理ツール |
| Black Formatter | Blackによるコード自動整形 |

#### AI支援

| 拡張機能名 | 説明 |
|---|---|
| GitHub Copilot | AIコード補完 |
| GitHub Copilot Chat | AIチャット機能 |

#### Jupyter

| 拡張機能名 | 説明 |
|---|---|
| Jupyter | Jupyter Notebook サポート |
| Jupyter Keymap | Jupyterキーバインド |
| Jupyter Cell Tags | セルタグ管理 |
| Jupyter Slide Show | スライドショー機能 |

#### Markdown

| 拡張機能名 | 説明 |
|---|---|
| Markdown All in One | Markdown編集支援（プレビュー・ショートカット等） |
| Markdown Table Editor | Markdownテーブルの視覚的編集 |

#### その他

| 拡張機能名 | 説明 |
|---|---|
| Prettier | コード整形ツール |
| Japanese Language Pack | 日本語言語パック |


### インストールされるPythonライブラリ一覧

#### 1. 開発基盤ツール

| ライブラリ名 | 説明 |
|---|---|
| pip | 最新版 |
| wheel | パッケージビルドツール |
| build | パッケージビルドフロントエンド |

#### 2. コード品質・開発支援

| ライブラリ名 | 説明 |
|---|---|
| black | コード整形ツール |
| pylint | 静的解析ツール |
| flake8 | コード品質チェック |
| autopep8 | PEP8準拠の自動整形 |
| isort | import文の自動整理 |
| mypy | 型チェックツール |

#### 3. ユーティリティ

| ライブラリ名 | 説明 |
|---|---|
| requests | HTTP通信ライブラリ |
| python-dotenv | 環境変数管理 |
| tqdm | プログレスバー表示 |
| colorama | ターミナルの色付け |

#### 4. 数値計算・データ分析・可視化

| ライブラリ名 | 説明 |
|---|---|
| numpy | 数値計算の基盤 |
| pandas | データ分析 |
| matplotlib | グラフ描画 |
| scipy | 科学技術計算 |
| seaborn | 統計データ可視化 |

#### 5. Web開発

| ライブラリ名 | 説明 |
|---|---|
| flask | Webフレームワーク(軽量) |
| requests | HTTP通信・API連携|
| fastapi | モダンなAPIフレームワーク |
| uvicorn | ASGIサーバー(FastAPI用) |
| beautifulsoup4 | HTMLパーサー(スクレイピング) |
| lxml | XML/HTMLパーサー |

#### 6. ファイル処理

| ライブラリ名 | 説明 |
|---|---|
| openpyxl | Excel読み書き |
| pillow | 画像処理 |
| pyyaml | YAML読み書き |
| xlsxwriter | Excel高度な出力 |
| plotly | インタラクティブなグラフ |

#### 7. テスト・モックデータ

| ライブラリ名 | 説明 |
|---|---|
| pytest | テストフレームワーク |
| faker | ダミーデータ生成 |

#### 8. Jupyter環境

| ライブラリ名 | 説明 |
|---|---|
| notebook | Jupyter Notebook |
| jupyterlab | JupyterLab |
| ipykernel | IPythonカーネル |
| ipywidgets | インタラクティブウィジェット |
| jupyterlab-lsp | Jupyter用LSP |
| python-lsp-server | Pythonの言語サーバー |

#### 9. Webアプリケーション

| ライブラリ名 | 説明 |
|---|---|
| streamlit | データアプリ開発フレームワーク |

#### 10. デバッグ

| ライブラリ名 | 説明 |
|---|---|
| debugpy | Python デバッガー(VS Code用) |

#### 11. ゲーム開発

| ライブラリ名 | 説明 |
|---|---|
| pygame | 2Dゲーム開発 |
| arcade | 初心者向けゲームライブラリ |
| pyglet | OpenGLベースのゲーム開発 |

#### 12. 機械学習・統計

| ライブラリ名 | 説明 |
|---|---|
| scikit-learn | 機械学習ライブラリ |
| statsmodels | 統計モデリング |

#### 13. データベース

| ライブラリ名 | 説明 |
|---|---|
| sqlalchemy | ORM(データベース抽象化) |
| psycopg2-binary | PostgreSQL接続ドライバ |

#### 14. API開発強化

| ライブラリ名 | 説明 |
|---|---|
| pydantic | データバリデーション |
| httpx | 非同期HTTPクライアント |

#### 15. 日本語処理

| ライブラリ名 | 説明 |
|---|---|
| janome | 日本語形態素解析 |

#### 16. ターミナル出力

| ライブラリ名 | 説明 |
|---|---|
| rich | リッチなターミナル出力 |

#### 17. カスタムライブラリ

| ライブラリ名 | 説明 |
|---|---|
| tkxlib | 学習用のツール(カスタム) |

## いろいろなカスタマイズ
### 画面のテーマの変更
　画面のテーマ色は**Light＋**です。デフォルトの**Dark＋**にするには次のようにします。
1. VS Code の 左の下端にある歯車（⚙）アイコンをクリック
2. 「テーマの選択（Color Theme）」 をクリック
3. テーマ一覧が表示される
4. 「Default Dark+」 を選ぶ

### スクリプトのカスタマイズ
　スクリプトのカスタマイズは比較的簡単です。違うバージョンのPythonをインストールしたりできます。VScodeの拡張機能やpythonのライブラリも追加や削除できます。
 自分で変更する時は、claude codeなどのAIに指示・相談して変更させるといいでしょう。手動での変更は間違いの元です。

#### 異なるバージョンのPythonに変更する
　例えば、3.14.0に変える時は、setup.ps1ファイルのバージョン番号に関係する部分を変更します。青い背景部分を3.14.0、または314に変更するといいでしょう。https://www.python.org/ftp/python をウェブでのぞいてみると、いろいろなバージョンの詳細がわかります。
 
　ただ、Pythonのバージョンが新しすぎると、VScodeやその拡張機能が対応していないこともあるので、新しければいいというものではありません。慎重に決定してください。
 　

![16.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/60058/621192a8-a0e0-454d-b8b0-9fbb42907994.png)


 #### VScodeの拡張機能
　VScode本体は毎月バージョンアップされるので、スクリプトでは最新安定版をダウンロードする設定にしています。変更するのは拡張機能です。config/cleanExtensions.txtに、セットアップする拡張機能のリストがあります。内容は次の通りです。

config/cleanExtensions.txt
```
esbenp.prettier-vscode
github.codespaces
github.copilot
github.copilot-chat
github.remotehub
github.vscode-github-actions
ms-ceintl.vscode-language-pack-ja
ms-python.debugpy
ms-python.python
ms-python.vscode-pylance
ms-python.vscode-python-envs
ms-python.black-formatter
ms-toolsai.jupyter
ms-toolsai.jupyter-keymap
ms-toolsai.jupyter-renderers
ms-toolsai.vscode-jupyter-cell-tags
ms-toolsai.vscode-jupyter-slideshow
ms-vscode.remote-repositories
yzhang.markdown-all-in-one
octop162.markdown-table-editor
``` 

この内容を変更すればセットアップする拡張機能を変更できます。
拡張機能の名前は、一度手動でセットアップした後、vscodeフォルダのある場所で、次のコマンドを実行するとわかります。

```
.\vscode\bin\code.cmd --list-extensions
```

これで名前を調べて、cleanExtention.txtに追加するなどしてください。

## Pythonライブラリの編集
 
 スクリプトの85行目以降に、インストールする項目が並んでいます。
 
 ``` 
# pipのアップグレード
Write-Host "  pip をアップグレード中..."
& ".\python\python.exe" -m pip install --upgrade pip

# wheelのインストール
Write-Host "  wheel をインストール中..."
& ".\python\python.exe" -m pip install wheel

# コード整形・静的解析ツール
Write-Host "  [1/17] コード整形・解析ツールをインストール中..."
& ".\python\python.exe" -m pip install black pylint flake8 autopep8 isort mypy

# ユーティリティ系
Write-Host "  [2/17] ユーティリティをインストール中..."
& ".\python\python.exe" -m pip install requests python-dotenv tqdm colorama

--- 以下省略 ---
 ``` 
 
 この例にならって、追加したいライブラリを記述してください。
 
 　インストール後の追加などは、VSCodeで、［表示］メニューから［ターミナル］を開くと、pipコマンドでライブラリの追加や削除ができます。
  ただし、**python -m pip ～**のように、python経由で実行してください。pipは、環境を生成した時のPythonのパスを記憶しているので、環境を移動している場合は、pip単体で起動すると動作しないからです。
  
  次はpip listを実行してみた例です。
 
![15.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/60058/c924eb18-f0ab-46d9-b89b-4ee79fd4864c.png)  

### 追記:

#### 2026-05-20
READMEを更新しました。同時に、GitHubセットアップガイドを追加しました。

#### 2026-04-18
Pythonのバージョンを3.13に変更しました。
また、拡張機能にMarkdown関連を追加しました。

#### 2025-12-27
tcl/tkはポータブル版のPythonからは削除されていて使えないようになっています。
そこで、非ポータブル版のpythonからtcl/tkの関連コードをコピーすることにより使えるようにしました。
　


