from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt


SRC_XLSX = "olap_variant7_promotion.xlsx"
OUT_XLSX = "Pr3_variant7_client_report.xlsx"
OUT_PNG = "Pr3_variant7_chart.png"


def load_slice(path: str | Path) -> pd.DataFrame:
    df = pd.read_excel(path, sheet_name="Slice_Variant7", parse_dates=["Date", "PromotionEndDate"])
    df["OrderCount"] = 1
    return df


def pivots(df: pd.DataFrame) -> dict[str, pd.DataFrame]:
    p1 = (
        pd.pivot_table(
            df,
            index=["Year", "Quarter", "Month"],
            columns=["Country"],
            values=["UnitSales", "StoreSales", "StoreCost"],
            aggfunc="sum",
            fill_value=0
        )
        .sort_index()
    )

    p2 = (
        pd.pivot_table(
            df,
            index=["Country", "City"],
            columns=["Year", "Quarter"],
            values=["UnitSales", "StoreSales"],
            aggfunc="sum",
            fill_value=0
        )
        .sort_index()
    )

    p3 = (
        df.groupby(["Date", "Country"], as_index=False)[["StoreSales", "UnitSales"]]
        .sum()
        .sort_values(["Date", "Country"])
    )

    return {
        "Pivot_Time_Country": p1,
        "Pivot_Location_Time": p2,
        "Series_Daily": p3,
    }


def make_chart(series_df: pd.DataFrame, out_png: str) -> None:
    wide = series_df.pivot(index="Date", columns="Country", values="StoreSales").fillna(0).sort_index()

    plt.figure(figsize=(10, 5))
    for col in wide.columns:
        plt.plot(wide.index, wide[col], label=str(col))
    plt.title("StoreSales (сума) за датами — Variant 7 (Promotion)")
    plt.xlabel("Date")
    plt.ylabel("StoreSales (sum)")
    plt.grid(True)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_png, dpi=160)
    plt.close()


def export_report(out_xlsx: str, df_slice: pd.DataFrame, outputs: dict[str, pd.DataFrame]) -> None:
    with pd.ExcelWriter(out_xlsx, engine="xlsxwriter", datetime_format="yyyy-mm-dd") as writer:
        df_slice.to_excel(writer, sheet_name="Slice_Variant7", index=False)
        for name, table in outputs.items():
            table.to_excel(writer, sheet_name=name, index=True)


def main() -> None:
    df = load_slice(SRC_XLSX)
    outs = pivots(df)
    make_chart(outs["Series_Daily"], OUT_PNG)
    export_report(OUT_XLSX, df, outs)

    print("Готово:")
    print(f"- {Path(OUT_XLSX).resolve()}")
    print(f"- {Path(OUT_PNG).resolve()}")
    print(f"- Slice rows: {len(df)}")


if __name__ == "__main__":
    main()