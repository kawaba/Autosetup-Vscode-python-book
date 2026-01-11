# ============================================================
# Portable Python + VS Code セットアップスクリプト
# ============================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'  # 高速化

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Portable Python + VS Code 環境セットアップ開始" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 1. ポータブルPythonのダウンロード・展開
# ============================================================

Write-Host "[1/5] ポータブルPythonをダウンロード中..." -ForegroundColor Green

# Python 3.12.9 Embeddable版（64bit）
$pythonUrl = "https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.zip"
$pythonZip = "python.zip"
$pythonDir = ".\python"

if (Test-Path $pythonDir) {
    Write-Host "  ○ Pythonは既に存在します。スキップします。" -ForegroundColor Yellow
} else {
    Write-Host "  ダウンロード中: $pythonUrl"
    Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonZip
    
    Write-Host "  展開中..."
    Expand-Archive -Path $pythonZip -DestinationPath $pythonDir -Force
    Remove-Item $pythonZip
    
    Write-Host "  Pythonのダウンロード・展開完了" -ForegroundColor Green
}

# ============================================================
# python312._pth の修正（pip有効化のため）
# ============================================================

Write-Host "  python312._pth を修正中..."
$pthFile = Join-Path $pythonDir "python312._pth"

if (Test-Path $pthFile) {
    $content = Get-Content $pthFile
    $newContent = $content -replace '^#import site', 'import site'
    $newContent | Set-Content $pthFile -Encoding ASCII
    Write-Host "  python312._pth の修正完了" -ForegroundColor Green
}

Write-Host ""

# ============================================================
# 1.5 Tcl/Tk セットアップ（tkinter有効化・確実版）
# ============================================================

Write-Host "[1.5/5] Tcl/Tk をセットアップ中..." -ForegroundColor Green

$tkLog = Join-Path $PSScriptRoot "tk_error.log"

function Write-TkLog {
    param([string]$msg)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time $msg" | Out-File -FilePath $tkLog -Append -Encoding UTF8
}

try {
    $fullZip = ".\python-full.zip"
    $fullDir = ".\python-full"

    if (!(Test-Path $fullDir)) {
        Write-Host "  フル版Python(ZIP)をダウンロード中..." -ForegroundColor Gray
        $url = "https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.zip"
        Invoke-WebRequest -Uri $url -OutFile $fullZip

        Write-Host "  展開中..." -ForegroundColor Gray
        Expand-Archive -Path $fullZip -DestinationPath $fullDir -Force
    }

    $srcTcl  = Join-Path $fullDir "tcl"
    $srcDlls = Join-Path $fullDir "DLLs"
    $dstDlls = Join-Path $pythonDir "DLLs"

    if (!(Test-Path $srcTcl)) {
        throw "tcl ディレクトリが見つかりません: $srcTcl"
    }

    Copy-Item $srcTcl $pythonDir -Recurse -Force
    Write-TkLog "tcl コピー成功"

    Copy-Item "$srcDlls\_tkinter.pyd" $dstDlls -Force
    Write-TkLog "_tkinter.pyd コピー成功"

    Copy-Item "$srcDlls\tcl86t.dll" $pythonDir -Force
    Copy-Item "$srcDlls\tk86t.dll"  $pythonDir -Force
    Write-TkLog "tcl/tk DLL コピー成功"

    Write-Host "  Tcl/Tk セットアップ完了" -ForegroundColor Green
}
catch {
    Write-Host "  Tcl/Tk セットアップ失敗" -ForegroundColor Red
    Write-Host "  詳細は tk_error.log を確認してください" -ForegroundColor Yellow
    Write-TkLog "エラー: $($_.Exception.Message)"
}

Write-Host ""


# ============================================================
# 2. pipコマンドのインストール
# ============================================================

Write-Host "[2/5] pipをインストール中..." -ForegroundColor Green

$getPipUrl = "https://bootstrap.pypa.io/get-pip.py"
$getPipFile = "get-pip.py"

