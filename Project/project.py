"""
report.py — Healthcare Analytics CLI Reporting Tool
─────────────────────────────────────────────────────────────────
Usage:
    python report.py                         # interactive menu
    python report.py --report hospitals      # hospital ranking
    python report.py --report conditions     # condition analysis
    python report.py --report all            # full report

Available reports:
    hospitals | conditions | trends | insurance |
    doctors | age | billing | medications | all
─────────────────────────────────────────────────────────────────
"""

import argparse
import sqlite3
import sys
import textwrap
from pathlib import Path
import pandas as pd

DB_PATH  = "healthcare.db"
DIVIDER  = "=" * 65
THIN_DIV = "─" * 65


def get_conn() -> sqlite3.Connection:
    if not Path(DB_PATH).exists():
        sys.exit(
            "\n  ERROR: Database not found.\n"
            "  Run  python main.py  first to build the pipeline.\n"
        )
    return sqlite3.connect(DB_PATH)


def load(table: str) -> pd.DataFrame:
    try:
        conn = get_conn()
        df = pd.read_sql_query(f"SELECT * FROM {table}", conn)
        conn.close()
        return df
    except Exception:
        return pd.DataFrame()


def header(title: str) -> None:
    print(f"\n{DIVIDER}\n  {title.upper()}\n{DIVIDER}")


def show(df: pd.DataFrame, max_rows: int = 20) -> None:
    if df.empty:
        print("  (no data — run main.py first)")
        return
    for line in df.head(max_rows).to_string(index=False).split("\n"):
        print("  " + line)
    if len(df) > max_rows:
        print(f"  … {len(df) - max_rows} more rows in reports/ CSV")


# ── Individual reports ────────────────────────────────────────────

def report_hospitals():
    header("Hospital Ranking by Revenue")
    df = load("gold_hospital_ranking")
    if df.empty: show(df); return

    top = df.iloc[0]
    print(f"\n  #1 Hospital : {top['Hospital']}")
    print(f"  Revenue     : ₹{float(top['total_revenue']):>15,.2f}")
    print(f"  Patients    : {int(top['total_patients']):,}")
    print(f"  Avg Billing : ₹{float(top['avg_billing']):>12,.2f}")
    print(f"\n  Full ranking:\n")
    show(df[["revenue_rank","Hospital","total_patients",
             "total_revenue","avg_billing","avg_stay_days","abnormal_pct"]])


def report_conditions():
    header("Medical Condition Analysis")
    df = load("gold_condition_analysis")
    if df.empty: show(df); return

    print(f"\n  Conditions tracked : {len(df)}")
    top = df.iloc[0]
    print(f"  Highest billing    : {top['condition']} "
          f"(₹{float(top['total_billing']):,.0f}  |  {top['pct_of_revenue']}% of revenue)")
    print()
    show(df[["billing_rank","condition","patient_count","pct_of_patients",
             "total_billing","pct_of_revenue","avg_stay_days","avg_patient_age"]])


def report_trends():
    header("Monthly Admission Trends")
    df = load("gold_monthly_trends")
    if df.empty: show(df); return

    total_rev = df["monthly_revenue"].sum()
    print(f"\n  Total revenue (all time) : ₹{total_rev:,.0f}")
    print(f"  Peak admissions month    : "
          f"{int(df.loc[df['admissions'].idxmax(),'year'])}-"
          f"{int(df.loc[df['admissions'].idxmax(),'month']):02d}  "
          f"({int(df['admissions'].max())} admissions)")
    print()
    show(df, max_rows=24)


def report_insurance():
    header("Insurance Provider Analysis")
    df = load("gold_insurance_analysis")
    show(df)


def report_doctors():
    header("Top 30 Doctors by Patient Volume")
    df = load("gold_doctor_performance")
    if df.empty: show(df); return
    show(df[["Doctor","Hospital","patients_treated","avg_billing",
             "avg_stay_days","normal_pct","rank_in_hospital"]])


def report_age():
    header("Age Group Health Profile")
    df = load("gold_age_group_analysis")
    show(df)


def report_billing():
    header("Billing Tier Distribution")
    df = load("gold_billing_tiers")
    if df.empty: show(df); return

    premium = df[df["billing_tier"].str.contains("Premium", na=False)]
    if not premium.empty:
        print(f"\n  Premium patients (>50K) : "
              f"{int(premium['patients'].values[0]):,} "
              f"({premium['pct_of_patients'].values[0]}% of patients, "
              f"{premium['pct_of_revenue'].values[0]}% of revenue)")
    print()
    show(df)


def report_medications():
    header("Medication Usage by Condition")
    df = load("gold_medication_analysis")
    show(df[df["rank_in_condition"] == 1])   # top med per condition


def report_all():
    report_hospitals()
    report_conditions()
    report_trends()
    report_insurance()
    report_age()
    report_billing()
    report_medications()


# ── Menu ──────────────────────────────────────────────────────────

MENU = {
    "1":  ("Hospital Ranking",             report_hospitals),
    "2":  ("Medical Condition Analysis",   report_conditions),
    "3":  ("Monthly Admission Trends",     report_trends),
    "4":  ("Insurance Provider Analysis",  report_insurance),
    "5":  ("Doctor Performance",           report_doctors),
    "6":  ("Age Group Health Profile",     report_age),
    "7":  ("Billing Tier Distribution",    report_billing),
    "8":  ("Medication Usage",             report_medications),
    "9":  ("All Reports",                  report_all),
    "0":  ("Exit",                         None),
}

CLI_MAP = {
    "hospitals":  report_hospitals,
    "conditions": report_conditions,
    "trends":     report_trends,
    "insurance":  report_insurance,
    "doctors":    report_doctors,
    "age":        report_age,
    "billing":    report_billing,
    "medications":report_medications,
    "all":        report_all,
}


def interactive_menu():
    get_conn()
    while True:
        print(f"\n{DIVIDER}")
        print("  HEALTHCARE DATA PIPELINE — ANALYTICS REPORTS")
        print(DIVIDER)
        for k, (label, _) in MENU.items():
            print(f"  [{k}]  {label}")
        print(DIVIDER)
        choice = input("  Select report: ").strip()
        if choice == "0":
            print("\n  Goodbye.\n"); break
        elif choice in MENU and MENU[choice][1]:
            MENU[choice][1]()
        else:
            print("  Invalid. Try again.")


def main():
    parser = argparse.ArgumentParser(
        description="Healthcare Analytics Reporting Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""\
            Examples:
              python report.py                      # interactive menu
              python report.py --report hospitals   # hospital ranking
              python report.py --report all         # all reports
        """),
    )
    parser.add_argument("--report", "-r", choices=list(CLI_MAP.keys()))
    args = parser.parse_args()

    if args.report:
        get_conn()
        CLI_MAP[args.report]()
    else:
        interactive_menu()


if __name__ == "__main__":
    main()