"""
report.py — Command-line reporting tool
Usage:
    python report.py                    # interactive menu
    python report.py --report revenue   # direct report
    python report.py --report all       # all reports

Available report names:
    revenue | categories | products | rfm | cohort |
    regional | status | ltv | profitability | all
"""

import argparse
import sqlite3
import sys
import textwrap
from pathlib import Path

import pandas as pd

DB_PATH = "data/ecommerce.db"
DIVIDER = "=" * 72


# ── Formatting helpers ────────────────────────────────────────────────────────

def fmt_inr(v) -> str:
    try:
        return f"₹{float(v):>12,.0f}"
    except (TypeError, ValueError):
        return str(v)


def header(title: str) -> None:
    print(f"\n{DIVIDER}")
    print(f"  {title.upper()}")
    print(DIVIDER)


def print_table(df: pd.DataFrame, max_rows: int = 20) -> None:
    if df.empty:
        print("  (no data)")
        return
    display = df.head(max_rows).to_string(index=False)
    for line in display.split("\n"):
        print("  " + line)
    if len(df) > max_rows:
        print(f"  … {len(df) - max_rows} more rows (see reports/ CSV)")


def get_conn() -> sqlite3.Connection:
    if not Path(DB_PATH).exists():
        sys.exit(
            f"\n  ERROR: Database not found at '{DB_PATH}'.\n"
            "  Run  python main.py  first to build the database.\n"
        )
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def load_csv(name: str) -> pd.DataFrame:
    path = Path(f"reports/{name}.csv")
    if not path.exists():
        return pd.DataFrame()
    return pd.read_csv(path)


# ── Individual reports ────────────────────────────────────────────────────────

def report_revenue() -> None:
    df = load_csv("monthly_revenue")
    if df.empty:
        print("  No revenue data. Run main.py first."); return

    header("Monthly Revenue Trends")
    total = df["gross_revenue"].sum()
    best  = df.loc[df["gross_revenue"].idxmax()]
    worst = df.loc[df["gross_revenue"].idxmin()]

    print(f"\n  Period       : {df['month'].min()}  →  {df['month'].max()}")
    print(f"  Total revenue: {fmt_inr(total)}")
    print(f"  Best month   : {best['month']}   {fmt_inr(best['gross_revenue'])}")
    print(f"  Worst month  : {worst['month']}  {fmt_inr(worst['gross_revenue'])}")
    print(f"  Avg MoM Δ    : {fmt_inr(df['mom_change'].mean())}\n")

    cols = ["month", "gross_revenue", "orders", "unique_customers", "mom_pct"]
    available = [c for c in cols if c in df.columns]
    print_table(df[available], max_rows=30)


def report_categories() -> None:
    df = load_csv("revenue_by_category")
    header("Revenue by Product Category")
    if df.empty: print("  No data."); return
    print_table(df)


def report_products() -> None:
    df = load_csv("top_products")
    header("Top 15 Products by Revenue")
    if df.empty: print("  No data."); return
    print_table(df)


def report_rfm() -> None:
    summary = load_csv("segment_summary")
    header("Customer RFM Segmentation")
    if summary.empty: print("  No data."); return

    print("\n  Segment Summary\n")
    print_table(summary)

    rfm = load_csv("rfm_scores")
    if rfm.empty: return
    champ = rfm[rfm["segment"] == "Champions"]
    lost  = rfm[rfm["segment"] == "Lost"]
    print(f"\n  Champions : {len(champ):,} customers  |  "
          f"avg LTV {fmt_inr(champ['monetary'].mean()) if not champ.empty else 'N/A'}")
    print(f"  Lost      : {len(lost):,} customers  |  "
          f"avg LTV {fmt_inr(lost['monetary'].mean()) if not lost.empty else 'N/A'}")