Write-Host "  get-pip.py をダウンロード中..."
Invoke-WebRequest -Uri $getPipUrl -OutFile $getPipFile

Write-Host "  pip をインストール中..."
& ".\python\python.exe" $getPipFile

Write-Host "  pipのバージョン確認:"
& ".\python\python.exe" -m pip --version

Write-Host "  pipのインストール完了" -ForegroundColor Green
Write-Host ""

# ============================================================
# 3. Pythonライブラリのインストール
# ============================================================

Write-Host "[3/5] Pythonライブラリをインストール中..." -ForegroundColor Green
$env:PATH = "$PWD\python;$PWD\python\Scripts;$env:PATH"

& ".\python\python.exe" -m pip install --upgrade pip
& ".\python\python.exe" -m pip install wheel
& ".\python\python.exe" -m pip install build
& ".\python\python.exe" -m pip install black pylint flake8 autopep8 isort mypy
& ".\python\python.exe" -m pip install requests python-dotenv tqdm colorama
& ".\python\python.exe" -m pip install --only-binary :all: numpy pandas matplotlib scipy seaborn
& ".\python\python.exe" -m pip install flask fastapi uvicorn beautifulsoup4 lxml
& ".\python\python.exe" -m pip install openpyxl pillow pyyaml pytest faker
& ".\python\python.exe" -m pip install notebook jupyterlab ipykernel ipywidgets
& ".\python\python.exe" -m pip install jupyterlab-lsp python-lsp-server
& ".\python\python.exe" -m pip install plotly xlsxwriter
& ".\python\python.exe" -m pip install streamlit debugpy pygame arcade pyglet
& ".\python\python.exe" -m pip install scikit-learn statsmodels sqlalchemy psycopg2-binary
& ".\python\python.exe" -m pip install pydantic httpx janome rich
& ".\python\python.exe" -m pip install https://k-webs.jp/lib/python/tkxlib-1.1.1-py3-none-any.whl

Write-Host ""

# ============================================================
# 4. Pythonライブラリのインストール
# ============================================================

Write-Host "[3/5] Pythonライブラリをインストール中..." -ForegroundColor Green
Write-Host "  （この処理には5~10分かかる場合があります）" -ForegroundColor Yellow
Write-Host ""

# PATHの設定
$env:PATH = "$PWD\python;$PWD\python\Scripts;$env:PATH"

# pipのアップグレード
Write-Host "  pip をアップグレード中..."
& ".\python\python.exe" -m pip install --upgrade pip

# wheelのインストール
Write-Host "  wheel をインストール中..."
& ".\python\python.exe" -m pip install wheel

# コード整形・静的解析ツール
Write-Host "  [1/18] コード整形・解析ツールをインストール中..."
& ".\python\python.exe" -m pip install black pylint flake8 autopep8 isort mypy

# ユーティリティ系
Write-Host "  [2/18] ユーティリティをインストール中..."
& ".\python\python.exe" -m pip install requests python-dotenv tqdm colorama

# 数値・統計・可視化
Write-Host "  [3/18] 数値計算・可視化ライブラリをインストール中..."
& ".\python\python.exe" -m pip install --only-binary :all: numpy pandas matplotlib scipy seaborn

# Web開発
Write-Host "  [4/18] Web開発ライブラリをインストール中..."
& ".\python\python.exe" -m pip install flask requests fastapi uvicorn beautifulsoup4 lxml

# Excel・画像・テスト
Write-Host "  [5/18] Excel・画像処理・テストライブラリをインストール中..."
& ".\python\python.exe" -m pip install openpyxl pillow pyyaml pytest faker

# Jupyter Notebook
Write-Host "  [6/18] Jupyter Notebookをインストール中..."
& ".\python\python.exe" -m pip install notebook jupyterlab ipykernel ipywidgets

