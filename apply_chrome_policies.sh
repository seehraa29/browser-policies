#!/bin/bash
# ============================================================
#  Google Chrome Policy Applicator (Linux)
#  Supports: system (apt/dnf) and Flatpak installs
# ============================================================

set -euo pipefail

POLICY_CONTENT='{
  "ExtensionInstallBlocklist": ["*"],
  "EnableDoNotTrack": true,
  "MetricsReportingEnabled": false,
  "SafeBrowsingProtectionLevel": 2,
  "SafeBrowsingExtendedReportingEnabled": false,
  "ShowHomeButton": true,
  "NetworkPredictionOptions": 2,
  "TranslateEnabled": false,
  "NTPContentSuggestionsEnabled": false,
  "WalletServiceEnabled": false,
  "SyncDisabled": false,
  "BlockThirdPartyCookies": true,
  "PasswordManagerEnabled": false,
  "AutofillAddressEnabled": true,
  "AutofillCreditCardEnabled": false,
  "DefaultSearchProviderEnabled": true,
  "DefaultSearchProviderName": "Google",
  "DefaultSearchProviderSearchURL": "https://www.google.com/search?q={searchTerms}",
  "DefaultSearchProviderSuggestURL": "https://www.google.com/complete/search?q={searchTerms}",
  "DefaultSearchProviderNewTabURL": "https://www.google.com/",
  "DnsOverHttpsMode": "secure",
  "DnsOverHttpsTemplates"="https://dns.quad9.net/dns-query{?dns} https://cloudflare-dns.com/dns-query{?dns}",
  "BackgroundModeEnabled": false,
  "StartupBoostEnabled": false,
  "DefaultBrowserSettingEnabled": false,
  "AlternateErrorPagesEnabled": false,
  "SearchSuggestEnabled": false
}'

# ---- Detection -------------------------------------------------------

detect_chrome() {
    # Flatpak (system)
    if flatpak list --system 2>/dev/null | grep -q "com.google.Chrome"; then
        echo "flatpak-system:/var/lib/flatpak/app/com.google.Chrome/current/active/files/extra/chrome/policies/managed"
        return
    fi
    # Flatpak (user)
    if flatpak list --user 2>/dev/null | grep -q "com.google.Chrome"; then
        echo "flatpak-user:$HOME/.var/app/com.google.Chrome/config/google-chrome/policies/managed"
        return
    fi
    # Native
    for bin in google-chrome google-chrome-stable google-chrome-beta; do
        if command -v "$bin" >/dev/null 2>&1; then
            echo "system:/etc/opt/google/chrome/policies/managed"
            return
        fi
    done
    echo "not_found"
}

# ---- Main ------------------------------------------------------------

main() {
    local detection
    detection=$(detect_chrome)

    if [[ "$detection" == "not_found" ]]; then
        echo "[✗] Google Chrome not found (checked Flatpak and system PATH)."
        exit 1
    fi

    local install_type policy_dir
    install_type="${detection%%:*}"
    policy_dir="${detection#*:}"

    echo "[i] Detected install type : $install_type"
    echo "[i] Policy directory      : $policy_dir"

    local policy_file="$policy_dir/chrome_policies.json"
    local tmp
    tmp=$(mktemp)
    echo "$POLICY_CONTENT" > "$tmp"

    case "$install_type" in
        system|flatpak-system)
            sudo mkdir -p "$policy_dir"
            sudo cp "$tmp" "$policy_file"
            sudo chmod 644 "$policy_file"
            ;;
        flatpak-user)
            mkdir -p "$policy_dir"
            cp "$tmp" "$policy_file"
            chmod 644 "$policy_file"
            ;;
    esac

    rm -f "$tmp"
    echo "[✓] Chrome policies applied to: $policy_file"
    echo "[i] Please restart Chrome for changes to take effect."
}

main "$@"
