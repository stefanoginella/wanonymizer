---
id: R-002
title: gdpr anonymisation
date: 2026-11-27
---

## Summary

Question: under the GDPR, when is a shared database dump anonymous, when is it pseudonymised (still personal data), and what may a tool claim? Searched 2026-11-27. This is a record of sources, not legal advice.

Answer: data is anonymous only when no person in it can be identified by means reasonably likely to be used (Recital 26). The risk must be insignificant, not zero, and it is judged per entity that holds the data. Pseudonymised data, which can be linked to a person with extra information, stays personal data, also when someone else holds that information. A controller that keeps a key or a map must treat the shared data as personal data. For a recipient without the key, the data is not always personal data (CJEU C-413/23 P), but it is when the recipient works on the controller's behalf, as an agency or a freelancer does. No source supports a tool that labels its output "GDPR-compliant" or "anonymous": the controller makes that assessment, per recipient.

For the tool: free text, IP addresses, and rare combinations of attributes decide an anonymity claim, not only names and emails. The docs describe what the tool changes and the risk that stays, and promise no legal status.

## Findings

- Current guidance on anonymisation: EDPB Guidelines 02/2026, adopted 2026-07-07 as version 1.0 for public consultation. It updates WP29 Opinion 05/2014. The three criteria are now No Record Isolation (singling out), No Linkage, and No Inference (para 2). Passing all three means "safely anonymous"; failing one needs more analysis.
- A dataset is anonymous only if it is anonymous for every individual in it (para 36).
- "Means" include what an entity can reach through other parties (paras 20-22, 26-30). A contract that forbids re-identification only complements technical measures (para 34). Lack of motive is not a reason (para 31).
- Anonymisation is itself processing that needs a legal basis, and its result is reassessed over time (paras 35, 38).
- A controller that keeps the key treats the data as personal data (para 37). The recipient's own view counts only when the recipient is an independent controller. When it processes on the controller's behalf, the data is personal data for it too (paras 15, 21). When the recipient can pass the data to someone who can re-identify, it is personal data for that transfer (para 21).
- Controllers should not use "anonymous", "de-identified", or "de-personalised" while people are still identifiable (para 40), and should document the process and its tests (para 41).
- Pseudonymisation: EDPB Guidelines 01/2025 exist only as the consultation version of 2025-01-16. Pseudonymised data is personal data, also when another party holds the additional information.
- CJEU C-413/23 P, EDPS v SRB (2025-09-04): pseudonymised data is not personal data "in all cases and for every person". The duty to tell data subjects about recipients is judged from the controller's side at collection. The case was decided under Regulation 2018/1725; the EDPB applies it to the GDPR.
- Digital Omnibus: a proposal, not law. The Commission proposed an entity-relative definition of personal data. The Council mandate of 2026-10-21 deletes it and adds an Art. 25a on pseudonymised data. Parliament has no position; trilogues are not expected before about March 2027.
- Enforcement where "anonymised" data was pseudonymised: CNIL, EUR 5M (July 2026, health data; secondary source); Garante v IQVIA, EUR 7M; Czech authority v Avast, CZK 351M.
- Whether an LLM service is a processor or an independent recipient is decided case by case.

## Unknown

- Whether final versions of Guidelines 01/2025 and 02/2026 exist: none found.
- Guidelines 02/2026 were read up to para 52; the later criteria and technical analysis are not covered.
- The full text of the SRB judgment was not read, only the press release and the EDPB citations.
- No regulator statement aimed at software tools was found; the claim rule above follows from para 40 and the enforcement cases.

## Sources

- https://www.edpb.europa.eu/system/files/2026-07/edpb_guidelines_202602_anonymisation_v1_en_0.pdf (2026-07-07): the paragraphs above
- https://www.edpb.europa.eu/documents/guideline/guidelines-022026-on-anonymisation_en (2026-07-08): consultation closed, no final version shown
- https://www.edpb.europa.eu/system/files/2025-01/edpb_guidelines_202501_pseudonymisation_en.pdf (2025-01-16): consultation version
- https://curia.europa.eu/jcms/upload/docs/application/pdf/2025-09/cp250107en.pdf (2025-09-04): press release on C-413/23 P
- https://www.addleshawgoddard.com/en/insights/insights-briefings/2026/data-protection/eu-digital-omnibus-european-council-adopts-its-position/ (2026-10-26): Council position
- https://www.stephensonharwood.com/insights/anonymisation-through-the-eyes-of-the-french-data-protection-authority-lessons-from-the-cnil-s-5-million-decision-july-2026/ (July 2026): CNIL decision, secondary
