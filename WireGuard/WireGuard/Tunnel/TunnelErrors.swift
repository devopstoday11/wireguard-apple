// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import NetworkExtension
import WireGuardKit

enum TunnelsManagerError: WireGuardAppError {
    case tunnelNameEmpty
    case tunnelAlreadyExistsWithThatName
    case systemErrorOnListingTunnels(systemError: Error)
    case systemErrorOnAddTunnel(systemError: Error)
    case systemErrorOnModifyTunnel(systemError: Error)
    case systemErrorOnRemoveTunnel(systemError: Error)

    var alertText: AlertText {
        switch self {
        case .tunnelNameEmpty:
            return (tr("alertTunnelNameEmptyTitle"), tr("alertTunnelNameEmptyMessage"))
        case .tunnelAlreadyExistsWithThatName:
            return (tr("alertTunnelAlreadyExistsWithThatNameTitle"), tr("alertTunnelAlreadyExistsWithThatNameMessage"))
        case .systemErrorOnListingTunnels(let systemError):
            return (tr("alertSystemErrorOnListingTunnelsTitle"), systemError.localizedUIString)
        case .systemErrorOnAddTunnel(let systemError):
            return (tr("alertSystemErrorOnAddTunnelTitle"), systemError.localizedUIString)
        case .systemErrorOnModifyTunnel(let systemError):
            return (tr("alertSystemErrorOnModifyTunnelTitle"), systemError.localizedUIString)
        case .systemErrorOnRemoveTunnel(let systemError):
            return (tr("alertSystemErrorOnRemoveTunnelTitle"), systemError.localizedUIString)
        }
    }
}

enum TunnelsManagerActivationAttemptError: WireGuardAppError {
    case tunnelIsNotInactive
    case failedWhileStarting(systemError: Error) // startTunnel() throwed
    case failedWhileSaving(systemError: Error) // save config after re-enabling throwed
    case failedWhileLoading(systemError: Error) // reloading config throwed
    case failedBecauseOfTooManyErrors(lastSystemError: Error) // recursion limit reached

    var alertText: AlertText {
        switch self {
        case .tunnelIsNotInactive:
            return (tr("alertTunnelActivationErrorTunnelIsNotInactiveTitle"), tr("alertTunnelActivationErrorTunnelIsNotInactiveMessage"))
        case .failedWhileStarting(let systemError),
             .failedWhileSaving(let systemError),
             .failedWhileLoading(let systemError),
             .failedBecauseOfTooManyErrors(let systemError):
            return (tr("alertTunnelActivationSystemErrorTitle"),
                    tr(format: "alertTunnelActivationSystemErrorMessage (%@)", systemError.localizedUIString))
        }
    }
}

enum TunnelsManagerActivationError: WireGuardAppError {
    case activationFailed(wasOnDemandEnabled: Bool)
    case activationFailedWithExtensionError(title: String, message: String, wasOnDemandEnabled: Bool)

    var alertText: AlertText {
        switch self {
        case .activationFailed(let wasOnDemandEnabled):
            return (tr("alertTunnelActivationFailureTitle"), tr("alertTunnelActivationFailureMessage") + (wasOnDemandEnabled ? tr("alertTunnelActivationFailureOnDemandAddendum") : ""))
        case .activationFailedWithExtensionError(let title, let message, let wasOnDemandEnabled):
            return (title, message + (wasOnDemandEnabled ? tr("alertTunnelActivationFailureOnDemandAddendum") : ""))
        }
    }
}

extension WireGuardPacketTunnelProviderError: WireGuardAppError {
    var alertText: AlertText {
        switch self {
        case .loadTunnelConfiguration:
            return (tr("alertTunnelActivationFailureTitle"), tr("alertTunnelActivationSavedConfigFailureMessage"))
        case .dnsResolution:
            return (tr("alertTunnelDNSFailureTitle"), tr("alertTunnelDNSFailureMessage"))
        case .startWireGuardBackend:
            return (tr("alertTunnelActivationFailureTitle"), tr("alertTunnelActivationBackendFailureMessage"))
        case .tunnelDeviceFileDescriptor:
            return (tr("alertTunnelActivationFailureTitle"), tr("alertTunnelActivationFileDescriptorFailureMessage"))
        case .setNetworkSettings:
            return (tr("alertTunnelActivationFailureTitle"), tr("alertTunnelActivationSetNetworkSettingsMessage"))
        }
    }
}

extension Error {
    var localizedUIString: String {
        if let systemError = self as? NEVPNError {
            switch systemError {
            case NEVPNError.configurationInvalid:
                return tr("alertSystemErrorMessageTunnelConfigurationInvalid")
            case NEVPNError.configurationDisabled:
                return tr("alertSystemErrorMessageTunnelConfigurationDisabled")
            case NEVPNError.connectionFailed:
                return tr("alertSystemErrorMessageTunnelConnectionFailed")
            case NEVPNError.configurationStale:
                return tr("alertSystemErrorMessageTunnelConfigurationStale")
            case NEVPNError.configurationReadWriteFailed:
                return tr("alertSystemErrorMessageTunnelConfigurationReadWriteFailed")
            case NEVPNError.configurationUnknown:
                return tr("alertSystemErrorMessageTunnelConfigurationUnknown")
            default:
                return ""
            }
        } else {
            return localizedDescription
        }
    }
}
