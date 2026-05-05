#!/bin/bash
# ============================================================
#  Brave Browser Policy Applicator (Linux)
#  Supports: system (apt/dnf/pacman) and Flatpak installs
# ============================================================

set -euo pipefail

POLICY_CONTENT='{
  "ExtensionInstallBlocklist": ["*"],
  "BraveP3AEnabled": false,
  "BraveStatsPingEnabled": false,
  "BraveWebDiscoveryEnabled": false,
  "BraveNewsDisabled": true,
  "BraveWaybackMachineEnabled": false,
  "BraveAIChatEnabled": false,
  "BraveRewardsDisabled": true,
  "BraveWalletDisabled": true,
  "BraveTalkDisabled": true,
  "BraveVPNDisabled": true,
  "TorDisabled": true,
  "BraveSpeedreaderEnabled": false,
  "BravePlaylistEnabled": false,
  "ShowSidebarButtonEnabled": false,
  "SyncDisabled": false,
  "SafeBrowsingProtectionLevel": 2,
  "BlockThirdPartyCookies": true,
  "DefaultNotificationsSetting": 2,
  "DefaultGeolocationSetting": 2,
  "DefaultPopupsSetting": 2,
  "PasswordManagerEnabled": false,
  "AutofillAddressEnabled": true,
  "AutofillCreditCardEnabled": false,
  "SearchSuggestEnabled": false,
  "AlternateErrorPagesEnabled": false,
  "TranslateEnabled": false,
  "NetworkPredictionOptions": 2,
  "DefaultSearchProviderEnabled": true,
  "DefaultSearchProviderName": "Google",
  "DefaultSearchProviderSearchURL": "https://www.google.com/search?q={searchTerms}",
  "DefaultSearchProviderSuggestURL": "https://www.google.com/complete/search?q={searchTerms}",
  "DefaultSearchProviderNewTabURL": "https://www.google.com/",
  "BuiltInDnsClientEnabled": true,
  "DnsOverHttpsMode": "secure",
  "DnsOverHttpsTemplates"="https://dns.quad9.net/dns-query{?dns} https://cloudflare-dns.com/dns-query{?dns}",
  "NewTabPageContentEnabled": false,
  "NewTabPageHideDefaultTopSites": true,
  "BackgroundModeEnabled": false,
  "StartupBoostEnabled": false,
  "DefaultBrowserSettingEnabled": false
}'

# ---- Detection -------------------------------------------------------

detect_brave() {
    # Flatpak (system)
    if flatpak list --system 2>/dev/null | grep -q "com.brave.Browser"; then
        echo "flatpak-system:/var/lib/flatpak/app/com.brave.Browser/current/active/files/extra/brave/policies/managed"
        return
    fi
    # Flatpak (user)
    if flatpak list --user 2>/dev/null | grep -q "com.brave.Browser"; then
        echo "flatpak-user:$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser/policies/managed"
        return
    fi
    # Native
    for bin in brave-browser brave brave-browser-stable; do
        if command -v "$bin" >/dev/null 2>&1; then
            echo "system:/etc/brave/policies/managed"
            return
        fi
    done
    echo "not_found"
}

# ---- Main ------------------------------------------------------------

main() {
    local detection
    detection=$(detect_brave)

    if [[ "$detection" == "not_found" ]]; then
        echo "[✗] Brave Browser not found (checked Flatpak and system PATH)."
        exit 1
    fi

    local install_type policy_dir
    install_type="${detection%%:*}"
    policy_dir="${detection#*:}"

    echo "[i] Detected install type : $install_type"
    echo "[i] Policy directory      : $policy_dir"

    local policy_file="$policy_dir/brave_policies.json"
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
    echo "[✓] Brave policies applied to: $policy_file"
    echo "[i] Please restart Brave for changes to take effect."
}

main "$@"
