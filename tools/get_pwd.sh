#!/bin/bash
#
# Print the testsuite root password on stdout, nothing else.
#
# Backed by a GPG wallet each user creates for themselves -- see the README.
# --batch means gpg never prompts: with a cold agent cache it fails rather than
# blocking, which is what makes this usable from batch jobs and CI.
#
# GCS_ROOT_PW_FILE overrides the wallet location.
gpg --batch -q -d "${GCS_ROOT_PW_FILE:-$HOME/.config/gcs/ts-root-pw.gpg}"
