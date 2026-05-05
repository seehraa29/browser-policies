#!/bin/bash
# ============================================================
#  Microsoft Edge Policy Applicator (Linux)
#  Supports: system (apt/dnf) and Flatpak installs
# ============================================================

set -euo pipefail

POLICY_CONTENT='{
  "ExtensionInstallBlocklist": ["*"],
  "HideFirstRunExperience": 1,
  "AutoImportAtFirstRun": 4,
  "PromotionalTabsEnabled": 0,
  "GuidedSwitchEnabled": 0,
  "MicrosoftEdgeInsiderPromotionEnabled": 0,

  "ConfigureDoNotTrack": 1,
  "TrackingPrevention": 3,
  "DiagnosticData": 0,
  "PersonalizationReportingEnabled": 0,
  "Edge3PSerpTelemetryEnabled": 0,
  "ExperimentationAndConfigurationServiceControl": 0,
  "RelatedWebsiteSetsEnabled": 0,

  "DnsOverHttpsMode": "secure",
  "DnsOverHttpsTemplates"="https://dns.quad9.net/dns-query{?dns} https://cloudflare-dns.com/dns-query{?dns}",
  "BuiltInDnsClientEnabled": 0,

  "HttpsOnlyMode": "force_enabled",
  "TyposquattingCheckerEnabled": 0,
  "RemoteDebuggingAllowed": 0,
  "ResolveNavigationErrorsUseWebService": 0,
  "AlternateErrorPagesEnabled": 0,

  "PasswordManagerEnabled": 0,
  "PasswordMonitorAllowed": 0,
  "PasswordGeneratorEnabled": 0,
  "PasswordDismissCompromisedAlertEnabled": 0,
  "PasswordProtectionWarningTrigger": 0,
  "AutofillAddressEnabled": 0,
  "AutofillCreditCardEnabled": 0,
  "AutofillMembershipsEnabled": 0,
  "PaymentMethodQueryEnabled": 0,

  "DefaultSearchProviderEnabled": 1,
  "DefaultSearchProviderName": "Google Custom",
  "DefaultSearchProviderSearchURL": "https://www.google.com/search?udm=14&q={searchTerms}",
  "DefaultSearchProviderSuggestURL": "https://www.google.com/complete/search?q={searchTerms}",
  "DefaultSearchProviderNewTabURL": "https://www.google.com/",
  "NewTabPageSearchBox": "redirect",
  "SearchSuggestEnabled": 0,
  "AddressBarTrendingSuggestEnabled": 0,
  "AddressBarWorkSearchResultsEnabled": 0,
  "SearchInSidebarEnabled": 2,
  "SearchbarAllowed": 0,
  "SearchbarIsEnabledOnStartup": 0,
  "SearchFiltersEnabled": 0,
  "SearchForImageEnabled": 0,
  "QuickSearchShowMiniMenu": 0,

  "NewTabPageLocation": "https://google.co.uk",
  "NewTabPageHideDefaultTopSites": 1,
  "NewTabPageContentEnabled": 0,
  "NewTabPageAllowedBackgroundTypes": 3,
  "NewTabPageAppLauncherEnabled": 0,
  "NewTabPageBingChatEnabled": 0,
  "NewTabPagePrerenderEnabled": 0,
  "NewTabPageQuickLinksEnabled": 0,

  "BuiltInAIAPIsEnabled": 0,
  "CopilotPageContext": 0,
  "CopilotPageContextEnabled": 0,
  "EdgeEntraCopilotPageContext": 0,
  "Microsoft365CopilotChatIconEnabled": 0,
  "AIGenThemesEnabled": 0,
  "GenAILocalFoundationalModelSettings": 1,
  "ComposeInlineEnabled": 0,
  "EdgeHistoryAISearchEnabled": 0,

  "FavoritesBarEnabled": 1,
  "ShowHomeButton": 1,
  "HubsSidebarEnabled": 0,
  "StandaloneHubsSidebarEnabled": 0,
  "EdgeCollectionsEnabled": 0,
  "PinBrowserEssentialsToolbarButton": 0,
  "PinningWizardAllowed": 0,
  "SplitScreenEnabled": 0,
  "TabServicesEnabled": 0,
  "PersonalizeTopSitesInCustomizeSidebarEnabled": 0,
  "SpotlightExperiencesAndRecommendationsEnabled": 0,
  "ShowRecommendationsEnabled": 0,
  "ShowAcrobatSubscriptionButton": 0,
  "ShowPDFDefaultRecommendationsEnabled": 0,
  "ShowMicrosoftRewards": 0,
  "ShowOfficeShortcutInFavoritesBar": 0,
  "DisableScreenshots": 0,
  "AskBeforeCloseEnabled": 0,

  "ShoppingListEnabled": 0,
  "EdgeShoppingAssistantEnabled": 0,
  "EdgeWalletCheckoutEnabled": 0,
  "EdgeWalletEtreeEnabled": 0,
  "WalletDonationEnabled": 0,
  "BingAdsSuppression": 1,

  "SyncDisabled": false,
  "BrowserSignin": 1,
  "BrowserAddProfileEnabled": 0,
  "BrowserGuestModeEnabled": 0,
  "NonRemovableProfileEnabled": 0,
  "EdgeDefaultProfileEnabled": "Default",
  "RoamingProfileSupportEnabled": 0,
  "ImportOnEachLaunch": 0,
  "ImplicitSignInEnabled": 0,
  "ProactiveAuthWorkflowEnabled": 0,
  "SeamlessWebToBrowserSignInEnabled": 0,
  "WebToBrowserSignInEnabled": 0,
  "AADWebSSOAllowed": 0,
  "AADWebSiteSSOUsingThisProfileEnabled": 0,
  "MSAWebSiteSSOUsingThisProfileAllowed": 0,
  "ConfigureOnPremisesAccountAutoSignIn": 0,
  "MAMEnabled": 0,

  "DefaultNotificationsSetting": 2,
  "AllowSystemNotifications": 0,
  "AutoplayAllowed": 0,
  "LiveCaptionsAllowed": 0,
  "SpeechRecognitionEnabled": 0,
  "LiveVideoTranslationEnabled": 0,
  "UploadFromPhoneEnabled": 0,
  "LocalBrowserDataShareEnabled": 0,
  "SharedLinksEnabled": 0,

  "TranslateEnabled": 0,
  "NetworkPredictionOptions": 2,
  "AllowGamesMenu": 0,
  "ReadAloudEnabled": 0,
  "WebCaptureEnabled": 0,
  "QRCodeGeneratorEnabled": 0,
  "VisualSearchEnabled": 0,
  "WebWidgetAllowed": 0,
  "EdgeWorkspacesEnabled": 0,
  "EdgeManagementEnabled": 0,
  "EdgeAdminCenterEnabled": 0,
  "EdgeAssetDeliveryServiceEnabled": 0,
  "EdgeAutofillMlEnabled": 0,
  "EdgeEDropEnabled": 0,
  "AdsTransparencyEnabled": 0,
  "InAppSupportEnabled": 0,
  "UserFeedbackAllowed": 0,
  "ExtensionsPerformanceDetectorEnabled": 0,
  "PerformanceDetectorEnabled": 0,
  "HighEfficiencyModeEnabled": 0,
  "QuickViewOfficeFilesEnabled": 0,
  "TextPredictionEnabled": 0,
  "MicrosoftEditorProofingEnabled": 0,
  "MicrosoftEditorSynonymsEnabled": 0,
  "SpellcheckEnabled": 0,
  "MouseGestureEnabled": 0,
  "FamilySafetySettingsEnabled": 0,
  "ClickOnceEnabled": 0,
  "ConfigureOnlineTextToSpeech": 0,
  "ConfigureShare": 0,
  "HideInternetExplorerRedirectUXForIncompatibleSitesEnabled": 1,
  "InternetExplorerIntegrationLevel": 0,
  "InternetExplorerIntegrationReloadInIEModeAllowed": 0,
  "ApplicationGuardFavoritesSyncEnabled": 0,
  "ApplicationGuardTrafficIdentificationEnabled": 0,
  "AccessibilityImageLabelsEnabled": 0,

  "BackgroundModeEnabled": 0,
  "StartupBoostEnabled": 0,
  "DefaultBrowserSettingEnabled": 0,
  "DefaultBrowserSettingsCampaignEnabled": 0
}'

