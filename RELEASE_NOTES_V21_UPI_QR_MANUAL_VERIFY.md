# V21 — Order-specific UPI QR with manual verification

- Added order-specific UPI QR checkout alongside the then-existing Cash on Delivery option.
- Generates a UPI URI with payee `9921318679@yespop`, exact INR order total, and unique order reference; renders QR using QRCode.js.
- UPI order is marked `PENDING_MANUAL_VERIFICATION`; admin can mark paid only after confirming the funds independently.
- This is a static/localStorage implementation: orders and payment status are not transmitted to a shared database, and payment is not automatically verified. Admin login remains client-side and is not secure for production.
- QR code and deep-link behavior varies by UPI app. Test with a small amount and confirm payee/amount before production use.
