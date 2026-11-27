# Vision

## Problem

A copy of a production WordPress database is the fastest way to debug a site, investigate a fix or a hack, develop locally, or give an LLM the real context. The dump holds customers, orders, password hashes, and API keys, so handing it to an agency, a freelancer, a support team, or an AI service is a privacy and legal risk. The existing tools need a live site, miss WooCommerce HPOS tables, treat serialized values as opaque strings, or delete the customers ([R-001](research/R-001-prior-art.md)).

## Users

WordPress developers, agencies, and support teams who receive or produce database dumps, on their own machine or on the server over SSH. Today they share raw dumps, write one-off SQL scripts, or run an in-place scrubber on a staging copy that first holds the raw data.

## Outcome

- A user pipes a dump through one command and gets a dump with no known personal data and no keys, which imports into a blank site and behaves like the original: logins, orders, and WooCommerce shipping and tax rules work.
- The user knows what the tool did: each run reports what was replaced, removed, and swept, and the risk that stays. The tool promises no legal status ([R-002](research/R-002-gdpr-anonymisation.md)).
- A site with a custom plugin is covered by a few lines of project config, and a new plugin by a rule pack that anyone can contribute.