def report_cohort() -> None:
    df = load_csv("cohort_retention")
    header("Cohort Retention Analysis  (% of cohort still buying)")
    if df.empty: print("  No data."); return

    # Pivot into a readable matrix
    try:
        pivot = df.pivot_table(
            index="cohort_month",
            columns="month_number",
            values="retention_pct",
        ).round(1)
        pivot.columns = [f"M+{int(c)}" for c in pivot.columns]
        pivot.index.name = "Cohort"
        print("\n  Retention matrix (% of cohort)\n")
        print("  " + pivot.to_string())
    except Exception:
        print_table(df)

    # Average retention at M+1, M+3, M+6
    for m in [1, 3, 6]:
        sub = df[df["month_number"] == m]
        if not sub.empty:
            avg = sub["retention_pct"].mean()
            print(f"\n  Average retention at M+{m}: {avg:.1f}%")


def report_regional() -> None:
    df = load_csv("regional_performance")
    header("Regional Performance")
    if df.empty: print("  No data."); return
    print_table(df)


def report_status() -> None:
    df = load_csv("order_status")
    header("Order Status Breakdown")
    if df.empty: print("  No data."); return
    print_table(df)

    cancel = df[df["status"] == "cancelled"]
    if not cancel.empty:
        pct = cancel.iloc[0]["pct_of_total"]
        print(f"\n  ⚠  Cancellation rate: {pct}%")
        if float(pct) > 15:
            print("     This is above the 15% threshold — investigate root causes.")


def report_ltv() -> None:
    df = load_csv("customer_ltv")
    header("Top 20 Customers by Lifetime Value")
    if df.empty: print("  No data."); return
    print_table(df)

    total_ltv = df["lifetime_value"].sum()
    print(f"\n  Combined LTV of top 20: {fmt_inr(total_ltv)}")


def report_profitability() -> None:
    df = load_csv("product_profitability")
    header("Top 15 Products by Profit")
    if df.empty: print("  No data."); return
    print_table(df)

    if "total_profit" in df.columns:
        best = df.iloc[0]
        print(f"\n  Most profitable product : {best['product_name']}")
        print(f"  Margin %               : {best['margin_pct']}%")
        print(f"  Total profit           : {fmt_inr(best['total_profit'])}")


def report_all() -> None:
    report_revenue()
    report_categories()
    report_products()
    report_rfm()
    report_cohort()
    report_regional()
    report_status()
    report_ltv()
    report_profitability()


# ── Menu ──────────────────────────────────────────────────────────────────────

MENU = {
    "1":  ("Monthly Revenue Trends",        report_revenue),
    "2":  ("Revenue by Category",           report_categories),
    "3":  ("Top Products",                  report_products),
    "4":  ("Customer RFM Segmentation",     report_rfm),
    "5":  ("Cohort Retention Matrix",       report_cohort),
    "6":  ("Regional Performance",          report_regional),
    "7":  ("Order Status Breakdown",        report_status),
    "8":  ("Top Customers by LTV",          report_ltv),
    "9":  ("Product Profitability",         report_profitability),
    "10": ("All Reports",                   report_all),
    "0":  ("Exit",                          None),
}

CLI_MAP = {
    "revenue":         report_revenue,
    "categories":      report_categories,
    "products":        report_products,
    "rfm":             report_rfm,
    "cohort":          report_cohort,
    "regional":        report_regional,
    "status":          report_status,
    "ltv":             report_ltv,
    "profitability":   report_profitability,
    "all":             report_all,
}


def interactive_menu() -> None:
    get_conn()   # validate DB exists
    while True:
        print(f"\n{DIVIDER}")
        print("  E-COMMERCE ANALYTICS REPORTING TOOL")
        print(DIVIDER)
        for k, (label, _) in MENU.items():
            print(f"  [{k:>2}]  {label}")
        print(DIVIDER)
        choice = input("  Select a report: ").strip()
        if choice == "0":
            print("\n  Goodbye.\n"); break
        elif choice in MENU and MENU[choice][1]:
            MENU[choice][1]()
        else:
            print("  Invalid choice. Try again.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="E-Commerce Analytics Reporting Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""\
            Examples:
              python report.py                   # interactive menu
              python report.py --report revenue  # revenue trends
              python report.py --report all      # all reports
        """),
    )
    parser.add_argument(
        "--report", "-r",
        choices=list(CLI_MAP.keys()),
        help="Report to generate (skip for interactive menu)",
    )
    args = parser.parse_args()

    if args.report:
        get_conn()
        CLI_MAP[args.report]()
    else:
        interactive_menu()


if __name__ == "__main__":
    main()