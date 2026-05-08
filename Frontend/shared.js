/* ============================================================
   SHARED.JS - BeamWorks
   Shared functionality across all pages:
   - Supabase data loading
   - Navigation injection
   - Cart (localStorage)
   - Product card rendering
   - Scroll header
   ============================================================ */

// --- GLOBAL DATA ---
let PRODUCTS_DB = [];
let ACTIVE_PROMO = null;
let PROMO_PRODUCT_IDS = new Set();

// ===================== INITIALIZATION =====================

async function sharedInit() {
    injectNav();
    injectCartModal();
    injectFloatingCheckout();
    await loadProductsFromDB();
    await loadPromotionFromDB();
    updateCartCount();
    renderCart();
    initScrollHeader();
}

// ===================== NAV / FOOTER / CART MODAL INJECTION =====================

function injectNav() {
    const nav = document.createElement('nav');
    nav.innerHTML = `
        <div class="container nav-inner">
            <a class="logo" href="index.html">BeamWorks</a>
            <div class="nav-links">
                <a href="index.html">Home</a>
                <a href="shop.html">Collection</a>
                <span style="position:relative; margin-left:40px; cursor:pointer;" onclick="toggleCart()">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M6 6h15l-1.5 9h-13z" stroke="#2C2C2C" stroke-width="2" fill="none"/>
                        <circle cx="9" cy="21" r="1.5" fill="#D4AF37"/>
                        <circle cx="18" cy="21" r="1.5" fill="#D4AF37"/>
                    </svg>
                    <span id="cart-count" style="position:absolute; top:-8px; right:-8px; background:var(--accent); color:white; border-radius:50%; width:18px; height:18px; display:flex; align-items:center; justify-content:center; font-size:11px;">0</span>
                </span>
            </div>
        </div>
    `;
    document.body.prepend(nav);
}

function injectFooter() {
    const footer = document.createElement('footer');
    footer.innerHTML = `
        <div class="container footer-inner">
            <div>
                <div class="footer-logo">BeamWorks</div>
                <p style="font-size: 13px; color: var(--text-muted); max-width: 300px;">
                    Modern lighting designed to transform your living space.
                </p>
            </div>
            <div>
                <h4 class="filter-title">Studio</h4>
                <ul class="filter-list">
                    <li>Our Story</li>
                    <li>Contact</li>
                </ul>
            </div>
            <div>
                <h4 class="filter-title">Connect</h4>
                <ul class="filter-list">
                    <li>Instagram</li>
                    <li>Pinterest</li>
                </ul>
            </div>
        </div>
    `;
    document.body.appendChild(footer);
}

