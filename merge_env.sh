#!/bin/bash
# ============================================================
#  merge_env.sh
#  Scans every subfolder in /home/kali for .env files and
#  merges unique KEY=VALUE pairs into /home/kali/.env
#  Skips duplicates, comments, and blank lines.
# ============================================================

BASE_DIR="/home/kali"
MASTER_ENV="$BASE_DIR/.env"
BACKUP="$BASE_DIR/.env.backup.$(date +%Y%m%d_%H%M%S)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║        .ENV MERGER  — /home/kali         ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${RESET}"

# ── 1. Backup existing master .env ───────────────────────────
if [ -f "$MASTER_ENV" ]; then
    cp "$MASTER_ENV" "$BACKUP"
    echo -e "${YELLOW}[BACKUP]${RESET} Existing .env backed up → $BACKUP"
else
    echo -e "${YELLOW}[INFO]${RESET} No existing $MASTER_ENV — will create fresh."
    touch "$MASTER_ENV"
fi

# ── 2. Build a set of keys already in master .env ────────────
declare -A EXISTING_KEYS

while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip blanks and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    key="${line%%=*}"
    EXISTING_KEYS["$key"]=1
done < "$MASTER_ENV"

# ── 3. Find all .env files in subdirectories ─────────────────
FOUND=0
ADDED=0
SKIPPED=0

# Also check root-level .env files in named project folders
while IFS= read -r envfile; do

    # Skip the master .env itself
    [ "$envfile" = "$MASTER_ENV" ] && continue

    echo -e "\n${CYAN}[SCAN]${RESET} $envfile"
    FOUND=$((FOUND + 1))

    # Add a section header comment in master
    echo "" >> "$MASTER_ENV"
    echo "# ── Imported from: $envfile ──" >> "$MASTER_ENV"

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip blank lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # Must contain = to be a valid KEY=VALUE
        [[ "$line" != *=* ]] && continue

        key="${line%%=*}"
        # Trim whitespace from key
        key="$(echo "$key" | tr -d '[:space:]')"

        if [ -z "$key" ]; then
            continue
        fi

        if [ "${EXISTING_KEYS[$key]+isset}" ]; then
            echo -e "  ${YELLOW}[SKIP]${RESET}  $key  (already defined)"
            SKIPPED=$((SKIPPED + 1))
        else
            echo "$line" >> "$MASTER_ENV"
            EXISTING_KEYS["$key"]=1
            echo -e "  ${GREEN}[ADD]${RESET}   $key"
            ADDED=$((ADDED + 1))
        fi
    done < "$envfile"

done < <(find "$BASE_DIR" -mindepth 2 -maxdepth 3 -name ".env" -type f 2>/dev/null)

# ── 4. Summary ───────────────────────────────────────────────
echo -e "\n${CYAN}"
echo "══════════════════════════════════════════"
echo "  DONE"
echo "  .env files found : $FOUND"
echo "  Keys added       : $ADDED"
echo "  Keys skipped     : $SKIPPED (duplicates)"
echo "  Master .env      : $MASTER_ENV"
[ -f "$BACKUP" ] && echo "  Backup           : $BACKUP"
echo -e "══════════════════════════════════════════${RESET}"
