# ============================================================
# Portable Python + VS Code セットアップスクリプト
# ============================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'  # 高速化

# ============================================================
# ログ機構（外部コマンドの出力・終了コードを確実に記録する）
# ============================================================

$script:LogPath   = Join-Path $PSScriptRoot "setup-log.txt"
$script:ErrorList = New-Object System.Collections.ArrayList

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $line = "{0} [{1}] {2}" -f (Get-Date -Format "HH:mm:ss"), $Level, $Message
    try { Add-Content -Path $script:LogPath -Value $line -Encoding UTF8 } catch { }
}

# 画面とログの両方に出す
function Write-Both {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
    Write-Log $Message
}

# 外部プログラム（python.exe / code.cmd 等）の実行ラッパー
#   - 標準出力・標準エラーをすべてログへ
#   - 終了コードが 0 以外なら「失敗」として画面に赤字表示＋一覧に記録
function Invoke-Logged {
    param(
        [string]$Label,
        [string]$FilePath,
        [string[]]$ArgList = @()
    )

    Write-Log "実行: $FilePath $($ArgList -join ' ')" "EXEC"

    # 外部コマンドの stderr は ErrorActionPreference=Stop だと例外化するため一時的に解除
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $global:LASTEXITCODE = 0
    try {
        $output = & $FilePath @ArgList 2>&1
        $code   = $LASTEXITCODE
    } catch {
        $output = $_.Exception.Message
        $code   = -1
    } finally {
        $ErrorActionPreference = $prevEAP
    }

    foreach ($line in $output) {
        $text = if ($line -is [System.Management.Automation.ErrorRecord]) { $line.ToString() } else { [string]$line }
        if ($text.Trim() -ne "") { Write-Log ("    " + $text) }
    }

    if ($code -ne 0) {
        Write-Host "  × 失敗: $Label (終了コード $code)" -ForegroundColor Red
        Write-Host "    → 詳細は setup-log.txt を確認してください" -ForegroundColor Yellow
        Write-Log "失敗: $Label (終了コード $code)" "ERROR"
        [void]$script:ErrorList.Add("$Label (終了コード $code)")
    } else {
        Write-Log "成功: $Label" "OK"
    }
    return $code
}

# ダウンロード（失敗しても止めずに記録する）
function Invoke-Download {
    param([string]$Label, [string]$Uri, [string]$OutFile)
    Write-Log "ダウンロード: $Label <- $Uri" "EXEC"
    try {
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
        Write-Log "成功: $Label" "OK"
        return $true
    } catch {
        Write-Host "  × ダウンロード失敗: $Label" -ForegroundColor Red
        Write-Log "ダウンロード失敗: $Label / $($_.Exception.Message)" "ERROR"
        [void]$script:ErrorList.Add("ダウンロード失敗: $Label")
        return $false
    }
}

# ログを初期化
try {
    "" | Out-File -FilePath $script:LogPath -Encoding UTF8 -Force
} catch {
    # 別プロセス(Start-Transcript 等)がファイルを掴んでいる場合は別名にする
    $script:LogPath = Join-Path $PSScriptRoot "setup-log-detail.txt"
    "" | Out-File -FilePath $script:LogPath -Encoding UTF8 -Force
}
Write-Log "==================== セットアップ開始 ===================="
Write-Log "日時         : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Log "実行フォルダ : $PSScriptRoot"
Write-Log "PSVersion    : $($PSVersionTable.PSVersion)"
Write-Log "OS           : $([System.Environment]::OSVersion.VersionString)"
Write-Log "コンピュータ : $env:COMPUTERNAME / ユーザー: $env:USERNAME"
Write-Log "=========================================================="