function injectCartModal() {
    const overlay = document.createElement('div');
    overlay.className = 'cart-modal-overlay';
    overlay.id = 'cart-overlay';
    overlay.setAttribute('onclick', 'closeCart()');

    const modal = document.createElement('div');
    modal.className = 'cart-modal';
    modal.id = 'cart-modal';
    modal.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 15px; margin-bottom: 30px;">
            <h3 class="cart-title" style="margin: 0; flex: 1;">Your Cart</h3>
            <button class="cart-close-btn" onclick="closeCart()" style="margin-top: -5px;">&times;</button>
        </div>
        <div id="cart-items-container" style="flex: 1;"></div>
        <div class="cart-footer">
            <div class="cart-subtotal">
                <span class="cart-subtotal-label">Subtotal</span>
                <span class="cart-subtotal-amount" id="cart-subtotal">R0.00</span>
            </div>
            <div class="cart-shipping-note">Shipping calculated at checkout</div>
            <button class="cart-checkout-btn" onclick="proceedToCheckout()">Proceed to Checkout</button>
        </div>
    `;

    document.body.appendChild(overlay);
    document.body.appendChild(modal);
}

function injectFloatingCheckout() {
    const btn = document.createElement('button');
    btn.className = 'checkout-btn';
    btn.id = 'checkout-btn';
    btn.setAttribute('onclick', 'proceedToCheckout()');
    btn.textContent = 'Proceed to Checkout';
    document.body.appendChild(btn);
}

// ===================== SUPABASE DATA LOADING =====================

async function loadProductsFromDB() {
    try {
        const { data: products, error } = await window.supabase
            .from('products')
            .select('*, product_images(*)')
            .order('created_at', { ascending: true });

        if (error || !products) {
            console.warn('Supabase products fetch failed:', error);
            PRODUCTS_DB = [];
            return;
        }

        PRODUCTS_DB = products.map(p => {
            const sortedImgs = (p.product_images || []).sort((a, b) => a.display_order - b.display_order);
            return {
                id: p.id,
                name: p.name,
                price: parseFloat(p.price),
                category: p.category,
                images: sortedImgs.map(img => img.image_url),
                status: p.status || 'active',
                desc: p.description || ''
            };
        });
    } catch (err) {
        console.warn('Could not connect to Supabase:', err);
        PRODUCTS_DB = [];
    }
}

async function loadPromotionFromDB() {
    try {
        const { data } = await window.supabase
            .from('promotions')
            .select('*, promotion_products(product_id)')
            .eq('is_active', true)
            .limit(1)
            .single();

        if (data) {
            ACTIVE_PROMO = data;
            PROMO_PRODUCT_IDS = new Set((data.promotion_products || []).map(pp => pp.product_id));
        } else {
            ACTIVE_PROMO = null;
            PROMO_PRODUCT_IDS.clear();
        }
    } catch (err) {
        console.warn('Could not load promotions:', err);
        ACTIVE_PROMO = null;
    }
}

async function loadHeroFromDB() {
    try {
        const heroEl = document.getElementById('hero-section');
        if (!heroEl) return;

        const { data } = await window.supabase.from('site_settings').select('*');
        const settings = {};
        if (data) data.forEach(s => { settings[s.setting_key] = s.setting_value; });

        if (settings.hero_visible !== 'true') {
            heroEl.classList.remove('active', 'loaded');
            return;
        }

        const heroH2 = heroEl.querySelector('.hero-content h2');
        const heroBtn = heroEl.querySelector('.hero-content .btn');

        if (settings.hero_image_url) {
            heroEl.style.backgroundImage = `url('${settings.hero_image_url}')`;
        }

        const heading = settings.hero_heading || (ACTIVE_PROMO ? ACTIVE_PROMO.name : 'Featured');
        if (heroH2) heroH2.textContent = heading;

        if (settings.hero_button_text && heroBtn) {
            heroBtn.textContent = settings.hero_button_text;
        } else if (heroBtn) {
            heroBtn.textContent = 'View Collection';
        }

        if (settings.hero_text_color && heroH2) {
            heroH2.style.color = settings.hero_text_color;
        }
        if (settings.hero_text_size && heroH2) {
            heroH2.style.fontSize = parseInt(settings.hero_text_size) + 'px';
        }

        // Set button destination based on active promotion
        if (heroBtn) {
            if (ACTIVE_PROMO && PROMO_PRODUCT_IDS.size > 0) {
                heroBtn.href = 'promotions.html';
            } else {
                heroBtn.href = 'shop.html';
            }
        }

        heroEl.classList.add('active');
        requestAnimationFrame(() => {
            heroEl.classList.add('loaded');
        });
    } catch (err) {
        console.warn('Could not load hero settings:', err);
    }
}

// ===================== PRODUCT CARD RENDERING =====================

function getDiscountedPrice(product) {
    if (ACTIVE_PROMO && ACTIVE_PROMO.discount_percentage > 0 && PROMO_PRODUCT_IDS.has(product.id)) {
        return product.price * (1 - ACTIVE_PROMO.discount_percentage / 100);
    }
    return null;
}

function createProductCard(p) {
    const discounted = getDiscountedPrice(p);
    const isSoldOut = p.status === 'sold_out';

    let priceHtml;
    if (discounted !== null) {
        priceHtml = `<span class="product-price-original">R ${p.price}</span><br><span class="product-price-discount">R ${discounted.toFixed(2)}</span>`;
    } else {
        priceHtml = `<span class="product-price">R ${p.price}</span>`;
    }

    return `
        <a class="product-card" href="product.html?id=${p.id}" style="${isSoldOut ? 'opacity: 0.6;' : ''}">
            <div class="product-image" style="position:relative;">
                ${isSoldOut ? '<div class="product-sold-out">Sold Out</div>' : ''}
                <img src="${p.images[0]}" alt="${p.name}">
            </div>
            <div class="product-info">
                <div>
                    <h4 class="product-name">${p.name}</h4>
                    <p style="font-size: 10px; color: var(--text-muted);">${p.category}</p>
                </div>
                ${priceHtml}
            </div>
        </a>
    `;
}

// ===================== CART (localStorage) =====================

function getCart() {
    try {
        return JSON.parse(localStorage.getItem('beamworks_cart') || '{}');
    } catch {
        return {};
    }
}

function saveCart(cartData) {
    localStorage.setItem('beamworks_cart', JSON.stringify(cartData));
}

function addToCart(productId) {
    const cart = getCart();
    cart[productId] = (cart[productId] || 0) + 1;
    saveCart(cart);
    updateCartCount();
    renderCart();
    openCart();
}

function updateQuantity(productId, change) {
    const cart = getCart();
    cart[productId] = (cart[productId] || 0) + change;
    if (cart[productId] <= 0) {
        delete cart[productId];
    }
    saveCart(cart);
    updateCartCount();
    renderCart();
}

function updateCartCount() {
    const cart = getCart();
    const totalItems = Object.values(cart).reduce((sum, qty) => sum + qty, 0);
    const el = document.getElementById('cart-count');
    if (el) el.textContent = totalItems;
}

function renderCart() {
    const container = document.getElementById('cart-items-container');
    if (!container) return;

    const cart = getCart();
    const cartItems = Object.keys(cart);

    if (cartItems.length === 0) {
        container.innerHTML = '<div class="cart-empty">Your cart is empty</div>';
        const subtotalEl = document.getElementById('cart-subtotal');
        if (subtotalEl) subtotalEl.textContent = 'R0.00';
        toggleCheckoutButton();
        return;
    }

    let subtotal = 0;
    container.innerHTML = cartItems.map(productId => {
        const product = PRODUCTS_DB.find(p => p.id === parseInt(productId));
        if (!product) return '';
        const quantity = cart[productId];
        const discountedPrice = getDiscountedPrice(product);
        const finalPrice = discountedPrice || product.price;
        const totalPrice = finalPrice * quantity;
        const originalTotalPrice = product.price * quantity;
        subtotal += totalPrice;

        let priceHtml;
        if (discountedPrice !== null) {
            priceHtml = `<span class="product-price-original">R${originalTotalPrice.toFixed(2)}</span><br><span class="product-price-discount">R${totalPrice.toFixed(2)}</span>`;
        } else {
            priceHtml = `<span class="cart-item-price">R${totalPrice.toFixed(2)}</span>`;
        }

        return `
            <div class="cart-item">
                <div class="cart-item-img">
                    <img src="${product.images[0]}" alt="${product.name}">
                </div>
                <div class="cart-item-info">
                    <div class="cart-item-name">${product.name}</div>
                    <div class="cart-item-category">${product.category}</div>
                    <div class="cart-item-price">${priceHtml}</div>
                    <div class="quantity-control">
                        <button onclick="updateQuantity(${product.id}, -1)">−</button>
                        <span>${quantity}</span>
                        <button onclick="updateQuantity(${product.id}, 1)">+</button>
                    </div>
                </div>
            </div>
        `;
    }).join('');

    const subtotalEl = document.getElementById('cart-subtotal');
    if (subtotalEl) subtotalEl.textContent = 'R' + subtotal.toFixed(2);
    toggleCheckoutButton();
}

function openCart() {
    const modal = document.getElementById('cart-modal');
    const overlay = document.getElementById('cart-overlay');
    if (modal) modal.classList.add('open');
    if (overlay) overlay.classList.add('open');
}

function closeCart() {
    const modal = document.getElementById('cart-modal');
    const overlay = document.getElementById('cart-overlay');
    if (modal) modal.classList.remove('open');
    if (overlay) overlay.classList.remove('open');
}

function toggleCart() {
    const cartModal = document.getElementById('cart-modal');
    if (cartModal && cartModal.classList.contains('open')) {
        closeCart();
    } else {
        openCart();
    }
}

function toggleCheckoutButton() {
    const cart = getCart();
    const totalItems = Object.values(cart).reduce((sum, qty) => sum + qty, 0);
    const floatingBtn = document.getElementById('checkout-btn');
    const modalBtn = document.querySelector('.cart-checkout-btn');
    const isOnCheckout = window.location.pathname.includes('checkout');

    if (totalItems > 0 && !isOnCheckout) {
        if (floatingBtn) floatingBtn.classList.add('show');
        if (modalBtn) modalBtn.style.display = 'block';
    } else {
        if (floatingBtn) floatingBtn.classList.remove('show');
        if (modalBtn) modalBtn.style.display = 'none';
    }
}

function proceedToCheckout() {
    closeCart();
    window.location.href = 'tempCheckout.html';
}

// ===================== SCROLL HEADER =====================

let lastScrollTop = 0;
let navHeight = 60;

function initScrollHeader() {
    window.addEventListener('scroll', function() {
        let currentScroll = window.pageYOffset || document.documentElement.scrollTop;
        const nav = document.querySelector('nav');
        if (!nav) return;
        let scrollDelta = currentScroll - lastScrollTop;
        let currentTranslate = parseFloat(nav.style.transform.match(/-?\d+/)?.[0] || 0);
        let newTranslate = currentTranslate - scrollDelta;
        newTranslate = Math.max(-navHeight, Math.min(0, newTranslate));
        nav.style.transform = `translateY(${newTranslate}px)`;
        lastScrollTop = currentScroll <= 0 ? 0 : currentScroll;
    });
}
