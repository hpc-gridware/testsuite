# `as-root` — run a command as root on a lab host

```
as-root <host> <command> [argument...]
```

The password comes from the same source the testsuite uses, `get_pwd.sh` backed
by the GPG wallet. It is never printed and never written to disk.

Meant for the few places where a setup genuinely needs root — mirroring
setuid-root binaries between installations, for instance. For everything else the
rule stands: do not work as root.

## Exit status

| Code | Meaning |
|---|---|
| 2 | wrong number of arguments |
| 3 | password not available — usually a cold gpg-agent cache: `gpg --batch` does not prompt, it fails. Call `get_pwd.sh` once interactively. |
| 4 | root login refused on that host |
| else | the exit status of the remote command |

## Environment

| Variable | Meaning |
|---|---|
| `GCS_PW_COMMAND` | Use a different helper instead of the bundled one. Contract: print the password on stdout, nothing else. |
| `GCS_ROOT_PW_FILE` | A different wallet location for the bundled helper, default `~/.config/gcs/ts-root-pw.gpg`. |

## Notes

The gpg-agent is bound to its host — its socket lives under
`/run/user/<uid>/gnupg` — and the cache has to be warm. A batch job on a host
other than the agent's will therefore fail, no matter that the home directory is
shared.

Verified to work without a controlling terminal, without `GPG_TTY`, with stdin
closed and even under `env -i`: gpg locates the agent socket via the uid, not via
the environment.

## See also

[`gcs-runners`](gcs-runners.md) · [`gcs-pipeline`](gcs-pipeline.md)
