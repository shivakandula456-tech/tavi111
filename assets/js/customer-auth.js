/* TAVISH & CO. account page: browser-only architecture has no customer authentication service. */
(function () {
  'use strict';
  var status = document.querySelector('[data-auth-status]');
  var signedOut = document.querySelector('[data-auth-panel="signed-out"]');
  var signedIn = document.querySelector('[data-auth-panel="signed-in"]');
  if (signedIn) signedIn.hidden = true;
  if (signedOut) {
    signedOut.innerHTML = '<h2 class="account-subtitle">Continue as a guest</h2>' +
      '<p class="account-intro">This static website does not create online customer accounts. Checkout remains available without registration.</p>' +
      '<a class="btn btn--gold btn--block" href="cart.html">Continue to checkout</a>';
  }
  if (status) {
    status.textContent = 'Customer accounts and password sign-in are not available in this browser-only version. You can still shop and check out as a guest.';
    status.dataset.kind = 'info';
    status.hidden = false;
  }
})();
