#!/bin/bash
# =============================================================================
#  Author : z1rov  |  zirov.xyz  |  OSCP
# =============================================================================

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

L_INFO="${CYAN}[INFO]${RESET} "
L_OK="${GREEN}[OK]${RESET}   "
L_WARN="${YELLOW}[WARN]${RESET} "
L_ERR="${RED}[ERROR]${RESET}"

# ── Tracking arrays ───────────────────────────────────────────────────────────
INSTALLED_TOOLS=()
FAILED_TOOLS=()
DEPLOYED_DIRS=()
FAILED_DIRS=()
WRITTEN_ALIASES=()
INSTALLED_BINS=()
FAILED_BINS=()

# ── Banner ────────────────────────────────────────────────────────────────────
print_banner() {
    echo -e "${RED}${BOLD}"
    echo -e "  ⣇⣿⠘⣿⣿⣿⡿⡿⣟⣟⢟⢟⢝⠵⡝⣿⡿⢂⣼⣿⣷⣌⠩⡫⡻⣝⠹⢿⣿⣷"
    echo -e "  ⡆⣿⣆⠱⣝⡵⣝⢅⠙⣿⢕⢕⢕⢕⢝⣥⢒⠅⣿⣿⣿⡿⣳⣌⠪⡪⣡⢑⢝⣇"
    echo -e "  ⡆⣿⣿⣦⠹⣳⣳⣕⢅⠈⢗⢕⢕⢕⢕⢕⢈⢆⠟⠋⠉⠁⠉⠉⠁⠈⠼⢐⢕⢽"
    echo -e "  ⡗⢰⣶⣶⣦⣝⢝⢕⢕⠅⡆⢕⢕⢕⢕⢕⣴⠏⣠⡶⠛⡉⡉⡛⢶⣦⡀⠐⣕⢕"
    echo -e "  ⡝⡄⢻⢟⣿⣿⣷⣕⣕⣅⣿⣔⣕⣵⣵⣿⣿⢠⣿⢠⣮⡈⣌⠨⠅⠹⣷⡀⢱⢕"
    echo -e "  ⡝⡵⠟⠈⢀⣀⣀⡀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣼⣿⢈⡋⠴⢿⡟⣡⡇⣿⡇⡀⢕"
    echo -e "  ⡝⠁⣠⣾⠟⡉⡉⡉⠻⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣿⣦⣥⣿⡇⡿⣰⢗⢄"
    echo -e "  ⠁⢰⣿⡏⣴⣌⠈⣌⠡⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣉⣉⣁⣄⢖⢕⢕⢕"
    echo -e "  ⡀⢻⣿⡇⢙⠁⠴⢿⡟⣡⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣵⣵⣿"
    echo -e "  ⡻⣄⣻⣿⣌⠘⢿⣷⣥⣿⠇⣿⣿⣿⣿⣿⣿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
    echo -e "  ⣷⢄⠻⣿⣟⠿⠦⠍⠉⣡⣾⣿⣿⣿⣿⣿⣿⢸⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿⠟"
    echo -e "  ⡕⡑⣑⣈⣻⢗⢟⢞⢝⣻⣿⣿⣿⣿⣿⣿⣿⠸⣿⠿⠃⣿⣿⣿⣿⣿⣿⡿⠁⣠"
    echo -e "  ⡝⡵⡈⢟⢕⢕⢕⢕⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⠿⠋⣀⣈⠙"
    echo -e "  ⡝⡵⡕⡀⠑⠳⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⢉⡠⡲⡫⡪⡪⡣"
    echo -e "${RESET}"
    echo -e "${GRAY}  ────────────────────────────────────────────────────────────${RESET}"
    echo -e "  ${BOLD}Author: ${RESET} Zirov  ${CYAN}https://zirov.xyz${RESET}"
    echo -e "  ${BOLD}OSCP${RESET}"
    echo -e "${GRAY}  ────────────────────────────────────────────────────────────${RESET}"
    echo ""
}

log() {
    local level="$1"; shift
    local msg="$*"
    case "$level" in
        info) echo -e "  $L_INFO $msg" ;;
        ok)   echo -e "  $L_OK $msg" ;;
        warn) echo -e "  $L_WARN $msg" ;;
        err)
            echo -e "  $L_ERR $msg"
            echo ""
            exit 1
            ;;
    esac
    echo ""
}

require_root() {
    [[ $EUID -ne 0 ]] && log err "Run as root:  sudo ./setup.sh"
}

