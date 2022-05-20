#!/bin/bash -x

snakemake --profile slurm --use-conda --conda-frontend mamba --latency-wait 120 --configfile ../config/config.yaml