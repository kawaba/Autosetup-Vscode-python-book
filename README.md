---
title: "スクリプトだけで完全ポータブルな VSCode＋Python＋Copilot を自動生成する"
emoji: "🐍"
type: "tech"
topics: ["python", "VScode", "portable", "CoPilot", "Script"]
published: true
---
## インストールなしで使えるPython環境
　Pythonを学ぶためには、**Pythonインタープリタ**はもちろんですが、IDEも必要です。最近は、（IDEではありませんが）**VScode**がよく使われています。また、学習の初期段階で、小さなコードを試すには、**Jupyter Notebook**がとても便利です。
 
　そして、AIも使えないと困りますね。定番は**GitHub Copilot**です。学生さんなら、（申請さえすれば）無料でProバージョンが使えます。例えば、GPT-5.1-codexのような最新版を自由に使えるようになります。

　そこで、これらをまとめてセットアップするスクリプトを作成しました。完全にポータブルな環境が5～10分程度で生成されます。ポータブルですから、インストールなしで、スクリプトの実行が終わったらそのまま実行できます。**仮想環境も必要ありません**。スクリプトで必要なだけ環境を作れるからです。いくつ環境を作っても、互いに影響しません。

　★書籍「わかりやすいPython」の読者用に、Copilotにコード生成のガイドラインを設定する.github/copilot-instruction.mdファイルを追加しています。

## セットアップ作業
セットアップは、setup.batをダブルクリックで実行するだけです。それだけで完了します。

### GitHubからダウンロード
スクリプト等はGitHubにあります。次からダウンロードまたはgitで入手してください