detect_shell_rc() {
    if [[ -n "$SUDO_USER" ]]; then
        USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        USER_SHELL=$(getent passwd "$SUDO_USER" | cut -d: -f7)
    else
        USER_HOME="$HOME"
        USER_SHELL="$SHELL"
    fi
    case "$USER_SHELL" in
        */zsh)  SHELL_RC="$USER_HOME/.zshrc" ;;
        *)      SHELL_RC="$USER_HOME/.bashrc" ;;
    esac
}

# ── 1. Update ─────────────────────────────────────────────────────────────────
update_system() {
    log info "Updating system packages..."
    pacman -Syu --noconfirm &>/dev/null
    log ok "System updated"
}

# ── 2. Python ─────────────────────────────────────────────────────────────────
install_python() {
    log info "Installing Python 3..."
    if pacman -S --noconfirm python python-pip &>/dev/null; then
        INSTALLED_TOOLS+=("python3")
    else
        FAILED_TOOLS+=("python3")
    fi

    log info "Installing Python 2..."
    if pacman -S --noconfirm python2 &>/dev/null; then
        INSTALLED_TOOLS+=("python2")
        if ! command -v pip2 &>/dev/null; then
            curl -sS https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip2.py
            python2 /tmp/get-pip2.py &>/dev/null && INSTALLED_TOOLS+=("pip2")
        fi
    else
        FAILED_TOOLS+=("python2")
    fi

    log ok "Python step done"
}

# ── 3. Tools ──────────────────────────────────────────────────────────────────
install_tools() {
    TOOLS=(nmap hashcat ffuf feroxbuster git wget curl unzip)
    for tool in "${TOOLS[@]}"; do
        log info "Installing $tool..."
        if pacman -S --noconfirm "$tool" &>/dev/null; then
            INSTALLED_TOOLS+=("$tool")
        else
            FAILED_TOOLS+=("$tool")
        fi
    done
    log ok "Pentest tools step done"
}

# ── helper: track deployed dir ────────────────────────────────────────────────
deploy_dir() {
    local src="$1"
    local dst="$2"
    local label="$3"
    mkdir -p "$dst"
    if [[ -d "$src" ]]; then
        cp -r "$src/." "$dst/"
        DEPLOYED_DIRS+=("$dst")
    elif [[ -f "$src" ]]; then
        cp "$src" "$dst/"
        DEPLOYED_DIRS+=("$dst")
    else
        FAILED_DIRS+=("$label")
    fi
}

# ── 4. Custom repos ───────────────────────────────────────────────────────────
setup_custom_tools() {
    log info "Cloning z1rov/pivoting-tools..."
    TMP_PIVOT="/tmp/pivoting-tools-clone"
    rm -rf "$TMP_PIVOT"
    if git clone -q https://github.com/z1rov/pivoting-tools "$TMP_PIVOT"; then
        while IFS= read -r -d '' tool_dir; do
            dname=$(basename "$tool_dir")
            [[ "$dname" == .* ]] && continue
            dst="/usr/share/$dname"
            mkdir -p "$dst"
            cp -r "$tool_dir/." "$dst/"
            DEPLOYED_DIRS+=("$dst")
        done < <(find "$TMP_PIVOT" -mindepth 1 -maxdepth 1 -type d -print0)
        rm -rf "$TMP_PIVOT"
        log ok "pivoting-tools deployed"
    else
        log warn "Failed to clone pivoting-tools"
    fi

    log info "Cloning z1rov/active-directory-tools..."
    TMP_AD="/tmp/active-directory-tools-clone"
    rm -rf "$TMP_AD"
    if git clone -q https://github.com/z1rov/active-directory-tools "$TMP_AD"; then
        # Dynamic: iterate every folder in the repo, copy as-is to /usr/share/
        while IFS= read -r -d '' tool_dir; do
            dname=$(basename "$tool_dir")
            [[ "$dname" == .* ]] && continue
            dst="/usr/share/$dname"
            mkdir -p "$dst"
            cp -r "$tool_dir/." "$dst/"
            DEPLOYED_DIRS+=("$dst")
        done < <(find "$TMP_AD" -mindepth 1 -maxdepth 1 -type d -print0)
        rm -rf "$TMP_AD"
        log ok "active-directory-tools deployed"
    else
        log warn "Failed to clone active-directory-tools"
    fi
}

