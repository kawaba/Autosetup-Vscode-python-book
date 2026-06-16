# SPD（Structured Programming Diagram）Pythonコード生成ガイドライン

本ドキュメントは、SPDで記述された設計図からPythonコードを生成するための規約である。
AIアシスタント（GitHub Copilot等）に対する指示書として利用することを想定する。

---

## 1. 概要

SPDは構造化プログラミングの設計を罫線で表現した木構造のテキストである。
プログラムの**順次・分岐・繰り返し・例外処理**を視覚的に表し、コード化に直結する粒度で処理を記述する。

SPD 1つは、原則として **1つのプログラム／1つの関数／1つの型定義** に対応する。
Pythonコード生成では、独立したSPD文書だけでなく、docstring内に書かれたSPDも設計入力として扱う。
一方、docstringに書かれた通常の箇条書き・番号付きリストは、旧方式の指示とみなし、原則として設計入力として扱わない。

---

## 2. 記号一覧

### 2.1 構造記号

| 記号 | 意味 |
|---|---|
| `│` | 縦方向の処理の流れ |
| `├─` | 兄弟処理の項目（同じレベルにまだ続きがある） |
| `└─` | 兄弟処理の最後の項目、または上位項目の**詳細・補足** |

### 2.2 制御構造記号

| 記号 | 意味 | 対応するPython構文 |
|---|---|---|
| `◇` | 分岐 | `if` / `elif` / `else` / `match` |
| `↻` | 繰り返し | `for` / `while` |
| `〇` | 例外処理ブロック | `try` / `except` / `finally` |

---

## 3. 読解の基本ルール

### ルール1：先頭行はタイトル

SPDの最初の行は、プログラム名・関数名・型名・処理の概要のいずれかである。
docstring内にSPDがある場合は、docstringの説明文ではなく、SPDの最初の行をタイトルとして読む。

### ルール2：階層はインデントで表現

インデントが深い項目は、直上の親項目に従属する。
階層は罫線の縦線（`│`）の位置で判定する。

### ルール3：`└─` は詳細・具体化

ある処理項目に対する `└─` の子要素は、その項目の**具体化情報**を表すことが多い。

```text
├─ 整数のリストを作成して、変数listに代入する
│        └─ 要素は(10, 20, 30)
```

生成例：

```python
numbers = [10, 20, 30]
```

### ルール4：横方向の `─` 連結は処理の合成

`├─ 結果を表示する─ ◇─ numberは6である` のように、`─` で項目をつなぐ場合は、
**左の文脈の中で右の制御構造を実行する**意味になる。

### ルール5：明示されていない情報の補完

SPDに書かれていない以下の事項は、生成側が常識的に補う。

- 必要な `import` 文
- PEP 8に沿った空行、インデント、変数名
- 入門者向けコードとして、処理のまとまりごとに簡潔なコメントを原則として付ける
- コメントは、ループ・分岐・集計・表示など、学習者が処理の意図を追いやすくなる位置に付ける
- コメントは冗長にせず、コードを読む助けになる説明だけを書く
- 「変数に代入する」のようなコードをそのまま言い換えただけのコメントは避ける
- ただし、1行で意味が明白な単純な代入・表示・計算には、無理にコメントを付けない

ただし、SPDに**書かれていない処理を勝手に追加しない**こと。
`main()` 関数、実行エントリ、例外処理、入力検証、クラス化、関数分割などは、SPDまたは上位指示に根拠がある場合にのみ行う。

---

## 4. Pythonへの変換原則

### 4.1 骨格

- SPDから生成するコードは、基礎練習用のコードであるため、原則としてトップレベルに直接記述する。
- SPDに書かれている内容だけを生成し、SPDにない処理を補わない。
- SPDに明示されていない `main()` 関数や実行エントリを追加しない。
- SPDが「関数の定義」「メソッドの定義」「データクラスの定義」などを明示する場合のみ、その定義を生成する。
- SPDが `main()` の定義を明示する場合のみ、`main()` を生成する。
- `main()` を生成した場合のみ、次の実行エントリを追加する。

