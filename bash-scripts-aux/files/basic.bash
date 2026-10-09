# Basic bash configuration for scripts.

# Copyright 2020-2023 Einhard Leichtfuß


###################################
## Error and termination handling

## What to consider as an error.

# Undefined variables are errors.
set -o nounset

# No `pipefail` (default).
#  - Enabling this might, in particular, cause unexpected issues in `if`
#    statements.
#  - Enable in a subshell whereever necessary.


## How to act on error.

# Trap ERR.
#  - Print something like a stack trace, and exit.
#  - Note: Unfortunately, on_error() is called twice when an error occurs
#    inside a command substitution or a subshell (i.a.?).
#    - This is not the case for functions.
#    - For subshell and command substitution, this could be "fixed" by not
#      exiting from on_error() and instead relying on `errexit` and
#      `inherit_errexit`.
#      - However, this does not work for functions.
#    - I do not know how to fix this (TODO).
function on_error()
{
  local -i i
  local -a args=()
  for (( i=1; i < ${#BASH_SOURCE[@]}; i++ ))
  do
    args+=( "${BASH_SOURCE[$i]} ${BASH_LINENO[${i}-1]} ${FUNCNAME[$i]}" )
  done
  printf 'FAILED: %s\n' "${args[@]}" >&2
  exit 1
}
trap 'on_error' ERR

# Inherit traps on ERR.
set -o errtrace

# If we didn't trap ERR (and exit in on_error()), we'd likely want the below.
#  - Note: `inherit_errexit` is similar to `errtrace`.
#set -o errexit
#shopt -s inherit_errexit


## How to act on exit.

# Trap EXIT.
#  - To be redefined if desired.
function on_exit()
{
  : NOP
}
trap 'on_exit' EXIT



########################
## Other shell options

# Disable globbing; set good defaults for when temporarily enabled.
#  - `extglob` has an effect regardless.
set -o noglob
shopt -s nullglob dotglob globasciiranges globstar extglob globskipdots

# Print an error message upon `shift`-ing "too far" (causes ERR regardless).
shopt -s shift_verbose

# Expand associative array subscripts only once.
shopt -s assoc_expand_once

# Do not let `source' use PATH.
shopt -u sourcepath



##################
## Other options

# Explicitly set the expected default umask.
umask 022