# ── 5. z1rov/tools → /usr/local/bin ──────────────────────────────────────────
setup_bin_tools() {
    log info "Cloning z1rov/tools..."
    TMP_TOOLS="/tmp/z1rov-tools-clone"
    rm -rf "$TMP_TOOLS"

    if git clone -q https://github.com/z1rov/tools "$TMP_TOOLS"; then
        # Walk every file in the repo root (skip .git and dirs)
        while IFS= read -r -d '' bin; do
            bname=$(basename "$bin")
            # Skip hidden files, README, LICENSE and non-files
            [[ "$bname" == .* || "$bname" == README* || "$bname" == LICENSE* ]] && continue
            [[ ! -f "$bin" ]] && continue

            dest="/usr/local/bin/$bname"
            if cp "$bin" "$dest" && chmod +x "$dest"; then
                INSTALLED_BINS+=("$bname")
            else
                FAILED_BINS+=("$bname")
            fi
        done < <(find "$TMP_TOOLS" -maxdepth 1 -print0)

        rm -rf "$TMP_TOOLS"
        log ok "z1rov/tools installed to /usr/local/bin"
    else
        log warn "Failed to clone z1rov/tools"
        FAILED_BINS+=("extract" "mke")
    fi
}

# ── 6. Wordlists ──────────────────────────────────────────────────────────────
setup_wordlists() {
    WDIR="/usr/share/wordlists"
    mkdir -p "$WDIR"

    log info "Cloning SecLists..."
    if [[ -d /usr/share/seclists/.git ]]; then
        git -C /usr/share/seclists pull -q
        DEPLOYED_DIRS+=("/usr/share/seclists")
    elif git clone -q --depth 1 https://github.com/danielmiessler/SecLists /usr/share/seclists; then
        DEPLOYED_DIRS+=("/usr/share/seclists")
    else
        FAILED_DIRS+=("seclists")
    fi
    log ok "SecLists step done"

    log info "Cloning z1rov/wordlists..."
    TMP_WL="/tmp/z1rov-wordlists"
    rm -rf "$TMP_WL"
    if git clone -q https://github.com/z1rov/wordlists "$TMP_WL"; then
        for file in "$TMP_WL"/*; do
            fname=$(basename "$file")
            [[ "$fname" == README* || "$fname" == .* ]] && continue
            case "$fname" in
                *.zip)
                    dest_name="${fname%.zip}"
                    mkdir -p "$WDIR/$dest_name"
                    unzip -o "$file" -d "$WDIR/$dest_name/" &>/dev/null
                    nested=$(find "$WDIR/$dest_name" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
                    if [[ $(echo "$nested" | grep -c .) -eq 1 ]] && \
                       [[ -z "$(find "$WDIR/$dest_name" -mindepth 1 -maxdepth 1 -type f 2>/dev/null)" ]]; then
                        mv "$nested"/* "$WDIR/$dest_name/" 2>/dev/null || true
                        rmdir "$nested" 2>/dev/null || true
                    fi
                    ;;
                *.tar.gz|*.tgz)
                    dest_name="${fname%.tar.gz}"; dest_name="${dest_name%.tgz}"
                    mkdir -p "$WDIR/$dest_name"
                    tar -xzf "$file" -C "$WDIR/$dest_name/" &>/dev/null
                    ;;
                *.gz)
                    dest_name="${fname%.gz}"
                    gunzip -c "$file" > "$WDIR/$dest_name" 2>/dev/null
                    [[ -d "$WDIR/$dest_name" ]] && rm -rf "$WDIR/$dest_name"
                    ;;
                *)
                    cp "$file" "$WDIR/" 2>/dev/null
                    ;;
            esac
        done

        if [[ -d "$WDIR/rockyou.txt" ]]; then
            INNER=$(find "$WDIR/rockyou.txt" -type f | head -1)
            if [[ -n "$INNER" ]]; then
                mv "$INNER" "$WDIR/rockyou.txt.tmp"
                rm -rf "$WDIR/rockyou.txt"
                mv "$WDIR/rockyou.txt.tmp" "$WDIR/rockyou.txt"
            fi
        fi

        rm -rf "$TMP_WL"
        DEPLOYED_DIRS+=("/usr/share/wordlists")
        log ok "Wordlists ready"
    else
        FAILED_DIRS+=("wordlists")
        log warn "Failed to clone z1rov/wordlists"
    fi
}

# ── 7. Aliases ────────────────────────────────────────────────────────────────
setup_aliases() {
    log info "Writing aliases to $SHELL_RC..."

    MARKER="# ── z1rov pentest aliases ──"
    grep -q "$MARKER" "$SHELL_RC" 2>/dev/null && \
        sed -i "/$MARKER/,/# ── end z1rov aliases ──/d" "$SHELL_RC"

    # Fixed aliases only for wordlists (everything else is dynamic)
    declare -A FIXED_ALIASES=(
        ["/usr/share/wordlists"]="wordlists"
        ["/usr/share/seclists"]="seclists"
    )

    {
        echo ""
        echo "# ── z1rov pentest aliases ──"

        # Fixed aliases (pivoting + wordlists)
        for dir in "${!FIXED_ALIASES[@]}"; do
            alias_name="${FIXED_ALIASES[$dir]}"
            if [[ -d "$dir" ]]; then
                echo "alias ${alias_name}='cd ${dir} && ls'"
                WRITTEN_ALIASES+=("${alias_name} → ${dir}")
            fi
        done

        # Dynamic aliases: every deployed directory
        for deployed in "${DEPLOYED_DIRS[@]}"; do
            [[ "${FIXED_ALIASES[$deployed]+_}" ]] && continue
            [[ ! -d "$deployed" ]] && continue

            alias_name=$(basename "$deployed" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
            echo "alias ${alias_name}='cd ${deployed} && ls'"
            WRITTEN_ALIASES+=("${alias_name} → ${deployed}")
        done

        echo "# ── end z1rov aliases ──"
    } >> "$SHELL_RC"

    [[ -n "$SUDO_USER" ]] && chown "$SUDO_USER":"$SUDO_USER" "$SHELL_RC"
    log ok "Aliases written"
}

# ── 8. Dynamic summary ────────────────────────────────────────────────────────
print_summary() {
    echo -e "${GREEN}${BOLD}  Installation complete${RESET}"
    echo ""

    if [[ ${#INSTALLED_TOOLS[@]} -gt 0 ]]; then
        echo -e "${GREEN}  [OK]   Installed tools${RESET}"
        for t in "${INSTALLED_TOOLS[@]}"; do
            echo -e "         ${GRAY}·${RESET} $t"
        done
        echo ""
    fi

    if [[ ${#FAILED_TOOLS[@]} -gt 0 ]]; then
        echo -e "${RED}  [FAIL] Failed tools${RESET}"
        for t in "${FAILED_TOOLS[@]}"; do
            echo -e "         ${GRAY}·${RESET} $t"
        done
        echo ""
    fi

    if [[ ${#INSTALLED_BINS[@]} -gt 0 ]]; then
        echo -e "${GREEN}  [OK]   Installed to /usr/local/bin${RESET}"
        for b in "${INSTALLED_BINS[@]}"; do
            echo -e "         ${GRAY}·${RESET} $b"
        done
        echo ""
    fi

    if [[ ${#FAILED_BINS[@]} -gt 0 ]]; then
        echo -e "${RED}  [FAIL] Failed binaries${RESET}"
        for b in "${FAILED_BINS[@]}"; do
            echo -e "         ${GRAY}·${RESET} $b"
        done
        echo ""
    fi

    if [[ ${#DEPLOYED_DIRS[@]} -gt 0 ]]; then
        mapfile -t DEPLOYED_DIRS < <(printf '%s\n' "${DEPLOYED_DIRS[@]}" | sort -u)
        echo -e "${CYAN}  [OK]   Deployed directories${RESET}"
        for d in "${DEPLOYED_DIRS[@]}"; do
            echo -e "         ${GRAY}·${RESET} $d"
        done
        echo ""
    fi

    if [[ ${#FAILED_DIRS[@]} -gt 0 ]]; then
        mapfile -t FAILED_DIRS < <(printf '%s\n' "${FAILED_DIRS[@]}" | sort -u)
        echo -e "${RED}  [FAIL] Failed directories${RESET}"
        for d in "${FAILED_DIRS[@]}"; do
            echo -e "         ${GRAY}·${RESET} $d"
        done
        echo ""
    fi

    if [[ ${#WRITTEN_ALIASES[@]} -gt 0 ]]; then
        echo -e "${CYAN}  [OK]   Aliases → ${SHELL_RC}${RESET}"
        for a in "${WRITTEN_ALIASES[@]}"; do
            echo -e "         ${GRAY}·${RESET} $a"
        done
        echo ""
    fi

    echo -e "${YELLOW}  Reload:${RESET}  source $SHELL_RC"
    echo ""
}

# ── MAIN ──────────────────────────────────────────────────────────────────────
main() {
    print_banner
    require_root
    detect_shell_rc
    update_system
    install_python
    install_tools
    setup_custom_tools
    setup_bin_tools
    setup_wordlists
    setup_aliases
    print_summary
}

main "$@"
