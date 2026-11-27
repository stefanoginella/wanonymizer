---
id: I-001
title: dump anonymizer
status: active
---

## Summary

The first release of wanonymizer: an open-source (MIT) command-line filter in Go that reads a WordPress SQL dump from a file or stdin and writes a dump without known personal data or keys, which still imports into a blank site. It is for WordPress developers, agencies, and support teams who share dumps to debug, investigate, develop locally, or use an LLM.

In this release: a streaming engine that also rewrites inside PHP-serialized and JSON values; rule packs for WordPress core, WooCommerce (HPOS and legacy orders, with shipping and tax rules kept working), four WooCommerce extensions, and five form plugins; a project config in two files (committed rules, and local word lists that are never committed); and a best-effort sweep of tables and keys without a rule, kept by default and emptied with `--strict`. Each run writes a report. The tool promises an honest scope and no legal label.

Later initiatives (rows in `roadmap.md`): reversible pseudonymization, companion logs and files, more plugin packs, a WP-CLI or plugin wrapper.

Build order: M-001 guardrails, M-002 the first end-to-end run on `wp_users`, M-003 the WordPress core pack, M-004 the sweep, M-005 WooCommerce, M-006 the project config, M-007 and M-008 the plugin packs. All are strict: each touches a sensitive path or a risk of 6 or more. Prior art is in R-001, the GDPR sources in R-002.

## Problem

A WordPress developer, an agency, or a support team needs a copy of a production database to debug, to investigate a fix or a hack, to develop locally, or to give to an LLM. The dump holds customer data, password hashes, and API keys, so sharing it is a privacy and legal risk. The existing tools need a live site, miss WooCommerce HPOS tables, treat serialized values as opaque strings, or delete the customers ([R-001](../../research/R-001-prior-art.md)).

## Outcome

The user pipes a dump through one command and gets a dump that holds no known personal data and no keys, imports into a blank site, and keeps WooCommerce shipping and tax rules working. A report says what was changed and what was removed.

## Scope

In:
- A dump stream filter: SQL dump in (file or stdin), SQL dump out.
- Rule packs for WordPress core, WooCommerce, four WooCommerce extensions, and five form plugins (D-09), in a pack format that others can extend.
- A project config for custom plugins, tables, and columns, with always-anonymize and never-anonymize word lists.
- A best-effort sweep of data that no rule covers.
- Irreversible anonymization.

Out, as roadmap rows:
- Reversible pseudonymization with an encrypted map.
- Companion logs and files (debug.log, WooCommerce logs, Nginx and Apache logs, text, CSV).
- More plugin packs, among them the forms of Elementor and Bricks.
- A WP-CLI command or a WordPress plugin that wraps the tool.
- winget and Scoop packages.

## Approach

A stream filter in Go: it reads a dump statement by statement, rewrites values by the rules of the matching packs, and writes the result. It needs no WordPress and no database, and never writes to one. Replacement values come from a random key made per run, so equal originals get equal replacements in one run, and nothing restores them. A pack is data, not code; the built-in packs and the project config share one format. Data without a rule goes through the sweep. The layout and the boundaries are in `architecture.md`.

## Milestones

