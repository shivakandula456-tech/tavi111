/*!
 * TAVISH & CO. — shared Supabase catalogue bootstrap for GitHub Pages.
 * Seeds/localStorage remain a fallback only; Supabase is the shared public catalogue.
 */
(function (window, document) {
  'use strict';

  var boot = document.currentScript;
  var moduleList = String(boot && boot.getAttribute('data-page-modules') || 'site.js,shopping-enhancements-v10.js')
    .split(',').map(function (s) { return s.trim(); }).filter(Boolean);
  var store = window.TavishStore;
  var config = window.TAVISH_SUPABASE_CONFIG;

  function parse(raw, fallback) {
    try { return raw ? JSON.parse(raw) : fallback; } catch (e) { return fallback; }
  }
  function absoluteAsset(path) {
    if (!path) return '';
    if (/^(https?:|data:|blob:)/i.test(path)) return path;
    if (String(path).indexOf('assets/') === 0 || String(path).indexOf('./assets/') === 0) {
      return new URL(String(path).replace(/^\.\//, ''), window.location.href).href;
    }
    return '';
  }
  function storageUrl(client, path) {
    if (!path) return '';
    var asset = absoluteAsset(path);
    if (asset) return asset;
    if (/^https?:/i.test(path)) return path;
    return client.storage.from('product-images').getPublicUrl(path).data.publicUrl;
  }
  function stableId(uuid, seedProduct) {
    if (seedProduct && seedProduct.id !== undefined) return seedProduct.id;
    var hex = String(uuid || '').replace(/[^a-f0-9]/gi, '').slice(0, 12);
    var id = parseInt(hex || '0', 16);
    return Number.isSafeInteger(id) && id > 0 ? id : Date.now();
  }
  function deepMerge(base, over) {
    var out = JSON.parse(JSON.stringify(base || {}));
    Object.keys(over || {}).forEach(function (key) {
      var a = out[key], b = over[key];
      if (a && b && typeof a === 'object' && typeof b === 'object' && !Array.isArray(a) && !Array.isArray(b)) out[key] = deepMerge(a, b);
      else out[key] = b;
    });
    return out;
  }
  function archiveLocalOnly(localProducts, cloudProducts, localCategories, cloudCategories) {
    var cloudSkus = {};
    cloudProducts.forEach(function (p) { cloudSkus[String(p.sku || '').toLowerCase()] = true; });
    var extras = localProducts.filter(function (p) { return p && p.sku && !cloudSkus[String(p.sku).toLowerCase()]; });
    var cloudSlugs = {};
    cloudCategories.forEach(function (c) { cloudSlugs[String(c.slug || '').toLowerCase()] = true; });
    var extraCats = localCategories.filter(function (c) { return c && c.slug && !cloudSlugs[String(c.slug).toLowerCase()]; });
    if (!extras.length && !extraCats.length) return true;
    var key = 'tavish_pre_supabase_archive_v1';
    var existing = parse(localStorage.getItem(key), null);
    if (existing && existing.products && existing.categories) return true;
    try {
      localStorage.setItem(key, JSON.stringify({
        archivedAt: new Date().toISOString(),
        note: 'Local-only records kept before switching the active catalogue read path to Supabase. Not automatically imported or deleted.',
        products: extras,
        categories: extraCats
      }));
      return true;
    } catch (e) {
      console.warn('[TAVISH] Could not archive local-only products; retaining local catalogue fallback.', e);
      return false;
    }
  }
  function showNotice(message) {
    window.TAVISH_CLOUD_BOOTSTRAP_STATUS = message;
    console.warn('[TAVISH Cloud]', message);
    document.addEventListener('DOMContentLoaded', function () {
      var n = document.createElement('div');
      n.setAttribute('role', 'status');
      n.style.cssText = 'position:fixed;z-index:99999;left:12px;right:12px;bottom:12px;padding:12px 16px;background:#211d19;color:#fff;border:1px solid #c9a04a;border-radius:8px;font:14px/1.45 Arial,sans-serif;box-shadow:0 8px 28px #0002';
      n.textContent = message;
      document.body.appendChild(n);
      window.setTimeout(function () { if (n.parentNode) n.parentNode.removeChild(n); }, 9000);
    }, { once: true });
  }
  async function hydrate() {
    if (!window.supabase || !window.supabase.createClient || !config || !config.url || !config.publishableKey) {
      showNotice('Live catalogue is temporarily unavailable. Showing the bundled catalogue instead.');
      return false;
    }
    var client = window.supabase.createClient(config.url, config.publishableKey);
    window.TAVISH_SUPABASE_CLIENT = client;
    var results = await Promise.all([
      client.from('products').select('*').eq('status', 'ACTIVE').order('sort_order', { ascending: true }),
      client.from('categories').select('*').eq('visible', true).order('sort_order', { ascending: true }),
      client.from('product_images').select('product_id,storage_path,alt_text,sort_order,is_primary').order('sort_order', { ascending: true }),
      client.from('store_settings').select('key,value').eq('is_public', true)
    ]);
    var pr = results[0], cr = results[1], ir = results[2], sr = results[3];
    if (pr.error) throw new Error('Could not load the shared catalogue: ' + pr.error.message);
    if (cr.error) throw new Error('Could not load shared categories: ' + cr.error.message);
    if (!Array.isArray(pr.data) || !pr.data.length) {
      showNotice('Supabase returned no active products. Showing the bundled catalogue as a fallback.');
      return false;
    }
    if (!archiveLocalOnly(store.products.all(), pr.data, store.categories.list(), cr.data || [])) {
      showNotice('Local-only catalogue entries could not be archived safely, so the local catalogue is being retained on this browser.');
      return false;
    }

    var seedProducts = window.TAVISH_SEED_PRODUCTS || [];
    var seedBySku = {};
    seedProducts.forEach(function (p) { seedBySku[String(p.sku || '').toLowerCase()] = p; });
    var seedCats = window.TAVISH_SEED_CATEGORIES || [];
    var seedCatBySlug = {};
    seedCats.forEach(function (c) { seedCatBySlug[String(c.slug || '').toLowerCase()] = c; });
    var categoryById = {};
    var categoryBySlug = {};
    (cr.data || []).forEach(function (c) { categoryById[c.id] = c; categoryBySlug[c.slug] = c; });

    var imgsByProduct = {};
    if (!ir.error && Array.isArray(ir.data)) {
      ir.data.forEach(function (i) {
        (imgsByProduct[i.product_id] || (imgsByProduct[i.product_id] = [])).push({
          path: i.storage_path,
          url: storageUrl(client, i.storage_path),
          alt: i.alt_text || '',
          order: Number(i.sort_order || 0),
          primary: !!i.is_primary
        });
      });
    }

    var mappedProducts = pr.data.map(function (p) {
      var seed = seedBySku[String(p.sku || '').toLowerCase()] || null;
      var c = categoryById[p.category_id] || categoryBySlug[p.category_name] || null;
      var images = (imgsByProduct[p.id] || []).sort(function (a, b) {
        if (a.primary !== b.primary) return a.primary ? -1 : 1;
        return a.order - b.order;
      });
      var urls = images.map(function (i) { return i.url; }).filter(Boolean);
      if (!urls.length && seed && Array.isArray(seed.images)) urls = seed.images.map(absoluteAsset).filter(Boolean);
      // Enforce the locked publish rule: active products need at least one resolvable image.
      if (!urls.length) return null;
      var primary = images.filter(function (i) { return i.primary; })[0];
      var primaryUrl = primary ? primary.url : urls[0];
      var record = {
        id: stableId(p.id, seed),
        dbId: p.id,
        sku: p.sku || '',
        name: p.name || '',
        slug: p.slug || '',
        category: p.category_name || (c && c.name) || (seed && seed.category) || 'Accessories',
        categorySlug: (c && c.slug) || (seed && seed.categorySlug) || '',
        subcategory: p.subcategory || '',
        subcategorySlug: seed && seed.subcategorySlug || String(p.subcategory || '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, ''),
        description: p.description || '',
        price: Number(p.price_paise || 0) / 100,
        salePrice: p.sale_price_paise === null || p.sale_price_paise === undefined ? null : Number(p.sale_price_paise) / 100,
        currency: p.currency || 'INR',
        images: urls,
        styleImages: seed && Array.isArray(seed.styleImages) ? seed.styleImages.map(absoluteAsset).filter(Boolean) : [],
        primaryImage: primaryUrl,
        material: p.material || '',
        finish: p.finish || '',
        dimensions: p.dimensions || '',
        weight: p.weight || '',
        availability: p.availability || 'IN_STOCK',
        featured: !!p.featured,
        newArrival: !!p.new_arrival,
        bestSeller: !!p.best_seller,
        tags: Array.isArray(p.tags) ? p.tags : [],
        sortOrder: Number(p.sort_order || 0),
        status: p.status || 'ACTIVE',
        createdAt: p.created_at || (seed && seed.createdAt) || new Date().toISOString(),
        updatedAt: p.updated_at || (seed && seed.updatedAt) || new Date().toISOString()
      };
      return record;
    }).filter(Boolean);

    if (!mappedProducts.length) throw new Error('No active products have a usable image. Check product_images before publishing the catalogue.');

    var mappedCategories = (cr.data || []).map(function (c) {
      var seed = seedCatBySlug[String(c.slug || '').toLowerCase()];
      var image = storageUrl(client, c.image_path || (seed && seed.image) || '');
      return {
        id: seed ? seed.id : c.id,
        name: c.name || '',
        slug: c.slug || '',
        description: c.description || '',
        image: image || '',
        sortOrder: Number(c.sort_order || (seed && seed.sortOrder) || 99),
        visible: c.visible !== false,
        subcategories: Array.isArray(c.subcategories) && c.subcategories.length ? c.subcategories : (seed && seed.subcategories) || []
      };
    });

    // Preserve old per-browser settings until a setting is present in the shared DB;
    // shared values, when present, override local values.
    var settingsKey = store.KEYS && store.KEYS.settings || 'tavish_settings';
    var localSettings = parse(localStorage.getItem(settingsKey), {});
    var merged = deepMerge(window.TAVISH_SEED_SETTINGS || {}, localSettings || {});
    if (!sr.error && Array.isArray(sr.data)) {
      sr.data.forEach(function (row) { merged[row.key] = deepMerge(merged[row.key] || {}, row.value || {}); });
    }
    // Never keep legacy browser credentials in the public settings cache.
    delete merged.admin;
    if (merged.disclaimer) {
      merged.disclaimer.admin = 'Administration uses Supabase Auth with database-enforced roles.';
      merged.disclaimer.orders = 'Orders are managed through the shared store system.';
    }
    try { localStorage.setItem(settingsKey, JSON.stringify(merged)); } catch (e) {}

    store.products.write(mappedProducts);
    store.categories.save(mappedCategories);
    window.TAVISH_CLOUD_DATA = { products: mappedProducts, categories: mappedCategories, loadedAt: new Date().toISOString() };
    return true;
  }
  function loadModule(name) {
    return new Promise(function (resolve, reject) {
      var src = /^https?:\/\//i.test(name) ? name : 'assets/js/' + name.replace(/^\//, '');
      var script = document.createElement('script');
      script.src = src;
      script.async = false;
      script.onload = resolve;
      script.onerror = function () { reject(new Error('Could not load page module: ' + src)); };
      document.body.appendChild(script);
    });
  }
  async function start() {
    try {
      await hydrate();
    } catch (e) {
      console.warn('[TAVISH Cloud] Bootstrap failed; local cache remains active.', e);
      showNotice(e.message || 'Live catalogue could not be loaded. Showing the bundled catalogue instead.');
    }
    for (var i = 0; i < moduleList.length; i++) {
      try { await loadModule(moduleList[i]); }
      catch (e) { showNotice(e.message || 'A page script could not be loaded.'); }
    }
    if (window.TAVISH_CLOUD_BOOTSTRAP_STATUS && window.Tavish && window.Tavish.toast) {
      window.Tavish.toast(window.TAVISH_CLOUD_BOOTSTRAP_STATUS, 'error');
    }
  }
  start();
})(window, document);
