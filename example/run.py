#!/usr/bin/env python3
from pathlib import Path

from snakebids.app import SnakeBidsApp


def main():

    app = SnakeBidsApp(Path(__file__).resolve().parent.parent)  # to get repository root
    app.run_snakemake()


if __name__ == "__main__":
    main()