| ID | Slug | Type | Rigor | Goal | Scope sketch |
|---|---|---|---|---|---|
| M-001 | guardrails | | | → spec.md | |
| M-002 | users-slice | feature | strict | The user pipes a dump through the tool and gets a dump whose `wp_users` rows hold no personal data: the thinnest run that proves the whole pipeline. | The CLI entry point and the CLI rule; the streaming tokenizer and writer (extended inserts, escapes, charsets, table prefix); the per-run key and replacement values; the pack format, with a core pack that covers `wp_users`; the run report and exit codes. Tables without a rule are emptied and reported until M-004. Out: serialized and JSON values, meta tables, config, sweep. |
| M-003 | wp-core-pack | feature | strict | A plain WordPress dump comes out with no personal data and no secrets in any core table, and still imports. | Rules for usermeta (names, sessions, application passwords), comments, options (salts, keys, SMTP passwords, admin email, transients), links, and multisite tables; rewriting inside PHP-serialized and JSON values with correct lengths. Option and meta keys without a rule are dropped and reported until M-004. Out: plugin data, theme-specific rules. |
| M-004 | sweep | feature | strict | Data that no rule covers is no longer dropped or missed: the site stays whole, and the report shows what the detectors did. | Detectors for emails, phone numbers, IP addresses, keys and tokens, and values already seen in ruled columns, over tables and keys without a rule, also inside serialized and JSON values. Sweep-and-keep becomes the default; `--strict` empties such tables. The report names each swept table and key. Out: detection by a language model or any network service. |
| M-005 | woocommerce-pack | feature | strict | A shop's dump comes out without customer data or keys, and the imported shop still calculates shipping and tax. | Rules for HPOS tables and legacy order meta, order addresses, the customer lookup, sessions, API keys, webhooks, payment tokens, download logs, order notes, and Action Scheduler arguments. Tax and shipping tables stay unchanged, and order and customer addresses keep matching their rules. Out: WooCommerce extensions (M-007). |
| M-006 | project-config | feature | strict | A site with custom plugins and tables is covered by a few lines of config, without a new release of the tool. | The committed config file (rules for custom plugins, tables, columns, and keys, in the pack format; a per-table choice to keep, sweep, or empty); the local config file (always-anonymize and never-anonymize word lists) and its gitignore advice; docs on writing a pack and a config. Out: packs loaded from a URL or a registry. |
| M-007 | woocommerce-extensions-pack | feature | strict | Shops with the common paid extensions are covered by rules, not by the detectors alone. | Packs for WooCommerce Subscriptions, the Stripe and PayPal gateway data, Memberships, and Bookings. Out: other gateways and extensions. |
| M-008 | forms-pack | feature | strict | Form entries, the densest personal data outside orders, are covered by rules. | Packs for Gravity Forms, WPForms, Contact Form 7 with Flamingo, Fluent Forms, and Ninja Forms: entries, entry meta, notification settings, and stored keys. Out: the forms of Elementor and Bricks (a roadmap row). |

## Open questions

- M-002: Which CLI rule do the commands, verbs, flags, and exit codes follow?
- M-002: Which file format do packs use?
- M-002: Which dump dialects are supported: mysqldump, mariadb-dump, `wp db export`, phpMyAdmin exports, gzip input?
- M-002: Are replacement values realistic (a plausible name and address) or clearly synthetic?
- M-003: What happens to free text by default: comment bodies and post content?
- M-003: Is the site domain replaced?
- M-003: How does the user log in after an import into a blank site?
- M-005: Are postcodes kept, or swapped for one that matches the same tax and shipping rules?
- M-005: Are order dates and totals kept?

## Decisions