```python
if __name__ == "__main__":
    main()
```

### 4.2 型表記の扱い

SPD例には `int number` や `float average` のような型付き表記が含まれる場合がある。
Pythonでは次のように解釈する。

| SPD表記 | Pythonでの解釈 |
|---|---|
| `int number` | 整数として扱う変数 `number` |
| `float value` | 浮動小数点数として扱う変数 `value` |
| `str name` | 文字列として扱う変数 `name` |
| `bool flag` | 真偽値として扱う変数 `flag` |

通常の関数・変数には型ヒントを付けない。
ただし、`@dataclass` を使用する場合は、属性に型ヒントを付ける。

### 4.3 命名

- SPDで変数名が明示されている場合は、原則としてその名前を使う。
- Pythonの組み込み名と衝突する名前（例：`list`, `dict`, `str`）は避け、自然な英語名に置き換える。
  - 例：`list` → `numbers`、`items`
- 明示されていない変数名は、初心者にも意味が分かる英語のスネークケースにする。

### 4.4 辞書のマージ

- 辞書のマージでは、辞書のマージ演算子（`|`）を使用する。
- 原則として `update()` ではなく、`merged_book = book | other_book` や
    `book = book | {"price": 1000}` の形で生成する。

---

## 5. 制御構造のパターン

### 5.1 分岐（`◇`）

#### パターンA：if / else

```text
├─ ◇─ 条件
│   │    └─ 真の場合の処理
│   └─ else
│          └─ 偽の場合の処理
```

```python
if 条件:
    真の場合の処理
else:
    偽の場合の処理
```

#### パターンB：単独のif

```text
├─ ◇─ 条件
│        └─ 処理
```

```python
if 条件:
    処理
```

#### パターンC：if / elif / else

```text
└─ 結果を表示する─ ◇─ 条件1
                      │    └─ 処理1
                      ◇─ 条件2
                      │    └─ 処理2
                      └─ else
                            └─ デフォルト処理
```

```python
if 条件1:
    処理1
elif 条件2:
    処理2
else:
    デフォルト処理
```

#### パターンD：match

SPDに `match` と明示されている場合は、Pythonの `match` 文を使う。

```text
└─ ◇─ match: codeの値で判定
           ├─ case 100なら「正常終了」と表示する
           ├─ case 200か201なら「ページが存在しない」と表示する
           └─ default それ以外は「内部エラー」と表示する
```

```python
match code:
    case 100:
        print("正常終了")
    case 200 | 201:
        print("ページが存在しない")
    case _:
        print("内部エラー")
```

### 5.2 繰り返し（`↻`）

#### パターンA：for

```text
└─ ↻─ for: n ← numbers
          └─ nをコンソールに表示する
```

```python
for number in numbers:
    print(number)
```

#### パターンB：while

```text
└─ ↻─ while: numberが0でない間繰り返す
          └─ 処理
```

```python
while number != 0:
    処理
```

#### パターンC：無限ループ + break

```text
├─ 合計の計算─ ↻─ while: True
│                     ├─ 変数numberにキーボードから整数を入力する
│                     ├─ ◇─ numberは0である
│                     │          └─ breakでループを脱出する
│                     └─ totalにnumberを加算する
```

```python
while True:
    number = get_int("整数> ")
    if number == 0:
        break
    total += number
```

### 5.3 例外処理（`〇`）

#### パターンA：try / except

```text
└─ 〇─try:
     │   └─ 通常処理
     〇─except: (OSError, UnicodeDecodeError)
          └─ "ファイル入力エラー"と表示する
```

```python
try:
    通常処理
except (OSError, UnicodeDecodeError) as error:
    print("ファイル入力エラー")
```

#### パターンB：with文を含むtry

