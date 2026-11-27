# Roadmap

## Next

- Reversible pseudonymization: a mode that keeps an encrypted map of original and replacement values, and a command that restores them. The output of this mode stays personal data (R-002).
- Companion logs and files: debug.log, WooCommerce logs, Nginx and Apache access and error logs, and any text or CSV file, rewritten with the same replacements as the dump and packed with it.
- More plugin packs: email, security, and log plugins (MailPoet, WP Mail SMTP, Wordfence, Redirection, activity logs); Easy Digital Downloads, LearnDash, MemberPress, BuddyPress, bbPress; the forms of Elementor and Bricks.

## Later

- A WP-CLI command or a WordPress plugin that wraps the tool on a live site.
- winget and Scoop packages for Windows.

## Deferred

- Decide again on a real import into WordPress with WooCommerce in CI (due M-005)

## Manual actions

- M-001: Create the GitHub repository `stefanoginella/wanonymizer` and add it as the `origin` remote, before `/specstral:build M-001` (M-001 D-04).
- M-001: Create the Homebrew tap repository `stefanoginella/homebrew-tap`, and add a fine-grained token with contents read-write on it only as the `HOMEBREW_TAP_TOKEN` GitHub Actions secret.