- [GitHubを開く](https://github.com/kawaba/Autosetup-Vscode-python)
- [zip形式でダウンロードする](https://github.com/kawaba/Autosetup-Vscode-python/archive/refs/heads/main.zip)
### ファイル構成
　スクリプトは次のような構成です。

```
./portable-python-vscode
  ├─config
  │   ├─cleanExtensions.txt     VScode拡張機能のリスト
  │   └─settings.json			ダミー用
  ├─workspace
  │   ├─.vscode
  │   │     ├─locale.json		日本語モードの指定
  │   │     └─settings.json		VScodeの設定
  │   └─sample
  │          ├─sample.ipynb		サンプルのJupyter Notebookファイル
  │          └─sample.py		サンプルのPythonソースコード
  ├─launch-vscode.bat			VScode起動用バッチファイル
  ├─README.md						
  ├─setup.bat					セットアップ実行用バッチファイル
  └─setup.ps1					セットアップスクリプト（本体）
``` 
　どこか適切な場所（**ローカルドライブ推奨**）に置いて、**setup.bat**をダブルクリックして実行します。ネットワークの速度にもよりますが、5～10分程度で完了します。
 完了後のファイル構成は次のようになります。

``` 
./portable-python-vscode
  ├─python
  ├─vscode
  ├─workspace
  │   ├─.vscode
  │   │     ├─locale.json		日本語モードの指定
  │   │     └─settings.json		VScodeの設定
  │   └─sample
  │          ├─sample.ipynb		サンプルのJupyter Notebookファイル
  │          └─sample.py		サンプルのPythonソースコード
  ├─launch-vscode.bat			VScode起動用バッチファイル
  └─README.md						
```   

必ず**launch-vscode.bat**を使って起動してください。
起動時に、.vscode/settings.json等を読み取って反映します。

## セットアップされる内容
　VScodeと重要な拡張機能、そして、Pythonインタプリターと主要なライブラリをセットアップします。Pythonライブラリは多くの分野を網羅しています。下記のライブラリのリストを見てください。
 　VScodeの拡張機能はミニマムなセットです。開発する分野に応じて、VScodeのメニューから必要な拡張機能を追加してください。
 　
### PythonとVScode
- Python 3.13.0 (Embeddable版)
- Visual Studio Code (Portable版)
　
### インストールされるVS Code拡張機能一覧

#### Python開発

| 拡張機能名 | 説明 |
|---|---|
| Python | Python言語サポート |
| Pylance | Python言語サーバー（高速・高機能） |
| Python Debugger | Pythonデバッガー |
| Python Environments Manager | Python環境管理ツール |

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
| kbinput | キーボード入力ライブラリ(カスタム) |
| tkxlib | 学習用のツール(カスタム) |

## 使い方
① **launch-vscode.bat**をダブルクリックして起動します。ここで、拡張機能がロードされるタイミングが遅れて、英語モードの表示になる場合があります。

 ![10.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/60058/63868bfb-79c2-4f6f-9ef6-20364e91e354.png)

② 英語モードで表示された場合は、一度終了し、もう一度起動し直すと日本語モードで起動します。
 
![00.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/60058/9b85f111-0dab-48a3-8c78-408b8c89b5e4.png)

③ まず、VScodeにPythonインタープリタを認識させる必要があります。
 - sampleフォルダの中の**sample.py**を開きます
 - すると、右下にPythonを選択するウィンドウが開くので、［Python インタープリタの選択］のボタンをクリックします
 　
![12.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/60058/490b5aec-37dd-4a07-b051-67f80224ae6e.png)
 
④選択ウィンドウが開くので、［python.defaultInterpreterPath 設定でPythonを使用する･･･］ をクリックします
　
![13.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/60058/307f828f-46fe-450e-a085-eac6a482f95c.png)

　 
④もう一度、Pythonのパスを設定するウィンドウが開きますが、×をクリックして閉じます

![14.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/60058/7eda055f-203d-464a-8f2a-75a4c9bc9210.png)
　
　
以上でPythonを認識したので、これ以降は自由にコードを書いて実行できます。
なお、sample.ipynbファイルは、Jupyter Notebookのファイルです。開いて確認してください。

![image6.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/60058/a803d695-213b-4d49-b29b-7f33e59d5ba0.png)

 　
⑤Copilot　
　Copilot（AIエージェント)を使うには、事前にGithubのアカウントを取得しておく必要があります。また、ログイン認証は2段階認証にしておかなくてはいけません。
　その上で、初回だけ、GitHubにログインしてアカウントを接続する作業が必要です。上の画面は、まだ接続していな状態です。右下隅の［Signed out］と書かれているCopilotアイコンをクリックし、画面の指示に従って接続してください。

## いろいろなカスタマイズ
### 画面のテーマの変更
　画面のテーマ色は**Light＋**です。デフォルトの**Dark＋**にするには次のようにします。
1. VS Code の 左の下端にある歯車（⚙）アイコンをクリック
2. 「テーマの選択（Color Theme）」 をクリック
3. テーマ一覧が表示される
4. 「Default Dark+」 を選ぶ

### スクリプトのカスタマイズ
　スクリプトのカスタマイズは比較的簡単です。違うバージョンのPythonをインストールしたりできます。VScodeの拡張機能やpythonのライブラリも追加や削除できます。

#### 異なるバージョンのPythonに変更する
　例えば、3.14.0に変える時は、setup.ps1ファイルの次の部分を変更します。青い背景部分を3.14.0、または314に変更するといいでしょう。https://www.python.org/ftp/python をウェブでのぞいてみると、いろいろなバージョンの詳細がわかります。
 
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
ms-toolsai.jupyter
ms-toolsai.jupyter-keymap
ms-toolsai.jupyter-renderers
ms-toolsai.vscode-jupyter-cell-tags
ms-toolsai.vscode-jupyter-slideshow
ms-vscode.remote-repositories
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
#### 2025-12-27
tcl/tkはポータブル版のPythonからは削除されていて使えないようになっています。
そこで、非ポータブル版のpythonからtcl/tkの関連コードをコピーすることにより使えるようにしました。
　


