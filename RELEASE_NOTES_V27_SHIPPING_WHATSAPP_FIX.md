# V27 — Shipping Announcement and WhatsApp Enquiry Fix

- Added a one-time settings migration for existing browsers so a saved legacy ₹2,499 free-shipping threshold is migrated to ₹999. Other custom thresholds are preserved.
- Generic WhatsApp enquiry links now use the requested direct wa.me URL with the jewellery enquiry message prefilled. Product-specific and order-specific WhatsApp flows remain dynamic.
- Updated public-facing WhatsApp number display to `91379 61623`.

Validation: JavaScript syntax checks and ZIP integrity check performed. Test after deployment with a hard refresh; browser storage migration runs on the next site load.
