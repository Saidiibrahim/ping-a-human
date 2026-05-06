---
allowed-tools: Bash(bun dev:*), mcp__claude-in-chrome__*
description: Test the portal invite flow end-to-end
---

## Overview

Test the invite-only portal access feature end-to-end using browser automation. This command will:
1. Start the dev server if not running
2. Get a temporary email from temp-mail.org
3. Create a new client with that email
4. Send a portal invite
5. Accept the invite using the magic link from temp mail
6. Verify portal access works

The entire flow will be recorded as a GIF.

## Prerequisites

- Chrome browser with Claude extension connected
- You are logged into the app with a role that has `clients.create` permission:
  - owner, admin, practitioner, reception, or intern
  - Login route is `/auth/login` (not `/login`)
- Alternative: If you don't have permission to create clients, you can:
  - Seed a test client directly in the database before testing the invite flow
  - Use an existing client that doesn't already have portal access

## Test Flow

### Phase 1: Setup

1. Start the dev server with `bun dev` if not already running (run in background)
2. Get browser context via `tabs_context_mcp` (createIfEmpty: true)
3. Create a tab for the app
4. Create a tab for temp-mail.org
5. Start GIF recording with `gif_creator` action: `start_recording`
6. Take initial screenshot to capture first frame

### Phase 2: Get Temporary Email

1. Navigate to https://temp-mail.org/en/
2. Wait for the page to fully load (email address appears in the input field)
3. Find and read the temporary email address (look for input with id "mail" or similar)
4. Store this email address for later use
5. Take a screenshot

### Phase 3: Create Client

1. Switch to the app tab
2. Navigate to http://localhost:3000/clients
3. Wait for the page to load
4. Click either "New Client" or "Add referral" button:
   - Both buttons require `clients.create` permission
   - If you don't see these buttons, log in with a role that has permission (see Prerequisites)
5. In the Create Client/Referral dialog, fill in:
   - First Name: "Test" + random 4 digits (e.g., "Test1234")
   - Last Name: "Portal" + random 4 digits (e.g., "Portal5678")
   - Scroll to "Contact Information" section
   - Email: Enter the temporary email from Phase 2
6. Click the submit button to create the client
7. Wait for success (toast notification appears or dialog closes)
8. Verify the client was created:
   - Toast notification shows success
   - You're redirected to the client detail page
   - Client ID is visible in the URL (save this for later verification)
9. Take a screenshot

### Phase 4: Send Portal Invite

1. After client creation, navigate to the client detail page if not already there
2. Find the "Portal Access" card in the Overview tab
3. Click the "Invite to Portal" button
4. In the invite dialog:
   - Verify email is pre-filled with the temp email (or enter it if not)
   - Ensure "Self (Client)" is selected for relationship (default)
   - Note: For "Self" relationship, the invite email MUST match the client's email on file
   - Click "Send Invitation"
5. Wait for success (dialog closes, card shows "Pending" badge)
6. Take a screenshot showing the pending invite status

### Phase 5: Get Invite from Temp Mail

1. Switch to the temp-mail tab
2. Refresh or wait for the invite email to arrive (may take 10-30 seconds)
3. Look for an email with subject containing "invite" or "You've been invited"
4. Click to open the email
5. Find the magic link in the email body (link containing "/auth/set-password")
6. Extract and store the FULL URL including the hash fragment (#access_token=...)
7. Take a screenshot of the email

### Phase 6: Accept Invite and Set Password

1. Create a new tab for the portal signup
2. Navigate to the magic link URL (must include the full hash fragment)
3. Wait for the set-password page to load
4. Generate a secure random password meeting these requirements:
   - 12+ characters (minimum 12, not 8)
   - At least one uppercase letter
   - At least one lowercase letter
   - At least one number
   - At least one special character
   - Example pattern: `PortalTest` + random 4 alphanumeric + `!1` (e.g., `PortalTest7829!1`)
5. Enter the password in the password field
6. Enter the same password in the confirm password field
7. Click the "Complete Setup" button
8. Wait for redirect to /portal/profile (not /portal which returns 404)
9. Take a screenshot showing successful portal access

### Phase 7: Verify and Report

1. Confirm the portal profile page loaded successfully (URL should be /portal/profile)
2. Take final screenshot
3. Stop GIF recording with `gif_creator` action: `stop_recording`
4. Export GIF with `gif_creator` action: `export` with:
   - download: true
   - filename: "portal-invite-test-[timestamp]"
5. Report test results including:
   - Temporary email address used
   - Client name created (First Last)
   - Password generated (so user can log in again if needed)
   - Success/failure status for each phase
   - Note about the downloaded GIF

## Error Handling

- If any step fails, take a screenshot and note the error
- Stop GIF recording even on failure (so partial recording is saved)
- If temp-mail email doesn't arrive within 60 seconds, try refreshing the inbox
- If the magic link appears expired or invalid, report the specific error message from the form
- Common errors:
  - "Your role (X) doesn't have permission to perform this action" - log in with a role that has `clients.create` (see Prerequisites)
  - "Link expired" - invite took too long, need to resend
  - "No pending invite found" - something went wrong with the invite creation
  - "Staff accounts cannot accept portal invites" - logged into wrong account
  - "/portal returns 404" - this is expected, you should be redirected to /portal/profile
  - "Failed to load clients" on portal profile - RLS policy issue, check migrations are applied

## Notes

- Password requirements: 12+ chars, uppercase, lowercase, number, special char
- Track tab IDs carefully - use `tabs_context_mcp` if confused about which tab is active
- Supabase invite emails typically arrive within 10-30 seconds
- The magic link hash fragment is critical - must include #access_token=... and refresh_token=...
- After successful password set, user is automatically logged in and redirected to /portal/profile

## Error Recovery

- If form data is lost due to a permission error, the temp email is still valid - just re-enter the form data
- If "Failed to load clients" appears on portal profile after login, the RLS migration may not be applied
- If magic link shows "Link expired", resend the invite from the staff side (client detail page)
- If you need to retry the test, create a new temp email - the old one may already have an auth.users entry