# 想定外の中断（ダウンロード失敗など）もログに残す
trap {
    Write-Log "予期しないエラー: $($_.Exception.Message)" "FATAL"
    Write-Log "発生位置: $($_.InvocationInfo.PositionMessage)" "FATAL"
    Write-Host ""
    Write-Host "  ×××  予期しないエラーで中断しました  ×××" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  詳細は setup-log.txt を確認してください" -ForegroundColor Yellow
    Write-Host ""
    $null = Read-Host "終了するには Enter キーを押してください"
    exit 1
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Portable Python + VS Code 環境セットアップ開始" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 0. 実行パスの長さチェック（Windowsロングパス対策）
# ============================================================

$currentPath = $PSScriptRoot
$pathLengthWarningThreshold = 60

Write-Host "[0/5] 実行パスを確認中..." -ForegroundColor Yellow
Write-Host "  現在の実行フォルダ: $currentPath"
Write-Host "  パスの文字数: $($currentPath.Length) 文字"

if ($currentPath.Length -gt $pathLengthWarningThreshold) {
    Write-Host ""
    Write-Host "  ★★★ 警告 ★★★" -ForegroundColor Red
    Write-Host "  実行フォルダのパスが長すぎる可能性があります。" -ForegroundColor Red
    Write-Host "  Cドライブの直下など、短いパスで実行してください。" -ForegroundColor Red
    Write-Host "  このまま進めると、インストール中にファイルパスが" -ForegroundColor Red
    Write-Host "  Windowsの制限（260文字）を超えて失敗する可能性があります。" -ForegroundColor Red
    Write-Host ""
    Write-Host "  よくある原因:" -ForegroundColor Yellow
    Write-Host "    ・Downloads フォルダ内で実行している" -ForegroundColor Yellow
    Write-Host "    ・GitHubの「Download ZIP」でフォルダ名が二重になっている" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  実行フォルダを移動するため中止しますか？ (Y/N)" -ForegroundColor White
    $continueAnswer = Read-Host

    if ($continueAnswer -eq "Y" -or $continueAnswer -eq "y") {
        Write-Host ""
        Write-Host "  セットアップを中止しました。" -ForegroundColor Yellow
        Write-Host "  フォルダを短いパスへ移動してから再実行してください。" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "終了するには何かキーを押してください..." -ForegroundColor White
        try {
            $Host.UI.RawUI.FlushInputBuffer()
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        } catch {
            $null = Read-Host "終了するには Enter キーを押してください"
        }
        exit 1
    }

    Write-Host ""
    Write-Host "  続行します。失敗する場合はフォルダを短いパスへ移動してください。" -ForegroundColor Yellow
} else {
    Write-Host "  パスの長さは問題ありません。" -ForegroundColor Green
}

Write-Host ""

# ============================================================
# 1. ポータブルPythonのダウンロード・展開
# ============================================================

Write-Host "[1/5] ポータブルPythonをダウンロード中..." -ForegroundColor Green

# Python 3.13.13 Embeddable版（64bit）
$pythonUrl = "https://www.python.org/ftp/python/3.13.13/python-3.13.13-amd64.zip"
$pythonZip = "python.zip"
$pythonDir = ".\python"

if (Test-Path $pythonDir) {
    Write-Host "  ○ Pythonは既に存在します。スキップします。" -ForegroundColor Yellow
} else {
    Write-Host "  ダウンロード中: $pythonUrl"
    if (-not (Invoke-Download "ポータブルPython本体" $pythonUrl $pythonZip)) {
        throw "Python本体のダウンロードに失敗しました。ネットワーク接続を確認してください。"
    }
    
    Write-Host "  展開中..."
    Expand-Archive -Path $pythonZip -DestinationPath $pythonDir -Force
    Remove-Item $pythonZip
    
    Write-Host "  Pythonのダウンロード・展開完了" -ForegroundColor Green
}

# ============================================================
# python313._pth の修正（pip有効化のため）
# ============================================================

Write-Host "  python313._pth を修正中..."
$pthFile = Join-Path $pythonDir "python313._pth"

if (Test-Path $pthFile) {
    $content = Get-Content $pthFile
    $newContent = $content -replace '^#import site', 'import site'
    $newContent | Set-Content $pthFile -Encoding ASCII
    Write-Host "  python313._pth の修正完了" -ForegroundColor Green
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
    Write-Log $msg "TK"
}

try {
    $fullZip = ".\python-full.zip"
    $fullDir = ".\python-full"

    if (!(Test-Path $fullDir)) {
        Write-Host "  フル版Python(ZIP)をダウンロード中..." -ForegroundColor Gray
        $url = "https://www.python.org/ftp/python/3.13.13/python-3.13.13-amd64.zip"
        if (-not (Invoke-Download "フル版Python(Tcl/Tk用)" $url $fullZip)) {
            throw "フル版Pythonのダウンロードに失敗しました"
        }

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
if (-not (Invoke-Download "get-pip.py" $getPipUrl $getPipFile)) {
    throw "get-pip.py のダウンロードに失敗しました。ネットワーク接続を確認してください。"
}

Write-Host "  pip をインストール中..."
Invoke-Logged "$getPipFile --no-warn-script-location" ".\python\python.exe" @($getPipFile, "--no-warn-script-location") | Out-Null

Write-Host "  pipのバージョン確認:"
Invoke-Logged "-m pip --version" ".\python\python.exe" @("-m", "pip", "--version") | Out-Null

Write-Host "  pipのインストール完了" -ForegroundColor Green
Write-Host ""

# ============================================================
# 3. Pythonライブラリのインストール
# ============================================================

Write-Host "[3/5] Pythonライブラリをインストール中..." -ForegroundColor Green
Write-Host "  （この処理には5~10分かかる場合があります）" -ForegroundColor Yellow
Write-Host ""

# PATHの設定
$env:PATH = "$PWD\python;$PWD\python\Scripts;$env:PATH"

# pipのアップグレード
Write-Host "  pip をアップグレード中..."
Invoke-Logged "-m pip install --upgrade pip" ".\python\python.exe" @("-m", "pip", "install", "--upgrade", "pip") | Out-Null

# wheelのインストール
Write-Host "  wheel をインストール中..."
Invoke-Logged "-m pip install wheel" ".\python\python.exe" @("-m", "pip", "install", "wheel") | Out-Null

# コード整形・静的解析ツール
Write-Host "  [1/17] コード整形・解析ツールをインストール中..."
Invoke-Logged "-m pip install black pylint flake8 autopep8 isort mypy" ".\python\python.exe" @("-m", "pip", "install", "black", "pylint", "flake8", "autopep8", "isort", "mypy") | Out-Null

# ユーティリティ系
Write-Host "  [2/17] ユーティリティをインストール中..."
Invoke-Logged "-m pip install requests python-dotenv tqdm colorama" ".\python\python.exe" @("-m", "pip", "install", "requests", "python-dotenv", "tqdm", "colorama") | Out-Null

# 数値・統計・可視化
Write-Host "  [3/17] 数値計算・可視化ライブラリをインストール中..."
Invoke-Logged "-m pip install --only-binary :all: numpy pandas matplotlib scipy seaborn" ".\python\python.exe" @("-m", "pip", "install", "--only-binary", ":all:", "numpy", "pandas", "matplotlib", "scipy", "seaborn") | Out-Null

# Web開発
Write-Host "  [4/17] Web開発ライブラリをインストール中..."
Invoke-Logged "-m pip install flask requests fastapi uvicorn beautifulsoup4 lxml" ".\python\python.exe" @("-m", "pip", "install", "flask", "requests", "fastapi", "uvicorn", "beautifulsoup4", "lxml") | Out-Null

# Excel・画像・テスト
Write-Host "  [5/17] Excel・画像処理・テストライブラリをインストール中..."
Invoke-Logged "-m pip install openpyxl pillow pyyaml pytest faker" ".\python\python.exe" @("-m", "pip", "install", "openpyxl", "pillow", "pyyaml", "pytest", "faker") | Out-Null

# Jupyter Notebook
Write-Host "  [6/17] Jupyter Notebookをインストール中..."
Invoke-Logged "-m pip install notebook jupyterlab ipykernel ipywidgets" ".\python\python.exe" @("-m", "pip", "install", "notebook", "jupyterlab", "ipykernel", "ipywidgets") | Out-Null

# Jupyter LSP
Write-Host "  [7/17] Jupyter LSPをインストール中..."
Invoke-Logged "-m pip install jupyterlab-lsp python-lsp-server" ".\python\python.exe" @("-m", "pip", "install", "jupyterlab-lsp", "python-lsp-server") | Out-Null

# グラフ・Excel出力拡張
Write-Host "  [8/17] グラフ・Excel出力ライブラリをインストール中..."
Invoke-Logged "-m pip install plotly xlsxwriter" ".\python\python.exe" @("-m", "pip", "install", "plotly", "xlsxwriter") | Out-Null

# streamlit 関係
Write-Host "  [9/17] グラフ・streamlit関連ライブラリをインストール中..."
Invoke-Logged "-m pip install streamlit requests" ".\python\python.exe" @("-m", "pip", "install", "streamlit", "requests") | Out-Null

# その他（settings.jsonで参照されているもの）
Write-Host "  [10/17] その他必要なライブラリをインストール中..."
Invoke-Logged "-m pip install debugpy" ".\python\python.exe" @("-m", "pip", "install", "debugpy") | Out-Null

# ゲーム開発
Write-Host "  [11/17] ゲーム開発ライブラリをインストール中..."
Invoke-Logged "-m pip install pygame arcade pyglet" ".\python\python.exe" @("-m", "pip", "install", "pygame", "arcade", "pyglet") | Out-Null

# 機械学習・データサイエンス
Write-Host "  [12/17] 機械学習ライブラリをインストール中..."
Invoke-Logged "-m pip install scikit-learn statsmodels" ".\python\python.exe" @("-m", "pip", "install", "scikit-learn", "statsmodels") | Out-Null

# データベース・ORM
Write-Host "  [13/17] データベースライブラリをインストール中..."
Invoke-Logged "-m pip install sqlalchemy psycopg2-binary" ".\python\python.exe" @("-m", "pip", "install", "sqlalchemy", "psycopg2-binary") | Out-Null

# API開発強化
Write-Host "  [14/17] API開発強化ライブラリをインストール中..."
Invoke-Logged "-m pip install pydantic httpx" ".\python\python.exe" @("-m", "pip", "install", "pydantic", "httpx") | Out-Null

# 日本語処理
Write-Host "  [15/17] 日本語処理ライブラリをインストール中..."
Invoke-Logged "-m pip install janome" ".\python\python.exe" @("-m", "pip", "install", "janome") | Out-Null

# ターミナル出力
Write-Host "  [16/17] ターミナル出力ライブラリをインストール中..."
Invoke-Logged "-m pip install rich" ".\python\python.exe" @("-m", "pip", "install", "rich") | Out-Null

# tkxlibのインストール
Write-Host "  [17/17] tkxlib （教材ツール）をインストール中..."
Invoke-Logged "-m pip install https://k-webs.jp/lib/python/tkxlib-2.0.1-py3-none-any.whl" ".\python\python.exe" @("-m", "pip", "install", "https://k-webs.jp/lib/python/tkxlib-2.0.1-py3-none-any.whl") | Out-Null

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
    if (-not (Invoke-Download "VS Code Portable" $vscodeUrl $vscodeZip)) {
        throw "VS Code のダウンロードに失敗しました。ネットワーク接続を確認してください。"
    }
    
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
        Invoke-Logged "拡張機能 $ext" ".\vscode\bin\code.cmd" @("--install-extension", $ext, "--force") | Out-Null
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
if ($script:ErrorList.Count -eq 0) {
    Write-Host " セットアップが完了しました！" -ForegroundColor Cyan
} else {
    Write-Host " セットアップは終了しましたが、エラーがあります" -ForegroundColor Red
}
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "次の手順で起動してください:" -ForegroundColor White
Write-Host "  1. launch-vscode.bat をダブルクリック" -ForegroundColor Yellow
Write-Host "  2. VS Codeが起動します" -ForegroundColor Yellow
Write-Host ""
Write-Host "インストールされた環境:" -ForegroundColor White
Write-Host "  ・Python 3.13.13 (Portable)" -ForegroundColor Gray
Write-Host "  ・VS Code (Portable)" -ForegroundColor Gray
Write-Host "  ・拡張機能 ($($extensions.Count)個)" -ForegroundColor Gray
Write-Host "  ・Pythonライブラリ（numpy, pandas, jupyter等）" -ForegroundColor Gray
Write-Host ""

# ============================================================
# セットアップファイルの自動削除
# ============================================================

# ============================================================
# エラーサマリ
# ============================================================

if ($script:ErrorList.Count -gt 0) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " 【注意】$($script:ErrorList.Count) 件のエラーが発生しました" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    foreach ($e in $script:ErrorList) {
        Write-Host "  ・$e" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "  詳細は setup-log.txt を確認してください。" -ForegroundColor Yellow
    Write-Host "  セットアップファイルは削除せずに残します（修正後、再実行できます）。" -ForegroundColor Yellow
    Write-Host ""
    Write-Log "エラー合計: $($script:ErrorList.Count) 件" "ERROR"
    foreach ($e in $script:ErrorList) { Write-Log "  - $e" "ERROR" }
} else {
    Write-Log "エラーなしで完了しました" "OK"
}

# ============================================================
# セットアップファイルの自動削除（エラーが無い場合のみ）
# ============================================================

if ($script:ErrorList.Count -eq 0) {

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

}
Write-Host ""
Write-Log "==================== セットアップ終了 (エラー $($script:ErrorList.Count) 件) ===================="
Write-Host ""
Write-Host "  ログ: $script:LogPath" -ForegroundColor Gray
Write-Host ""
Write-Host "終了するには何かキーを押してください..." -ForegroundColor White
try {
    # 入力バッファに残っているキー（起動時のEnterなど）を破棄してから待機
    $Host.UI.RawUI.FlushInputBuffer()
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    # ReadKey が使えない環境では Enter 待ちにフォールバック
    $null = Read-Host "終了するには Enter キーを押してください"
}

exit 0
