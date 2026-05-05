#!/bin/bash
# ============================================================
#  Firefox Policy Applicator (Linux)
#  Supports: system (apt/dnf/pacman) and Flatpak installs
# ============================================================

set -euo pipefail

POLICY_CONTENT='{
  "policies": {
    "DisableTelemetry": true,
    "NetworkPrediction": false,
    "DNSOverHTTPS": {
      "Enabled": true,
      "ProviderURL": "https://dns.quad9.net/dns-query",
      "Locked": true
    },
    "EnableTrackingProtection": {
      "Value": true,
      "Locked": true,
      "Cryptomining": true,
      "Fingerprinting": true,
      "EmailTracking": true,
      "Category": "strict"
    },
    "Cookies": {
      "Behavior": "reject-tracker-and-partition-foreign",
      "Locked": true
    },
    "TranslateEnabled": false,
    "SearchSuggestEnabled": false,
    "PasswordManagerEnabled": false,
    "AutofillAddressEnabled": true,
    "AutofillCreditCardEnabled": false,
    "OfferToSaveLogins": false,
    "PopupBlocking": {
      "Default": "block",
      "Locked": true
    },
    "Permissions": {
      "Location": {
        "BlockNewRequests": true,
        "Locked": true
      },
      "Notifications": {
        "BlockNewRequests": true,
        "Locked": true
      }
    },
    "AlternateErrorPages": false,
    "NewTabPage": false,
    "Homepage": {
      "StartPage": "none"
    },
    "SearchEngines": {
      "Default": "Google",
      "PreventInstalls": true
    },
    "ExtensionSettings": {
      "*": {
        "installation_mode": "blocked"
      }
    },
    "UserMessaging": {
      "ExtensionRecommendations": false,
      "FeatureRecommendations": false,
      "UrlbarInterventions": false,
      "MoreFromMozilla": false
    }
  }
}'

# ---- Detection -------------------------------------------------------

detect_firefox() {
    # Check Flatpak first (user and system)
    if flatpak list 2>/dev/null | grep -q "org.mozilla.firefox"; then
        # Check system-wide flatpak install first
        local sys_path="/var/lib/flatpak/app/org.mozilla.firefox/current/active/files/lib/firefox/distribution"
        local user_path="$HOME/.var/app/org.mozilla.firefox/config/firefox/policies"
        if flatpak list --system 2>/dev/null | grep -q "org.mozilla.firefox"; then
            echo "flatpak-system:$sys_path"
        else
            echo "flatpak-user:$user_path"
        fi
        return
    fi

    # Check snap
    if snap list 2>/dev/null | grep -q "^firefox "; then
        echo "snap:/var/snap/firefox/common/policies"
        return
    fi

    # Check native system install (common binary names)
    for bin in firefox firefox-esr firefox-bin; do
        if command -v "$bin" >/dev/null 2>&1; then
            echo "system:/etc/firefox/policies"
            return
        fi
    done

    echo "not_found"
}

# ---- Main ------------------------------------------------------------

main() {
    local detection
    detection=$(detect_firefox)

    if [[ "$detection" == "not_found" ]]; then
        echo "[✗] Firefox not found (checked Flatpak, Snap, and system PATH)."
        exit 1
    fi

    local install_type policy_dir
    install_type="${detection%%:*}"
    policy_dir="${detection#*:}"

    echo "[i] Detected install type : $install_type"
    echo "[i] Policy directory      : $policy_dir"

    # Create directory
    case "$install_type" in
        system|snap|flatpak-system)
            sudo mkdir -p "$policy_dir"
            ;;
        flatpak-user)
            mkdir -p "$policy_dir"
            ;;
    esac

    # Write policy file
    local policy_file="$policy_dir/policies.json"
    local tmp
    tmp=$(mktemp)
    echo "$POLICY_CONTENT" > "$tmp"

    case "$install_type" in
        system|snap|flatpak-system)
            sudo cp "$tmp" "$policy_file"
            sudo chmod 644 "$policy_file"
            ;;
        flatpak-user)
            cp "$tmp" "$policy_file"
            chmod 644 "$policy_file"
            ;;
    esac

    rm -f "$tmp"
    echo "[✓] Firefox policies applied to: $policy_file"
    echo "[i] Please restart Firefox for changes to take effect."
}

main "$@"
