#!/bin/bash
# ============================================================
#  Browser Policy Removal Script (Linux)
#  Usage: ./remove_browser_policies.sh <brave|chrome|edge|firefox>
# ============================================================

set -euo pipefail

usage() {
    echo "Usage: $0 <brave|chrome|edge|firefox>"
    echo ""
    echo "  brave    — Remove Brave Browser policies"
    echo "  chrome   — Remove Google Chrome policies"
    echo "  edge     — Remove Microsoft Edge policies"
    echo "  firefox  — Remove Firefox policies"
    exit 1
}

# ---- Detection helpers -----------------------------------------------

detect_brave() {
    if flatpak list --system 2>/dev/null | grep -q "com.brave.Browser"; then
        echo "flatpak-system:/var/lib/flatpak/app/com.brave.Browser/current/active/files/extra/brave/policies/managed"
    elif flatpak list --user 2>/dev/null | grep -q "com.brave.Browser"; then
        echo "flatpak-user:$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser/policies/managed"
    else
        for bin in brave-browser brave brave-browser-stable; do
            if command -v "$bin" >/dev/null 2>&1; then
                echo "system:/etc/brave/policies/managed"; return
            fi
        done
        echo "not_found"
    fi
}

detect_chrome() {
    if flatpak list --system 2>/dev/null | grep -q "com.google.Chrome"; then
        echo "flatpak-system:/var/lib/flatpak/app/com.google.Chrome/current/active/files/extra/chrome/policies/managed"
    elif flatpak list --user 2>/dev/null | grep -q "com.google.Chrome"; then
        echo "flatpak-user:$HOME/.var/app/com.google.Chrome/config/google-chrome/policies/managed"
    else
        for bin in google-chrome google-chrome-stable google-chrome-beta; do
            if command -v "$bin" >/dev/null 2>&1; then
                echo "system:/etc/opt/google/chrome/policies/managed"; return
            fi
        done
        echo "not_found"
    fi
}

detect_edge() {
    if flatpak list --system 2>/dev/null | grep -q "com.microsoft.Edge"; then
        echo "flatpak-system:/var/lib/flatpak/app/com.microsoft.Edge/current/active/files/extra/edge/policies/managed"
    elif flatpak list --user 2>/dev/null | grep -q "com.microsoft.Edge"; then
        echo "flatpak-user:$HOME/.var/app/com.microsoft.Edge/config/microsoft-edge/policies/managed"
    else
        for bin in microsoft-edge microsoft-edge-stable microsoft-edge-beta; do
            if command -v "$bin" >/dev/null 2>&1; then
                echo "system:/etc/opt/microsoft/edge/policies/managed"; return
            fi
        done
        echo "not_found"
    fi
}

detect_firefox() {
    if flatpak list --system 2>/dev/null | grep -q "org.mozilla.firefox"; then
        echo "flatpak-system:/var/lib/flatpak/app/org.mozilla.firefox/current/active/files/lib/firefox/distribution"
    elif flatpak list --user 2>/dev/null | grep -q "org.mozilla.firefox"; then
        echo "flatpak-user:$HOME/.var/app/org.mozilla.firefox/config/firefox/policies"
    elif snap list 2>/dev/null | grep -q "^firefox "; then
        echo "snap:/var/snap/firefox/common/policies"
    else
        for bin in firefox firefox-esr firefox-bin; do
            if command -v "$bin" >/dev/null 2>&1; then
                echo "system:/etc/firefox/policies"; return
            fi
        done
        echo "not_found"
    fi
}

# ---- Remove policy file(s) in a directory ----------------------------

remove_policies() {
    local install_type="$1"
    local policy_dir="$2"
    local browser="$3"

    if [[ ! -d "$policy_dir" ]]; then
        echo "[i] Policy directory does not exist, nothing to remove: $policy_dir"
        return
    fi

    echo "[i] Scanning: $policy_dir"

    # Determine the expected filename pattern for this browser
    local pattern
    case "$browser" in
        firefox) pattern="policies.json" ;;
        brave)   pattern="brave_policies.json" ;;
        chrome)  pattern="chrome_policies.json" ;;
        edge)    pattern="edge_policies.json" ;;
    esac

    local target="$policy_dir/$pattern"

    if [[ ! -f "$target" ]]; then
        echo "[i] No policy file found at: $target"
        return
    fi

    case "$install_type" in
        system|snap|flatpak-system)
            sudo rm -f "$target"
            ;;
        flatpak-user)
            rm -f "$target"
            ;;
    esac

    echo "[✓] Removed: $target"

    # Optionally clean up an empty managed dir (non-destructive)
    if [[ -d "$policy_dir" ]] && [[ -z "$(ls -A "$policy_dir" 2>/dev/null)" ]]; then
        case "$install_type" in
            system|snap|flatpak-system) sudo rmdir "$policy_dir" 2>/dev/null || true ;;
            flatpak-user)               rmdir "$policy_dir" 2>/dev/null || true ;;
        esac
        echo "[i] Removed empty directory: $policy_dir"
    fi
}

# ---- Main ------------------------------------------------------------

main() {
    if [[ $# -lt 1 ]]; then
        usage
    fi

    local browser="${1,,}"   # lowercase

    local detection
    case "$browser" in
        brave)   detection=$(detect_brave)   ;;
        chrome)  detection=$(detect_chrome)  ;;
        edge)    detection=$(detect_edge)    ;;
        firefox) detection=$(detect_firefox) ;;
        *)       echo "[!] Unknown browser: $1"; usage ;;
    esac

    if [[ "$detection" == "not_found" ]]; then
        echo "[!] $browser not found. Cannot determine policy location."
        exit 1
    fi

    local install_type policy_dir
    install_type="${detection%%:*}"
    policy_dir="${detection#*:}"

    echo "============================================================"
    echo " Removing $browser policies"
    echo "============================================================"
    echo "[i] Install type : $install_type"
    echo "[i] Policy dir   : $policy_dir"

    remove_policies "$install_type" "$policy_dir" "$browser"

    echo ""
    echo "[✓] Done. Please restart the browser for changes to take effect."
}

main "$@"
