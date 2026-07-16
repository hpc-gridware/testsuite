#!/bin/sh
#
# Epilog script for the checktree_arco/dbwriter/custom_usage TCL test (CS-1266).
# Appends two custom usage values to the shepherd usage file. sge_execd
# reads these on job exit and includes them in the acct record; dbwriter's
# JSONL parser then routes them into sge_job_usage_values.
#
# SGE_JOB_SPOOL_DIR is set by the shepherd for prolog/epilog execution and
# is the per-job spool directory the shepherd is currently using.
#

echo "custom_foo=42" >> "$SGE_JOB_SPOOL_DIR/usage"
echo "custom_bar=7.5" >> "$SGE_JOB_SPOOL_DIR/usage"
exit 0