```text
└─ 〇─try: with文で、pathの入力用ファイルオブジェクトをfile_objにセットする
     │   └─ ↻─ for: line ← file_obj
     │             └─ lineをコンソールに表示する
     〇─except: (OSError, UnicodeDecodeError)
          └─ "ファイル入力エラー"と表示する
```

```python
try:
    with path.open("r", encoding="utf-8") as file_obj:
        for line in file_obj:
            print(line, end="")
except (OSError, UnicodeDecodeError) as error:
    print("ファイル入力エラー")
```

---

## 6. 関数定義のパターン

```text
マイルをキロメートルに変換
  │
  ├─ メソッドの定義
  │     ├─ 名前：mile2km
  │     ├─ 引数
  │     │    └─ float mile : マイルの値
  │     └─ 戻り値
  │           └─ float : キロメートルの値
  │
  └─ 処理
        ├─ マイルをキロメートルに変換して変数kmに代入する
        │      ├─ km = mile * 1.609
        │      └─ kmを小数点以下2桁までに四捨五入する
        └─ kmを返す
```

生成例：

```python
def mile2km(mile):
    """マイルをキロメートルに変換します。"""
    km = mile * 1.609
    km = round(km, 2)
    return km
```

関数やクラスを生成する場合、docstringがない関数・クラスには簡潔なdocstringを付ける。
ただし、docstring内にSPDがある場合、そのSPDは設計入力として扱う。
既存docstring内のSPDは、明示指示がない限り削除・改変しない。

---

## 7. クラス・dataclass定義のパターン

### 7.1 dataclass

SPDで `データクラスの定義（@dataclass）` と明示されている場合は、`dataclasses.dataclass` を使う。
生成後に属性変更が不要なデータクラスには、原則として `frozen=True` を付ける。

```text
定義：データクラスの定義（@dataclass）
│
├─ 名前: Product
├─ 属性
│    ├─ 型番─ number : str
│    ├─ 品名─ name : str
│    ├─ 価格─ price : int
│    └─ 在庫の有無─ stock : bool
└─ メソッド
      ├─ 定義
      │    ├─ 名前 : __post_init__
      │    ├─ 目的 : バリデーション
      │    ├─ 引数 : self
      │    └─ 戻り値 : なし
      └─ 処理
            └─ ◇─ self.price < 0
                        └─ 例外を発生する：ValueError("価格は負にできません")
```

生成例：

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class Product:
    """商品を表します。"""

    number: str
    name: str
    price: int
    stock: bool

    def __post_init__(self):
        if self.price < 0:
            raise ValueError("価格は負にできません")
