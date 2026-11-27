---
id: R-001
title: prior art
date: 2026-11-27
---

## Summary

Question: which tools already anonymize WordPress databases or MySQL dumps, and what gap is left? Searched 2026-11-27.

Answer: many tools exist, and none combines (a) a run on a dump file or stream with no live site, (b) WooCommerce rules that cover both HPOS and legacy order storage, (c) secrets in `wp_options`, (d) rewriting inside PHP-serialized and JSON values, (e) deterministic pseudonyms, and (f) handling of tables without a rule. The closest WordPress tool is wp-anonimyzer (PHP, needs a live database, WP-CLI, mysqldump, and DDL rights). The closest stream engines are myanon (C) and DekodeInteraktiv/anonymize-mysqldump (Go, WordPress defaults). No MySQL tool offers reversible pseudonymization. Laranon, which the user named, is not a database tool: it is a Laravel library that finds personal data in text (LLM prompts, logs, API bodies).

The stack facts of the same search (libraries, runtimes, distribution) are in `## Stack facts` below.

## WordPress tools

| Tool | Shape and mode | Covers | Config | State |
|---|---|---|---|---|
| bluelabsit/wp-anonimyzer | PHP CLI over WP-CLI, mysqldump, mysql. Copies the live DB into a temporary `anon_tmp_` schema, transforms, verifies, writes a gzip dump | Users, usermeta, HPOS and legacy orders, comments and order notes (bodies redacted), suspicious option keys. Unknown plugin tables: structure only | Wizard writes `run-config.json`. HMAC pseudonyms with a seed | v1.1.1, 2026-09-16; 0 stars; no license shown |
| williarin/wordpress-anonymizer | Docker image or Composer library; in place | Users, usermeta, comments, WooCommerce legacy meta; no HPOS | PHP provider classes (Faker) | 1.0.1, 2022-02-05; stale |
| makers99/wp-cli-db-export-clean | WP-CLI; during export | Deletes all users but admins and shop managers, with their data. HPOS, Subscriptions, Gravity Forms. `--remove-keys` drops option rows with keys | Filters in an mu-plugin | v1.0.1, 2026-09-04 |
| jooplaan/erase-personal-data | WP-CLI; in place | Core and 20+ plugins; orders through legacy postmeta only; no `wp_options`. Fixed value "Anonymous" | Edit the PHP source | Last commit 2026-05-05 |
| 10up/wp-scrubber | WP-CLI; in place; refuses production; 2 GB limit | Core users and comments | Hooks and `wp-scrubber.json` | Beta; last commit 2025-02-27; 28 stars |
| a8cteam51/safety-net | Plugin with WP-CLI; in place | Deletes non-admin users, orders, subscriptions; scrubs an option denylist | Code | 1.12.2, 2026-11-19; 35 stars |
| Database Anonymization (wordpress.org) | Plugin; exports an anonymized SQL file, or in place | Any table by rule, with serialized and JSON values. WooCommerce and form rules are paid | Rules in the admin | v2.0.3, 2026-05-25; 10+ installs |
| deliciousbrains/wp-migrate-db-anonymization | WP Migrate add-on; during export, push, pull | Users, usermeta, comments, WooCommerce legacy meta; no HPOS. Serialized data is an opaque string | Constants and a filter | wordpress.org 0.3.4, 2022-01-26. Open PR #40 (2026-11-01) adds a WP-CLI mode with HMAC |
| UpdraftPlus Premium | Paid backup option | Usernames, emails, IPs, custom fields; no coverage list | None | Undated vendor page |

Older or minimal WP-CLI packages (last commit 2016 to 2022): blavetstudio/wp-cli-db-anonymize, humanmade/hm-anonymizer (archived), EP4/wpcli-anonymizer, hoppinger/wp-cli-anonymize-command, Psycle/psycle-pii-scrub, webdevstudios/wds-user-email-scrambler.

Hosts: WordPress VIP has no automatic scrubbing in its data sync (a `vip_datasync_cleanup` hook for custom code; doc of 2024-05-17). No documented anonymize-on-clone feature found for Kinsta, WP Engine, or Pantheon (absence of a search result, not proof).

## General MySQL tools

| Tool | Input | Deterministic | JSON / PHP-serialized | Detects without a rule | License | State |
|---|---|---|---|---|---|---|
| ppomes/myanon | Dump on stdin | Yes, HMAC-SHA256 with a secret | JSON paths; no serialized | No | Modified BSD | v0.8.8, 2026-10-23 |
| DekodeInteraktiv/anonymize-mysqldump | Dump on stdin; default config for WordPress tables | No, random Faker values; columns by position; INSERT only | Neither | No | GPL-3.0 | v0.9.3, 2026-10-08 |
| humanmade/go-anonymize-mysqldump | Dump on stdin | Not checked | Not checked | No | Not checked | Last push 2022 |
| Smile-SA/gdpr-dump | Live MySQL connection | `hash` only, with no salt | Both, by path | No | GPL-3.0 | 5.0.7, 2026-02-23 |
| nixys/nxs-data-anonymizer | Dump on stdin | `link` gives equal output for equal input | No paths | Randomizes undescribed columns by SQL type | Apache-2.0 | v1.15.0, 2025-09-22 |
| rwnx/pynonymizer | Dump restored into a temporary DB | No | Neither | No | MIT | 2.5.0, 2024-12-27; stale |
| GreenmaskIO/greenmask | Live connection | Yes, hash engine | JSON paths | No | Apache-2.0 | v0.2.27, 2026-11-12; MySQL is beta |
| Qovery/replibyte | Live DB or dump | Not documented | No | No | GPL-3.0 | Last commit 2024-05-04 |
| edulazaro/laranon | Strings and arrays, not tables | Same value gives the same token in a scope | No | Yes, validators in free text (IBAN, Luhn) | MIT | 1.4.2, 2026-11-22 |

