#!/bin/sh
#
# Epilog for the CS-849 dbwriter mixed-type test. Emits a mix of numeric
# and string custom usage values through the shepherd usage file so the
# full pipeline (execd -> qmaster -> JSONL -> dbwriter) is exercised for
# both types. Values chosen to exercise the discrimination rule
# (usage_parse_value in source/libs/sgeobj/sge_usage.cc) including its
# quote-prefix, bool, and raw-string arms.
#
# SGE_JOB_SPOOL_DIR is set by the shepherd for prolog / epilog execution.

# --- AE2: canonical mixed pair (string + number) ---
echo "instance_type=\"A100\"" >> "$SGE_JOB_SPOOL_DIR/usage"
echo "energy=6915" >> "$SGE_JOB_SPOOL_DIR/usage"

# --- AE3: quoted-numeric-looking string (stays string, not 42) ---
echo "label_007=\"42\"" >> "$SGE_JOB_SPOOL_DIR/usage"

# --- AE3: bool coercion (case-insensitive) ---
echo "flag_ready=true" >> "$SGE_JOB_SPOOL_DIR/usage"

# --- AE3: plain string ---
echo "status=running" >> "$SGE_JOB_SPOOL_DIR/usage"

# note: empty-quoted-pair values ("") are silently skipped by
# usage_parse_value because CULL's wire format cannot distinguish empty
# string from nullptr (see sge_usage.cc). Not exercised here.

exit 0
