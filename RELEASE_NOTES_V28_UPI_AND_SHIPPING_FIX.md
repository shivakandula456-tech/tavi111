# V28 — UPI ID and shipping threshold fix

- Updated the UPI payee identifier used by order-specific UPI payment URIs/QR codes to `tanvianikhindi281-1@okicici`.
- Bumped the browser settings seed migration version so existing browsers are migrated from a saved legacy ₹2,499 free-shipping threshold to ₹999.
- Preserved the existing ₹99 shipping fee for orders below ₹999; orders of ₹999 and above qualify for free shipping.
- No other design or checkout behavior was intentionally changed.

Validation performed: checked the changed JavaScript files with Node syntax checks; searched the source for the previous UPI payee in executable code; verified the ZIP archive integrity. Live UPI payment and browser visual testing were not performed.