Laranon keeps a reversible map per scope, encrypted with the Laravel app key, in a vault (cache, database, or array). That design is the model for the reversible mode on the roadmap.

## Stack facts

- Dump parsing: no maintained library in PHP, Go, Rust, or Node tokenizes mysqldump output (INSERT, extended inserts, escaping) as a stream. Every stack needs a hand-written tokenizer. General SQL parsers work on one statement in memory: phpmyadmin/sql-parser 6.0.2 (PHP), Vitess `go/vt/sqlparser` (Go, heavy), sqlparser 0.64.0 (Rust), node-sql-parser 5.4.0 (Node).
- PHP-serialized values: PHP built in; Go elliotchance/phpserialize v1.4.0 (2024-01-31); Rust phpserz 0.3.0 (2026-03-08); Node php-serialize 5.1.3 (2025-03-20).
- Fake data with locales: fakerphp/faker v1.24.1 (PHP, many locales); @faker-js/faker 10.6.0 (Node, 79 locale folders); Rust `fake` 5.1.0 (about 12 locales); Go brianvoe/gofakeit v7.18.11 and jaswdr/faker v2.10.0 (no locale option in their READMEs).
- Stable runtimes: PHP 8.6.0 (2026-11-19); Go 1.27.4; Rust 1.100.0; Node v26.13.1 LTS.
- Distribution: Go, a static binary through GoReleaser (v2.20.3), a Homebrew tap, `go install`. Rust, a binary through cargo-dist. PHP, a phar built with box, or a WP-CLI package. Node, npm; its single-executable build is in active development.
- WP-CLI: a package command runs without WordPress loaded (`@when before_wp_load`). The latest release is v2.12.0 (2025-05-07), PHP 7.2.24 or later; not verified on PHP 8.5 or 8.6.
- Shared hosts usually have PHP and rarely Go or Node; a prebuilt Go or Rust binary needs neither.

## Gaps

- A run on an existing `.sql` file with no live site: only the general tools do it, and none ships WooCommerce rules for HPOS.
- HPOS (`wc_orders`, `wc_order_addresses`, `wc_orders_meta`, `wc_order_operational_data`) with legacy postmeta, option secrets, and deterministic pseudonyms in one tool.
- Personal data outside structured columns: serialized and JSON values, and free text (post content, reviews, order notes, form entries).
- Maintained, versioned rule sets per plugin: today they are paid, hardcoded, or absent.
- Proof that the result imports into a blank site and works (unique emails, intact references, correct serialized lengths).
- A check of the output that suits sharing with an LLM service.

## Unknown

- Duplicator, WP Staging, and Local were not checked.
- Coverage of Database Anonymization Enterprise and of UpdraftPlus for HPOS.
- MariaDB compatibility of each general tool.
- Memory use of any SQL lexer on a multi-GB extended INSERT on one line: needs a prototype.

## Sources

All read 2026-11-27; dates are the last release or commit.

- https://github.com/bluelabsit/wp-anonimyzer (2026-09-16)
- https://github.com/deliciousbrains/wp-migrate-db-anonymization and its pull request 40 (2026-11-01)
- https://wordpress.org/plugins/database-anonymization/ (2026-05-25)
- https://github.com/makers99/wp-cli-db-export-clean (2026-09-04)
- https://github.com/10up/wp-scrubber (2025-02-27)
- https://github.com/a8cteam51/safety-net (2026-11-19)
- https://github.com/jooplaan/erase-personal-data (2026-05-05)
- https://github.com/williarin/wordpress-anonymizer (2022-02-05)
- https://docs.wpvip.com/databases/data-sync/cleanup-operations/ (2024-05-17)
- https://github.com/ppomes/myanon (2026-10-23)
- https://github.com/DekodeInteraktiv/anonymize-mysqldump (2026-10-08)
- https://github.com/Smile-SA/gdpr-dump (2026-02-23)
- https://github.com/nixys/nxs-data-anonymizer (2025-09-22)
- https://github.com/rwnx/pynonymizer (2024-12-27)
- https://github.com/GreenmaskIO/greenmask (2026-11-12)
- https://github.com/Qovery/Replibyte (2024-05-04)
- https://github.com/edulazaro/laranon (2026-11-22)
- https://go.dev/dl/?mode=json, https://www.php.net/releases/index.php, https://nodejs.org/dist/index.json, https://static.rust-lang.org/dist/channel-rust-stable.toml (live, 2026-11-27): runtime versions
- https://make.wordpress.org/cli/handbook/guides/commands-cookbook/ (undated): `@when before_wp_load`, `wp package install`
- The npm registry, crates.io, packagist.org, proxy.golang.org, and the GitHub API (live, 2026-11-27): library versions and dates
