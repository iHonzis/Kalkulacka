import Foundation

/// Configuration for Convex backend
/// For dev mode: Get URL from `npx convex dev` output
/// For production: Get URL from `npx convex deploy` or Convex dashboard
struct ConvexConfig {
    // TODO: Replace with your actual Convex deployment URL
    // When running `npx convex dev`, look for a line like:
    // "Convex dashboard: https://your-project.convex.cloud"
    // Or check your Convex dashboard URL
    static let deploymentURL = "https://laudable-perch-634.convex.cloud"
    
    // Convex integration enabled
    static let isEnabled = true
}