| ID | Decision | Why | Rejected alternative |
|---|---|---|---|
| D-01 | The tool is a dump stream filter: a SQL dump in, an anonymized dump out | The user's choice (2026-11-27). It also covers a dump that someone already handed over, runs on the server so raw data need not leave it, and cannot damage a live database | A WP-CLI command or plugin inside WordPress: code on production, and no help for an existing dump. A database connection: a second server that first holds the raw data |
| D-02 | This release has the project config and the best-effort sweep. Reversible pseudonymization and companion logs are later initiatives | The user's choice (2026-11-27): every site has custom tables, and "no personal data, no keys" needs the sweep on a site with an unsupported plugin | All four in one release: more than one release of work |
| D-03 | The project config is two files: one that can be committed (rules for custom plugins, tables, columns), and a local one that is never committed (the always and never word lists, and other values that can be sensitive) | The user's request (2026-11-27): the word lists can hold personal data | One config file: a commit would publish the word lists |
| D-04 | The tool is open source, for WordPress developers, agencies, and support teams | The user's choice (2026-11-27): others add rule packs, and users can audit code that handles personal data | A private tool: no outside packs. A commercial product: licensing and billing work |
| D-05 | Go 1.27, with a new engine | The user's choice (2026-11-27). A prebuilt binary needs no runtime on a shared host; no existing engine has serialized-aware rewriting, deterministic pseudonyms, and detection together (R-001) | PHP: slower on big dumps, bound to the host's PHP. Rust: fewest contributors. A fork of Dekode's tool: GPL-3.0, and most of its core rewritten |
| D-06 | MIT license | The user's choice (2026-11-27): the fewest limits to embed the tool, and GPL-compatible for a later WP-CLI package or plugin | GPL-2.0-or-later: some companies avoid it. Apache-2.0: not compatible with GPL-2.0-only code |
| D-07 | A whole table that no pack or config covers is swept and kept: detectors rewrite what they recognise, the rest stays, and the report names the table. `--strict` empties such tables instead | The user's choice (2026-11-27): a fuller site by default | Empty by default (the recommended option, after R-002 para 36 and wp-anonimyzer): data of unsupported plugins missing until a config line. Keep unchanged: leaks by default |
| D-08 | The tool promises an honest scope: the docs and the run report say what was replaced, removed, and emptied, and the risk that stays. No "GDPR-compliant" or "anonymous" label | The user's choice (2026-11-27), after EDPB Guidelines 02/2026 para 40 and the enforcement cases (R-002). It replaces the "GDPR-compliant" wording of the input | "Anonymous by the EDPB criteria" as the design target: less realistic data by default. A "GDPR-compliant" label: a claim the tool cannot back |
| D-09 | Plugin packs of this release: WooCommerce extensions (Subscriptions, Stripe and PayPal gateway data, Memberships, Bookings) and forms (Gravity Forms, WPForms, Contact Form 7 with Flamingo, Fluent Forms, Ninja Forms) | The user's choice (2026-11-27): the plugins most shops run, and the densest personal data outside orders | Also email, security, and log plugins, EDD, LMS, membership, community, and the forms of Elementor and Bricks: more than one release; they are roadmap rows |
| D-10 | Tests are unit tests (with property tests) and golden dumps with canary values. No real import into WordPress in CI for now; the user tests the import by hand on a local WordPress | The user's choice (2026-11-27): "for now", to re-evaluate later (a deferred row in `roadmap.md`) | A real import into WordPress with WooCommerce in Docker, in CI (the recommended option): slower CI, and fixtures to maintain |
| D-11 | The 7 non-negotiables and the sensitive paths of `constitution.md`, as proposed: the engine, the rewriter, the pseudonym code, the sweep, the packs, and the CI and release files | The user's choice (2026-11-27): a defect in these paths leaks personal data or breaks a dump, and the output does not show it | Only the engine, the pseudonym code, and the release files as sensitive: cheaper, with less review where a miss leaks |
| D-12 | Hosted on GitHub with GitHub Actions. Each release has binaries for macOS, Linux, and Windows with checksums, a Homebrew tap, `go install`, and .deb and .rpm files | The user's choice (2026-11-27): the package files cost a few config lines | winget and Scoop now: a pull request to Microsoft's repo per release, and two more channels that can fail a release; they are a roadmap row. Binaries and Homebrew only: no Linux package files |

## Risks

The risk table with its protections is in `testing.md`. Risks of this initiative only:

- The tokenizer meets a dump dialect that it does not know: M-002 fixes the supported dialects, and a parse error stops the run.
- No real import runs in CI (D-10), so a dump that parses but breaks WordPress can pass the tests: the user imports by hand at each UAT, and a deferred row asks again at M-005.
- Sweep-and-keep is the default (D-07), so a detector miss in a table without a rule ships personal data: the report names every swept table, and `--strict` empties them.
- All 8 milestones are strict, which costs agents and time: the user can set a pack milestone to lean in `define`.
