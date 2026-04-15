workspace "GeoAssistantApp" "C4 diagram of Geo Assistant Application." {

    !identifiers hierarchical

    model {
        user = person "User" "A registered person who places location-based markers, defines notification criteria, and receives real-time alerts."
        admin = person "Administrator" "A priviliged operator who manages system configuration, monitors platform activity, and controls user access."
        
        geoAssistantApp = softwareSystem "Geo Assistant App" "A location-aware productivity platform for managing contextual map markers, task lists, group collaboration, enhanced with an AI assistant." {
            adminPanel = container "Admin Panel" "A browser-based administrative client that enables privileged operators to manage user accounts, monitor platform activity, and control system configuration." "JavaScript + React" {
                tag "WebApp"
            }
            
            iosMobileApp = container "iOS Mobile Application" "A native iOS client that enables users to place and manage contextual map markers, receive real-time group updates, manage tasks linked to map events, and interact with the AI assistant for voice-driven task generation." "Swift UI" {
                tag "MobileApp"
            }
            androidMobileApp = container "Android Mobile Applicaiton" "A native Android client that enables users to place and manage contextual map markers, receive real-time group updates, manage tasks linked to map events, and interact with the AI assistant for voice-driven task generation." "Jetpack Compose" {
                tag "MobileApp"
            }
            
            apiGateway = container "API Gateway" "Acts as a unified entry point for all client requests. Handles protocol conversion between REST/gRPC, routes requests to appropriate backend services, and enforces cross-cutting concerns such as authentication, rate limiting, and logging." "Envoy API Gateway" {
                tag "APIGateway"
            }
            
            authService = container "Authentication Service" "A microservice responsible for managing user authentication and authorization. Handles basic auth and credential validation, orchestrates OAuth2 identity verification with external providers, issues and refreshes application-scoped JWT access and refresh token pairs, and maintains active session state." "Java Spring"
            authDatabase = container "Authentication Database" "A relational database that persistently stores user credentials, OAuth2 provider associations, and authentication audit records for the Authentication Service." "PostgreSQL" {
                tag "Database"
            }
            authSessionCache = container "Authentication Session Cache" "An in-memory cache that stores active user session state and short-lived token metadata to enable fast authentication validation without persistent storage round trips." "Redis"
            
            notificationService = container "Notification Service" "A microservice that acts as a stateless wrapper for external notification providers. Consumes user registration and system events from the event bus and dispatches notifications via push, email, and SMS channels accordingly." "Go Fiber"
            
            relationshipService = container "Relationship Service" "A microservice responsible for managing the social graph of the platform. Maintains user friendship connections, group memberships, and shared marker associations. Consumes user registration events to synchronize identity nodes and provides relationship-aware queries for group collaboration features." "Go"
            relationshipDatabase = container "Relationship Database" "A graph database that persists the social graph including user nodes, friendship edges, group memberships, and shared marker associations." "Neo4j" {
                tag "Database"
            }
            
            profileService = container "Profile Service" "A microservice responsible for aggregating and managing user profile data including display information, application preferences, and notification settings. Serves as the primary source of truth for user-facing profile information consumed by mobile clients." "Go"
            profileDatabase = container "Profile Database" "A document store that persists user profile documents including personal information, application preferences, and usage statistics for the Profile Service." "MongoDB" {
                tag "Database"
            }
            
            geoService = container "Geo Service" "A microservice responsible for processing and managing geospatial data. Handles map marker creation, spatial queries, geofence definitions and proximity evaluations. Persists geographic data with spatial indexing and caches frequently accessed geospatial computations for low-latency location-aware feature delivery." "Go"
            geoDatabase = container "Geo Database" "A database extended that persistently stores geospatial data including map marker coordinates, geofence polygon boundaries, and spatial indexes for efficient proximity and containment queries." "PostgreSQL/PostGIS" {
                tag "Database"
            }
            geoCache = container "Geo Cache" "Caches frequently accessed geospatial computations and proximity query results using native GEO commands, providing low-latency location-aware data delivery." "Redis"
            
            eventBus = container "Event Bus" "An event bus that facilitates asynchronous event-driven communication between internal microservices, decoupling event producers from their downstream consumers." "Apache Kafka" {
                tag "MessageBroker"
            }
        }
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

        user -> geoAssistantApp.iosMobileApp "Places markers and receives notifications using"
        user -> geoAssistantApp.androidMobileApp "Places markers and receives notifications using"
        admin -> geoAssistantApp.adminPanel "Manages and monitors using"
        
        geoAssistantApp.iosMobileApp -> geoAssistantApp.apiGateway "Sends CRUD requests using" "gRPC"
        geoAssistantApp.iosMobileApp -> geoAssistantApp.apiGateway "Streams real-time events using" "WSS + Protobuf"
        geoAssistantApp.androidMobileApp -> geoAssistantApp.apiGateway "Sends CRUD requests using" "gRPC"
        geoAssistantApp.androidMobileApp -> geoAssistantApp.apiGateway "Streams real-time events using" "WSS + Protobuf"
        
        geoAssistantApp.adminPanel -> geoAssistantApp.apiGateway "Sends requests to using" "HTTPS + REST + JSON"
        
        geoAssistantApp.apiGateway -> geoAssistantApp.authService "Forward authentication requests to" "gRPC"
        
        geoAssistantApp.authService -> geoAssistantApp.authDatabase "Persists user credentials via"
        geoAssistantApp.authService -> geoAssistantApp.authSessionCache "Stores and retreives session state via"
        geoAssistantApp.authService -> geoAssistantApp.eventBus "Publishes user registration events to"
        geoAssistantApp.authService -> appleIdentityProvider "Validates OAuth2 identity claims via"
        geoAssistantApp.authService -> googleIdentityProvider "Validates OAuth2 identity claims via"
        
        geoAssistantApp.profileService -> geoAssistantApp.eventBus "Consumes user registration events from"
        geoAssistantApp.profileService -> geoAssistantApp.profileDatabase "Persists and queries profile data via"
        
        geoAssistantApp.relationshipService -> geoAssistantApp.relationshipDatabase "Persists and queries social data via"
        geoAssistantApp.relationshipService -> geoAssistantApp.eventBus "Consumes user registration events from"
        
        geoAssistantApp.geoService -> geoAssistantApp.geoDatabase "Persists and queries spatial data via"
        geoAssistantApp.geoService -> geoAssistantApp.geoCache "Caches geospatial computations and proximity queries via"
        geoAssistantApp.geoService -> geoAssistantApp.eventBus "Publishes geofence proximity events to"
        
        geoAssistantApp.notificationService -> geoAssistantApp.eventBus "Consumes user registration events via"
        geoAssistantApp.notificationService -> geoAssistantApp.eventBus "Consumes geofence proximity events from"
        geoAssistantApp.notificationService -> unisenderSystem "Sends email and sms messages using"
        geoAssistantApp.notificationService -> firebaseCloudMessagingSystem "Sends push notifications using"
    }

    views {
        systemContext geoAssistantApp "GeoAssistantApp-SystemContext" "Geo Assistant App - External dependencies overview." {
            include *
        }
        
        container geoAssistantApp "GeoAssistantApp-ContainerContext" {
            include *
        }
        styles {
          element "Person" {
            shape person
            background "#85C1E9"
            color "#000000"
          }

          element "Software System" {
            background "#A9DFBF"
            color "#000000"
          }

          element "Container" {
            background "#5DADE2"
            color "#000000"
          }

          element "Component" {
            background "#2E86C1"
            color "#FFFFFF"
          }

          element "Database" {
            shape Cylinder
            background "#F5B041"
            color "#000000"
          }
          
          element "MobileApp" {
              shape MobileDevicePortrait
              background "#5DADE2"
              color "#000000"
          }
          
          element "WebApp" {
              shape WebBrowser
              background "#5DADE2"
              color "#000000"
          }
          
          element "APIGateway" {
              shape Hexagon
              background "#5DADE2"
              color "#000000"
          }
          
          element "MessageBroker" {
              shape Pipe
              background "#5DADE2"
              color "#000000"
          }
        }
        
        theme "https://raw.githubusercontent.com/Jewish-Baikal-Autonomy-Territory/project-docs/refs/heads/main/architecture/c4-theme.json"
    }

    configuration {
        scope softwaresystem
    }

}