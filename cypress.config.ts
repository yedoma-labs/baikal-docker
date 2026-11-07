import { defineConfig } from "cypress";

const config = {
  // Non-sensitive values readable in specs via Cypress.expose(key)
  expose: {
    BAIKAL_VERSION: process.env.CYPRESS_BAIKAL_VERSION,
  },
  e2e: {
    supportFile: false,
    screenshotsFolder: "cypress/screenshots",
    excludeSpecPattern: "",
  },
};

// If MSMTP is enabled, we will use a different screenshots folder,
// otherwise exclude the MSMTP tests.
if (process.env.CYPRESS_MSMTP_ENABLED ?? false) {
  config.e2e.screenshotsFolder = "cypress/screenshots/msmtp";
} else {
  config.e2e.excludeSpecPattern = "**/*.msmtp.cy.ts";
}

export default defineConfig(config as Cypress.ConfigOptions);
