from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import numpy as np
import pandas as pd


V7_END_DATE = pd.to_datetime("2012-01-18")
V7_MEDIA_TYPE = "In-Store Coupon"


@dataclass(frozen=True)
class Settings:
    seed: int = 23
    rows: int = 800
    out_xlsx: str = "olap_variant7_promotion.xlsx"


S = Settings()


def generate_sales_like_facts(seed: int, rows: int) -> pd.DataFrame:
    rng = np.random.default_rng(seed)

    date_pool = pd.date_range("2011-01-01", "2013-12-31", freq="D")

    countries = ["Ukraine", "Poland"]
    cities = ["Kyiv", "Lviv", "Warsaw", "Krakow"]

    promo_end_dates = pd.to_datetime([
        "2012-01-18",
        "2012-02-10",
        "2012-03-05",
        "2012-04-22",
        "2012-06-15",
    ])
    promo_media_types = [
        "In-Store Coupon",
        "TV",
        "Radio",
        "Social Media",
        "Outdoor",
    ]

    df = pd.DataFrame({
        "Date": rng.choice(date_pool, size=rows),
        "Country": rng.choice(countries, size=rows),
        "City": rng.choice(cities, size=rows),
        "PromotionEndDate": rng.choice(promo_end_dates, size=rows),
        "PromotionMediaType": rng.choice(promo_media_types, size=rows),
        "UnitSales": rng.integers(1, 60, size=rows),
        "StoreCost": rng.uniform(5.0, 55.0, size=rows).round(2),
    })

    return df


def enrich_time(df: pd.DataFrame) -> pd.DataFrame:
    out = df.copy()
    out["Year"] = out["Date"].dt.year
    out["Quarter"] = out["Date"].dt.quarter
    out["Month"] = out["Date"].dt.month
    out["Day"] = out["Date"].dt.day
    return out


def calc_store_sales(df: pd.DataFrame, seed: int) -> pd.DataFrame:
    rng = np.random.default_rng(seed + 999)
    out = df.copy()
    margin = rng.uniform(1.10, 1.70, size=len(out)).round(2)
    out["StoreSales"] = (out["StoreCost"] * out["UnitSales"] * margin).round(2)
    return out


def slice_variant7(df: pd.DataFrame) -> pd.DataFrame:
    m = (df["PromotionEndDate"] == V7_END_DATE) & (df["PromotionMediaType"] == V7_MEDIA_TYPE)
    return df.loc[m].copy()


def build_olap_cube(df_slice: pd.DataFrame) -> pd.DataFrame:
    dims_rows = ["PromotionEndDate", "PromotionMediaType", "Year", "Quarter"]
    dims_cols = ["Country"]
    measures = ["UnitSales", "StoreSales", "StoreCost"]

    grouped = (
        df_slice
        .groupby(dims_rows + dims_cols, as_index=True)[measures]
        .sum()
        .round(2)
    )

    cube = grouped.unstack("Country", fill_value=0).sort_index(axis=1)
    return cube


def export_excel(path: str | Path, df_all: pd.DataFrame, df_slice: pd.DataFrame, cube: pd.DataFrame) -> None:
    path = Path(path)
    with pd.ExcelWriter(path, engine="xlsxwriter", datetime_format="yyyy-mm-dd") as writer:
        df_all.to_excel(writer, sheet_name="Fact_All", index=False)
        df_slice.to_excel(writer, sheet_name="Slice_Variant7", index=False)
        cube.to_excel(writer, sheet_name="Cube_V7")

    print(f"Excel created: {path.resolve()}")
    print(f"Variant 7 slice rows: {len(df_slice)}")


def main() -> None:
    df = generate_sales_like_facts(S.seed, S.rows)
    df = enrich_time(df)
    df = calc_store_sales(df, S.seed)

    df_v7 = slice_variant7(df)
    cube_v7 = build_olap_cube(df_v7)

    export_excel(S.out_xlsx, df, df_v7, cube_v7)


if __name__ == "__main__":
    main()