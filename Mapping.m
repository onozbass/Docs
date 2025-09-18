let
    // 元データ
    SourceTable = Table.FromRecords({
        [ID = 1, Code = "A"],
        [ID = 2, Code = "B"],
        [ID = 3, Code = "X"]  // マッピングに存在しないコード
    }),

    // マッピングテーブル
    MappingTable = Table.FromRecords({
        [Code = "A", Name = "Apple"],
        [Code = "B", Name = "Banana"],
        [Code = "C", Name = "Cherry"]
    }),

    // マッピングテーブルをリストに変換
    MappingList = List.Transform(MappingTable, each {_[Code], _[Name]}),

    // 変換関数を定義
    ReplaceCode = (code as text) =>
        let
            match = List.First(List.Select(MappingList, each _{0} = code), null)
        in
            if match = null then code else match{1},

    // 新しい列を追加（置換後の値）
    WithMappedCode = Table.AddColumn(SourceTable, "MappedCode", each ReplaceCode([Code]), type text),

    // 元の列を削除（任意）
    FinalTable = Table.RemoveColumns(WithMappedCode, {"Code"})
in
    FinalTable
```

### 💡補足

- `List.First(List.Select(...), null)` を使うことで、マッチしない場合に `null` を返し、元の値を保持できます。
- この方法は **マッピングテーブルが小規模で、頻繁に更新されない場合**に適しています。
- 大規模なマッピングやパフォーマンスが重要な場合は、`Table.Join` + `Table.AddColumn` + `Record.FieldOrDefault` の組み合わせがより効率的です。