```

### 7.2 通常クラス

- SPDまたは要件で「クラスを定義する」と明示されている場合のみ、通常クラスを生成する。
- 通常クラスの属性は、原則として `__init__` 内で `self.name` の形で定義する。
- 検証、計算、読み取り専用、副作用が必要な属性のみ `@property` を使う。
- 通常クラスには `__repr__` を定義する。

---

## 8. Pythonコード生成規約

### 8.1 言語・スタイル

- PEP 8に準拠する。
- 1行は79文字以内を目指す。
- 関数は30行以内を目安にする。
- 初心者向けとして、読みやすさを優先する。
- 文字列のフォーマットにはf文字列を使う。
- 平方根の計算では `x ** 0.5` を使う。
- 組み込み関数で代替可能な場合は、`len()`、`sum()`、`max()`、`min()` などを優先する。
- `map()` や `filter()` よりリスト内包表記を優先する。
- 複雑な内包表記になる場合は、明示的な `for` 文を使う。

### 8.2 入出力

要件定義から生成する場合、またはSPDでキーボード入力が指示された場合は、原則として `tkxlib` の入力関数を使う。
ただし、既存コードや課題の条件が `input()` を前提としている場合は、それに従う。

| SPDの記述 | Pythonコード |
|---|---|
| キーボードから整数を入力 | `get_int("整数> ")` |
| キーボードから実数を入力 | `get_float("実数> ")` |
| キーボードから文字列を入力 | `get_str("文字列> ")` |
| コンソールに表示 | `print(...)` |
| `"合計=〇〇"` の形式で表示 | `print(f"合計={total}")` |
| コロンとタブで区切って表示 | `print(f"{name}:\t{price}")` |

`tkxlib` を使う場合は、必要な関数をインポートする。

```python
from tkxlib import get_int
```

### 8.3 数値処理

| SPDの記述 | Pythonコード |
|---|---|
| 小数点以下N桁までに四捨五入 | `round(value, N)` |
| 整数へ四捨五入 | `round(value)` |
| 整数を小数に変換 | `float(value)` |

### 8.4 ファイルI/O

- ファイルパスは `pathlib.Path` オブジェクトで表す。
- テキストの一括読み込みは `path.read_text(encoding="utf-8")` を使う。
- テキストの一括書き込みは `path.write_text(text, encoding="utf-8")` を使う。
- 行単位の読み書き、追記、CSVでは `path.open(...)` を使う。
- `path.open(...)` を使う場合は、必ず `with` 文を使う。
- テキストファイルの読み書きでは `encoding="utf-8"` を明示する。
- ファイル入出力では例外処理を行う。

### 8.5 CSV

- 拡張子が `.csv` の場合は、標準ライブラリの `csv` モジュールを使う。
- `.csv` の解析に `split()` を使わない。
- 読み込み時は `path.open("r", newline="", encoding="utf-8")` を使う。
- 書き込み時は `path.open("w", newline="", encoding="utf-8")` を使う。
- 原則として `csv.reader` と `csv.writer` を使う。
- `DictReader` / `DictWriter` は明示指示がある場合のみ使う。
- `csv` モジュールを使う `try` 文では `csv.Error` も補足する。

---

## 9. 完全な変換例

### SPD

```text
リストの要素を集計する
│
├─ 整数のリストを作成して、変数listに代入する
│        └─ 要素は(10, 20, 30)
├─ 合計を入れる変数int totalを宣言してゼロを代入する
├─ ↻─ for: n ← list
│        └─ nをtotalに加算する
├─ 平均を計算して変数float averageに代入する
│        └─ 平均は、floatに変換したtotalをlistの要素数で割り、小数点以下1桁までに四捨五入する
├─ 合計を"合計＝〇〇"の書式でコンソールに表示する
└─ 平均を"平均＝〇〇"の書式でコンソールに表示する
```

### 生成Pythonコード

```python
numbers = [10, 20, 30]

total = 0
for number in numbers:
    total += number

average = round(float(total) / len(numbers), 1)

print(f"合計＝{total}")
print(f"平均＝{average:.1f}")
```

---

## 10. 生成時のチェックリスト

コード生成後、以下を確認する。

- [ ] SPDの全ノードがコードに反映されているか
- [ ] 制御構造の入れ子関係がSPDと一致しているか
- [ ] 変数名・型の解釈がSPDの指定と矛盾していないか
- [ ] 出力書式（`"合計＝〇〇"` 等）が忠実に再現されているか
- [ ] SPDにない処理を勝手に追加していないか
- [ ] 例外処理がSPDの指示通りか
- [ ] SPDに明示されていない `main()` や実行エントリを追加していないか
- [ ] Pythonの組み込み名を変数名で上書きしていないか
- [ ] PEP 8に準拠しているか
- [ ] ファイルI/Oでは `pathlib.Path` と `encoding="utf-8"` を使っているか
- [ ] `.csv` では `csv` モジュールを使っているか
- [ ] `@dataclass` では属性に型ヒントを付けているか

---

## 11. 補足事項

- SPDの記述に曖昧さがある場合は、最も自然な解釈を採用し、必要に応じてコメントで示す。
- 罫線のレイアウトの揺れ（全角／半角スペースの混在等）は無視してよい。
- 意味のあるのは、記号、階層構造、処理文、制御構造である。
- 例は `.github/SPD-example-v3.txt` も参照する。
