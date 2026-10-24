# V22 — UPI-only checkout and returns policy update

- Removed Cash on Delivery selection, copy, settings controls, FAQ references, shipping policy section, and COD-specific checkout logic.
- Checkout now creates UPI orders only and marks them `PENDING_MANUAL_VERIFICATION`.
- Removed the mandatory Terms & Conditions checkbox and its client-side validation. The Terms & Conditions page and footer links remain.
- Added a mandatory unboxing-video evidence section to Returns & Refunds, with a qualification for applicable consumer protection laws and statutory rights.
- Updated payment descriptions across public pages and admin order labels.
- Existing localStorage order storage remains unchanged; this is not a shared production order system and payment is not automatically verified.
