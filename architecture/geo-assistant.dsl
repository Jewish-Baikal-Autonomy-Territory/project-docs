workspace "GeoAssistantApp" "C4 diagram of Geo Assistant Application." {

    !identifiers hierarchical

    model {
        user = person "User" "A registered person who places location-based markers, defines notification criteria, and receives real-time alerts."
        admin = person "Administrator" "A priviliged operator who manages system configuration, monitors platform activity, and controls user access."
        
        geoAssistantApp = softwareSystem "Geo Assistant App" "A location-aware productivity platform for managing contextual map markers, task lists, group collaboration, enhanced with an AI assistant."
        appleIdentityProvider = softwareSystem "Apple Identity Provider" "External OAuth2 identity provider. Authenticates users viw 'Sign in with Apple ID' and returns identity claims to the system, with optional email privacy relay." {
          tag "External"
        }
        googleIdentityProvider = softwareSystem "Google Identity Provider" "External OAuth2 identity provider. Authenticates users via 'Sign in with Google' and returns identity claims to the system." {
          tag "External"
        }
        unisenderSystem = softwareSystem "Unisender Notification System" "External email/sms notification system. Delivers email/sms notifications to clients." {
          tag "External"
        }
        firebaseCloudMessagingSystem = softwareSystem "Firebase Cloud Messaging System" "External push notification gateway. Delivers push notifications to Android and iOS clients." {
          tag "External"
        }

        user -> geoAssistantApp "Places markers and receives notifications using"
        admin -> geoAssistantApp "Manages and monitors using"
        geoAssistantApp -> unisenderSystem "Sends email/sms messages using"
        geoAssistantApp -> appleIdentityProvider "Validates user identity using"
        geoAssistantApp -> googleIdentityProvider "Validates user identity using"
        geoAssistantApp -> firebaseCloudMessagingSystem "Sends push notification using"
    }

    views {
        systemContext geoAssistantApp "GeoAssistantApp-SystemContext" "Geo Assistant App - External dependencies overview." {
            include *
        }
        
        styles {
        }
        
        theme "https://raw.githubusercontent.com/Jewish-Baikal-Autonomy-Territory/project-docs/refs/heads/main/architecture/c4-theme.json"
    }

    configuration {
        scope softwaresystem
    }

}