# Jupyter LSP
Write-Host "  [7/18] Jupyter LSPをインストール中..."
& ".\python\python.exe" -m pip install jupyterlab-lsp python-lsp-server

# グラフ・Excel出力拡張
Write-Host "  [8/18] グラフ・Excel出力ライブラリをインストール中..."
& ".\python\python.exe" -m pip install plotly xlsxwriter

# streamlit 関係
Write-Host "  [9/18] グラフ・streamlit関連ライブラリをインストール中..."
& ".\python\python.exe" -m pip install streamlit requests

# その他（settings.jsonで参照されているもの）
Write-Host "  [10/18] その他必要なライブラリをインストール中..."
& ".\python\python.exe" -m pip install debugpy

# ゲーム開発
Write-Host "  [11/18] ゲーム開発ライブラリをインストール中..."
& ".\python\python.exe" -m pip install pygame arcade pyglet

# 機械学習・データサイエンス
Write-Host "  [12/18] 機械学習ライブラリをインストール中..."
& ".\python\python.exe" -m pip install scikit-learn statsmodels

# データベース・ORM
Write-Host "  [13/18] データベースライブラリをインストール中..."
& ".\python\python.exe" -m pip install sqlalchemy psycopg2-binary

# API開発強化
Write-Host "  [14/18] API開発強化ライブラリをインストール中..."
& ".\python\python.exe" -m pip install pydantic httpx

# 日本語処理
Write-Host "  [15/18] 日本語処理ライブラリをインストール中..."
& ".\python\python.exe" -m pip install janome

# ターミナル出力
Write-Host "  [16/18] ターミナル出力ライブラリをインストール中..."
& ".\python\python.exe" -m pip install rich

# tkinputのインストール
Write-Host "  [17/18] kbinput（キーボード入力） をインストール中..."
& ".\python\python.exe" -m pip install https://k-webs.jp/lib/python/kbinput-1.0.0-py3-none-any.whl

# tkxlibのインストール
Write-Host "  [18/18] tkxlib （教材ツール）をインストール中..."
& ".\python\python.exe" -m pip install https://k-webs.jp/lib/python/tkxlib-1.1.1-py3-none-any.whl

Write-Host "  Pythonライブラリのインストール完了" -ForegroundColor Green
Write-Host ""

# ============================================================
# 5. VS Codeのダウンロード・展開
# ============================================================

Write-Host "[4/5] VS Code Portableをダウンロード中..." -ForegroundColor Green
$vscodeUrl = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
			 
$vscodeZip = "vscode.zip"
$vscodeDir = ".\vscode"

if (Test-Path $vscodeDir) {
    Write-Host "  ○ VS Codeは既に存在します。スキップします。" -ForegroundColor Yellow
} else {
    Write-Host "  ダウンロード中（サイズが大きいため時間がかかります）..."
    Invoke-WebRequest -Uri $vscodeUrl -OutFile $vscodeZip
    
    Write-Host "  展開中..."
    Expand-Archive -Path $vscodeZip -DestinationPath $vscodeDir -Force
    Remove-Item $vscodeZip
    
    # ポータブルモード有効化
    Write-Host "  ポータブルモードを有効化中..."
    New-Item -Path "$vscodeDir\data" -ItemType Directory -Force | Out-Null
    
    Write-Host "  VS Codeのダウンロード・展開完了" -ForegroundColor Green
}

Write-Host ""

# ============================================================
# 6. VS Code拡張機能のインストール
# ============================================================

Write-Host "[5/5] VS Code拡張機能をインストール中..." -ForegroundColor Green

$extFile = ".\config\cleanExtentions.txt"

