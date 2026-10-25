/* TAVISH & CO. customer account: Supabase Auth, profile data and private order history. */
(function () {
  'use strict';
  var cfg = window.TAVISH_SUPABASE_CONFIG;
  var status = document.querySelector('[data-auth-status]');
  var signedOut = document.querySelector('[data-auth-panel="signed-out"]');
  var signedIn = document.querySelector('[data-auth-panel="signed-in"]');
  var profileForm = document.querySelector('[data-profile-form]');
  var orderBox = document.querySelector('[data-account-orders]');
  if (!window.supabase || !cfg || !cfg.url || !cfg.publishableKey) {
    if (status) { status.textContent = 'Secure account service is unavailable. Refresh the page or continue as a guest.'; status.hidden = false; }
    return;
  }
  var sb = window.supabase.createClient(cfg.url, cfg.publishableKey);
  var currentUser = null;
  function message(text, kind) {
    if (!status) return;
    status.textContent = text;
    status.dataset.kind = kind || 'info';
    status.hidden = false;
  }
  function escapeHtml(value) {
    return String(value == null ? '' : value).replace(/[&<>"']/g, function (c) {
      return ({ '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;' })[c];
    });
  }
  function formatDate(value) {
    try { return new Date(value).toLocaleDateString('en-IN', { day:'2-digit', month:'short', year:'numeric' }); }
    catch (e) { return value || '—'; }
  }
  function money(paise) {
    return '₹' + (Number(paise || 0) / 100).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }
  function selectTab(tab) {
    document.querySelectorAll('[data-auth-tab]').forEach(function (button) {
      var active = button.getAttribute('data-auth-tab') === tab;
      button.classList.toggle('is-active', active);
      button.setAttribute('aria-selected', active ? 'true' : 'false');
    });
    document.querySelectorAll('[data-auth-form]').forEach(function (form) {
      form.hidden = form.getAttribute('data-auth-form') !== tab;
    });
  }
  document.querySelectorAll('[data-auth-tab]').forEach(function (button) {
    button.addEventListener('click', function () { selectTab(button.getAttribute('data-auth-tab')); });
  });
  async function loadOrders(user) {
    if (!orderBox) return;
    orderBox.textContent = 'Loading your orders…';
    var result = await sb.from('orders')
      .select('order_number,total_paise,payment_status,fulfillment_status,created_at')
      .eq('user_id', user.id).order('created_at', { ascending:false }).limit(20);
    if (result.error) {
      orderBox.textContent = 'Order history could not be loaded. Guest orders are not automatically attached to an account.';
      return;
    }
    if (!result.data || !result.data.length) {
      orderBox.innerHTML = '<p class="account-small">No orders linked to this account yet. Guest orders are not automatically attached.</p>';
      return;
    }
    orderBox.innerHTML = '<div class="account-order-list">' + result.data.map(function (order) {
      return '<article class="account-order" style="padding:12px 0;border-bottom:1px solid #e7dfd3"><b>' +
        escapeHtml(order.order_number) + '</b><div class="account-small">' + escapeHtml(formatDate(order.created_at)) +
        ' · ' + escapeHtml(order.fulfillment_status) + ' · Payment ' + escapeHtml(order.payment_status) +
        '</div><strong>' + escapeHtml(money(order.total_paise)) + '</strong></article>';
    }).join('') + '</div>';
  }
  async function showSession(user) {
    currentUser = user || null;
    if (!user) {
      if (signedIn) signedIn.hidden = true;
      if (signedOut) signedOut.hidden = false;
      if (status) status.hidden = true;
      return;
    }
    if (signedOut) signedOut.hidden = true;
    if (signedIn) signedIn.hidden = false;
    var emailNode = document.querySelector('[data-account-email]');
    if (emailNode) emailNode.textContent = user.email || '';
    if (profileForm) {
      var profile = await sb.from('profiles').select('display_name,phone').eq('id', user.id).maybeSingle();
      if (!profile.error && profile.data) {
        var name = profileForm.querySelector('[name="full_name"]');
        var phone = profileForm.querySelector('[name="phone"]');
        if (name) name.value = profile.data.display_name || (user.user_metadata && user.user_metadata.full_name) || '';
        if (phone) phone.value = profile.data.phone || '';
      }
    }
    await loadOrders(user);
    message('You are signed in. Your profile and any orders placed while signed in can sync across devices.', 'success');
  }
  document.querySelectorAll('[data-auth-form]').forEach(function (form) {
    form.addEventListener('submit', async function (event) {
      event.preventDefault();
      var type = form.getAttribute('data-auth-form');
      var email = String((form.querySelector('[name="email"]') || {}).value || '').trim();
      var password = String((form.querySelector('[name="password"]') || {}).value || '');
      if (!email || !password) { message('Enter your email address and password.', 'error'); return; }
      var button = form.querySelector('button[type="submit"]');
      var original = button ? button.textContent : '';
      if (button) { button.disabled = true; button.textContent = 'Please wait…'; }
      try {
        var result;
        if (type === 'signin') {
          result = await sb.auth.signInWithPassword({ email: email, password: password });
        } else {
          var fullName = String((form.querySelector('[name="full_name"]') || {}).value || '').trim();
          result = await sb.auth.signUp({
            email: email, password: password,
            options: { data: { full_name: fullName }, emailRedirectTo: new URL('account.html', window.location.href).href }
          });
        }
        if (result.error) throw result.error;
        if (type === 'signup' && result.data && result.data.user && !result.data.session) {
          message('Account created. Check your email for a confirmation link, then return here and sign in.', 'success');
        } else if (result.data && result.data.user) {
          await showSession(result.data.user);
          message(type === 'signup' ? 'Account created and signed in.' : 'Signed in successfully.', 'success');
        }
      } catch (error) {
        message((type === 'signup' ? 'Account creation failed: ' : 'Sign in failed: ') + (error.message || String(error)), 'error');
      } finally {
        if (button) { button.disabled = false; button.textContent = original; }
      }
    });
  });
  document.querySelectorAll('[data-auth-action]').forEach(function (button) {
    button.addEventListener('click', async function () {
      var action = button.getAttribute('data-auth-action');
      try {
        if (action === 'signout') {
          var result = await sb.auth.signOut();
          if (result.error) throw result.error;
          await showSession(null);
          message('You have signed out.', 'success');
        } else if (action === 'forgot') {
          var emailInput = document.querySelector('[data-auth-form="signin"] [name="email"]');
          var email = String(emailInput ? emailInput.value : '').trim();
          if (!email) { message('Enter your email address first, then choose Forgot your password.', 'error'); return; }
          var reset = await sb.auth.resetPasswordForEmail(email, { redirectTo: new URL('account.html?recovery=1', window.location.href).href });
          if (reset.error) throw reset.error;
          message('If an account exists for this email, a password reset link will be sent.', 'success');
        } else if (action === 'google') {
          var oauth = await sb.auth.signInWithOAuth({ provider: 'google', options: { redirectTo: new URL('account.html', window.location.href).href } });
          if (oauth.error) throw oauth.error;
        }
      } catch (error) {
        message((action === 'google' ? 'Google sign-in may need to be enabled in Supabase Auth providers. ' : '') + (error.message || String(error)), 'error');
      }
    });
  });
  if (profileForm) {
    profileForm.addEventListener('submit', async function (event) {
      event.preventDefault();
      if (!currentUser) { message('Sign in before saving your profile.', 'error'); return; }
      var fullName = String(profileForm.querySelector('[name="full_name"]').value || '').trim();
      var phone = String(profileForm.querySelector('[name="phone"]').value || '').trim();
      var result = await sb.from('profiles').update({ display_name: fullName, phone: phone, updated_at: new Date().toISOString() }).eq('id', currentUser.id);
      if (result.error) message('Profile was not saved: ' + result.error.message + '. Apply the customer account migration if the profile fields are not ready.', 'error');
      else message('Profile saved securely.', 'success');
    });
  }
  sb.auth.onAuthStateChange(function (event, session) {
    window.setTimeout(function () {
      showSession(session && session.user ? session.user : null).catch(function (error) {
        message('Account status could not be refreshed: ' + (error.message || String(error)), 'error');
      });
    }, 0);
  });
  sb.auth.getSession().then(function (result) {
    if (result.error) message('Session lookup failed: ' + result.error.message, 'error');
    else showSession(result.data.session ? result.data.session.user : null);
  }).catch(function (error) { message('Account initialization failed: ' + error.message, 'error'); });
})();
