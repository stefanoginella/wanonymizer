# Glossary

**Anonymization**: replacing or removing values so that the tool keeps nothing to restore them. The word names the tool's mode, not a legal status of the output. _Avoid_: scrubbing, sanitizing.
**Canary value**: a made-up, unique value planted in a test fixture; a test fails when it appears in the output, a log, or a report. _Avoid_: marker, sentinel.
**Pack**: a data file of rules for one product (WordPress core, WooCommerce, one plugin): which tables, columns, and keys hold what kind of data. _Avoid_: provider, template, plugin.
**Pseudonymization**: replacing values while keeping an encrypted map to restore them. A later initiative; its output stays personal data. _Avoid_: reversible anonymization.
**Sweep**: the pass that runs detectors over tables and keys that no pack or config covers. _Avoid_: scan, auto-detect.