if (Test-Path $extFile) {
    $extensions = Get-Content $extFile | Where-Object { $_.Trim() -ne "" }
    
    $count = 1
    $total = $extensions.Count
    
    foreach ($ext in $extensions) {
        Write-Host "  [$count/$total] インストール中: $ext"
        & ".\vscode\bin\code.cmd" --install-extension $ext --force
        $count++
    }
    
    Write-Host "  拡張機能のインストール完了" -ForegroundColor Green
} else {
    Write-Host "  警告: cleanExtentions.txt が見つかりません" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================
# 6.5 VS Code 日本語化設定を追加
# ============================================================

Write-Host "VS Code の表示言語を日本語に設定中..." -ForegroundColor Green

$localeDir = ".\vscode\data\user-data\User"
$localeFile = Join-Path $localeDir "locale.json"

# ディレクトリが存在しない場合は作成
if (-not (Test-Path $localeDir)) {
    New-Item -Path $localeDir -ItemType Directory -Force | Out-Null
}

# locale.json に "locale": "ja" を書き込む
@'
{
    "locale": "ja"
}
'@ | Out-File -FilePath $localeFile -Encoding utf8 -Force

Write-Host "  日本語化設定(locale.json) の作成完了" -ForegroundColor Green
Write-Host ""

# ============================================================
# 7. 設定ファイルのコピー
# ============================================================

Write-Host "設定ファイルをコピー中..." -ForegroundColor Green

$settingsSource = ".\config\settings.json"
$settingsDir = ".\vscode\data\user-data\User"
$settingsDest = Join-Path $settingsDir "settings.json"

if (Test-Path $settingsSource) {
    # ディレクトリが存在しない場合は作成
    if (-not (Test-Path $settingsDir)) {
        New-Item -Path $settingsDir -ItemType Directory -Force | Out-Null
    }
    
    Copy-Item $settingsSource $settingsDest -Force
    Write-Host "  settings.json のコピー完了" -ForegroundColor Green
    Write-Host ""
    Write-Host "  注意: Pythonパスは環境変数で設定されます" -ForegroundColor Cyan
    Write-Host "  必ず launch-vscode.bat から起動してください" -ForegroundColor Cyan
} else {
    Write-Host "  警告: settings.json が見つかりません" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================
# 完了メッセージ
# ============================================================

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " セットアップが完了しました！" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "次の手順で起動してください:" -ForegroundColor White
Write-Host "  1. launch-vscode.bat をダブルクリック" -ForegroundColor Yellow
Write-Host "  2. VS Codeが起動します" -ForegroundColor Yellow
Write-Host ""
Write-Host "インストールされた環境:" -ForegroundColor White
Write-Host "  ・Python 3.12.9 (Portable)" -ForegroundColor Gray
Write-Host "  ・VS Code (Portable)" -ForegroundColor Gray
Write-Host "  ・拡張機能 ($($extensions.Count)個)" -ForegroundColor Gray
Write-Host "  ・Pythonライブラリ（numpy, pandas, jupyter等）" -ForegroundColor Gray
Write-Host ""

# ============================================================
# セットアップファイルの自動削除
# ============================================================

Write-Host "セットアップファイルを削除中..." -ForegroundColor Yellow
Write-Host ""

# 削除対象のファイルとフォルダ
$itemsToDelete = @(
    ".\config",           # configフォルダ
    ".\get-pip.py",       # get-pip.pyファイル（もし残っている場合）
    ".\python-full",	  # フル規格のpythonの展開先フォルダ
    ".\python-full.zip",  # フル規格のpythonのzipファイル
    ".\tk_error.log",       # tkl/tkのインストールログ
    "$PSCommandPath",     # setup.ps1自身
    ".\setup.bat"         # setup.bat
)

foreach ($item in $itemsToDelete) {
    if (Test-Path $item) {
        try {
            if (Test-Path $item -PathType Container) {
                # フォルダの場合
                Remove-Item $item -Recurse -Force
                Write-Host "  削除完了: $item (フォルダ)" -ForegroundColor Gray
            } else {
                # ファイルの場合
                Remove-Item $item -Force
                Write-Host "  削除完了: $item" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  警告: $item の削除に失敗しました" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "セットアップファイルの削除が完了しました。" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