# ---- Detection -------------------------------------------------------

detect_edge() {
    if flatpak list --system 2>/dev/null | grep -q "com.microsoft.Edge"; then
        echo "flatpak-system:/var/lib/flatpak/app/com.microsoft.Edge/current/active/files/extra/edge/policies/managed"
        return
    fi
    if flatpak list --user 2>/dev/null | grep -q "com.microsoft.Edge"; then
        echo "flatpak-user:$HOME/.var/app/com.microsoft.Edge/config/microsoft-edge/policies/managed"
        return
    fi
    for bin in microsoft-edge microsoft-edge-stable microsoft-edge-beta; do
        if command -v "$bin" >/dev/null 2>&1; then
            echo "system:/etc/opt/microsoft/edge/policies/managed"
            return
        fi
    done
    echo "not_found"
}

# ---- Main ------------------------------------------------------------

main() {
    local detection
    detection=$(detect_edge)

    if [[ "$detection" == "not_found" ]]; then
        echo "[✗] Microsoft Edge not found (checked Flatpak and system PATH)."
        exit 1
    fi

    local install_type policy_dir
    install_type="${detection%%:*}"
    policy_dir="${detection#*:}"

    echo "[i] Detected install type : $install_type"
    echo "[i] Policy directory      : $policy_dir"

    local policy_file="$policy_dir/edge_policies.json"
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
    echo "[✓] Edge policies applied to: $policy_file"
    echo "[i] Please restart Edge for changes to take effect."
}

main "$@"
