/* * * * * SHYFOX * * * * */
// userchrome.css usercontent.css activate
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// disable new sidebar
user_pref("sidebar.revamp", false);

// Fill SVG Color
user_pref("svg.context-properties.content.enabled", true);

// Integrated calculator at urlbar
user_pref("browser.urlbar.suggest.calculator", true);

// Integrated unit convertor at urlbar
user_pref("browser.urlbar.unitConversion.enabled", true);

// GTK rounded corners
user_pref("widget.gtk.rounded-bottom-corners.enabled", false);

// Who is bogus? (fixes Sidebery tab dragging on Linux)
user_pref("widget.gtk.ignore-bogus-leave-notify", 1);

/* * * * * ARKENFOX * * * * */

/* 1003: disable storing extra session data [SETUP-CHROME]
 * define on which sites to save extra session data such as form content, cookies and POST data
 * 0=everywhere, 1=unencrypted sites, 2=nowhere ***/
user_pref("browser.sessionstore.privacy_level", 2);

/* 0103: set HOME+NEWWINDOW page
 * about:home=Firefox Home (default, see 0105), custom URL, about:blank
 * [SETTING] Home>New Windows and Tabs>Homepage and new windows ***/
user_pref("browser.startup.homepage", "about:home");

/* 0104: set NEWTAB page
 * true=Firefox Home (default, see 0105), false=blank page
 * [SETTING] Home>New Windows and Tabs>New tabs ***/
user_pref("browser.newtabpage.enabled", true);

/* 0102: set startup page [SETUP-CHROME]
 * 0=blank, 1=home, 2=last visited page, 3=resume previous session
 * [NOTE] Session Restore is cleared with history (2811), and not used in Private Browsing mode
 * [SETTING] General>Startup>Restore previous session ***/
user_pref("browser.startup.page", 3);

/* 0601: disable link prefetching
 * [1] https://developer.mozilla.org/docs/Web/HTTP/Link_prefetching_FAQ ***/
user_pref("network.prefetch-next", false);

/* 2810: enable Firefox to clear items on shutdown
 * [SETTING] Privacy & Security>History>Custom Settings>Clear history when Firefox closes | Settings ***/
user_pref("privacy.sanitize.sanitizeOnShutdown", false);

/** SANITIZE ON SHUTDOWN: IGNORES "ALLOW" SITE EXCEPTIONS | v2 migration is FF128+ ***/
/* 2811: set/enforce what items to clear on shutdown (if 2810 is true) [SETUP-CHROME]
 * [NOTE] If "history" is true, downloads will also be cleared ***/
user_pref("privacy.clearOnShutdown.cache", false);
user_pref("privacy.clearOnShutdown_v2.cache", false);
user_pref("privacy.clearOnShutdown.downloads", false);
user_pref("privacy.clearOnShutdown.formdata", false);
user_pref("privacy.clearOnShutdown.history", false);
user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", false);
user_pref("privacy.clearOnShutdown.siteSettings", false);
user_pref("privacy.clearOnShutdown_v2.siteSettings", false);

/* 2812: set Session Restore to clear on shutdown (if 2810 is true) [FF34+]
 * [NOTE] Not needed if Session Restore is not used (0102) or it is already cleared with history (2811)
 * [NOTE] If true, this prevents resuming from crashes (also see 5008) ***/
user_pref("privacy.clearOnShutdown.openWindows", false);

/** SANITIZE ON SHUTDOWN: RESPECTS "ALLOW" SITE EXCEPTIONS FF103+ | v2 migration is FF128+ ***/
/* 2815: set "Cookies" and "Site Data" to clear on shutdown (if 2810 is true) [SETUP-CHROME]
 * [NOTE] Exceptions: A "cookie" block permission also controls "offlineApps" (see note below).
 * serviceWorkers require an "Allow" permission. For cross-domain logins, add exceptions for
 * both sites e.g. https://www.youtube.com (site) + https://accounts.google.com (single sign on)
 * [NOTE] "offlineApps": Offline Website Data: localStorage, service worker cache, QuotaManager (IndexedDB, asm-cache)
 * [NOTE] "sessions": Active Logins (has no site exceptions): refers to HTTP Basic Authentication [1], not logins via cookies
 * [WARNING] Be selective with what sites you "Allow", as they also disable partitioning (1767271)
 * [SETTING] to add site exceptions: Ctrl+I>Permissions>Cookies>Allow (when on the website in question)
 * [SETTING] to manage site exceptions: Options>Privacy & Security>Permissions>Settings
 * [1] https://en.wikipedia.org/wiki/Basic_access_authentication ***/
user_pref("privacy.clearOnShutdown.cookies", false);
user_pref("privacy.clearOnShutdown.offlineApps", false);
user_pref("privacy.clearOnShutdown.sessions", false);
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);

/** SANITIZE SITE DATA: IGNORES "ALLOW" SITE EXCEPTIONS ***/
/* 2820: set manual "Clear Data" items [SETUP-CHROME] [FF128+]
 * Firefox remembers your last choices. This will reset them when you start Firefox
 * [SETTING] Privacy & Security>Browser Privacy>Cookies and Site Data>Clear Data ***/
user_pref("privacy.clearSiteData.cache", false);
user_pref("privacy.clearSiteData.cookiesAndStorage", false);
user_pref("privacy.clearSiteData.historyFormDataAndDownloads", false);
user_pref("privacy.clearSiteData.siteSettings", false);

/* 0801: disable location bar using search
 * Don't leak URL typos to a search engine, give an error message instead
 * Examples: "secretplace,com", "secretplace/com", "secretplace com", "secret place.com"
 * [NOTE] This does not affect explicit user action such as using search buttons in the
 * dropdown, or using keyword search shortcuts you configure in options (e.g. "d" for DuckDuckGo)
 * [SETUP-CHROME] Override this if you trust and use a privacy respecting search engine ***/
user_pref("keyword.enabled", true);

/* 4501: enable privacy.resistFingerprinting [FF41+]
 * [SETUP-WEB] RFP can cause some website breakage: mainly canvas, use a site exception via the urlbar
 * RFP also has a few side effects: mainly timezone is UTC0, and websites will prefer light theme
 * [1] https://bugzilla.mozilla.org/418986 ***/
user_pref("privacy.resistFingerprinting", false);

/* 4504: enable RFP letterboxing [FF67+]
 * Dynamically resizes the inner window by applying margins in stepped ranges [2]
 * If you use the dimension pref, then it will only apply those resolutions.
 * The format is "width1xheight1, width2xheight2, ..." (e.g. "800x600, 1000x1000")
 * [SETUP-WEB] This is independent of RFP (4501). If you're not using RFP, or you are but
 * dislike the margins, then flip this pref, keeping in mind that it is effectively fingerprintable
 * [WARNING] DO NOT USE: the dimension pref is only meant for testing
 * [1] https://bugzilla.mozilla.org/1407366
 * [2] https://hg.mozilla.org/mozilla-central/rev/6d2d7856e468#l2.32 ***/
user_pref("privacy.resistFingerprinting.letterboxing", false);

/* 4510: disable using system colors
 * [SETTING] General>Language and Appearance>Fonts and Colors>Colors>Use system colors ***/
user_pref("browser.display.use_system_colors", true);

user_pref("_user.js.parrot", "SUCCESS: Custom JS loaded");

/* * * * * BETTERFOX * * * * */

// PREF: Font rendering cache in Skia (32MB)
// Increases font cache size to improve performance on text-heavy websites.
// Especially beneficial for sites with many font faces or complex typography.
// [1] https://bugzilla.mozilla.org/show_bug.cgi?id=1239151#c2
user_pref("gfx.content.skia-font-cache-size", 32); // 32 MB; default=5; Chrome=20

// PREF: GPU-accelerated Canvas2D
// Uses Accelerated Canvas2D for hardware acceleration of Canvas2D.
// This provides a consistent acceleration architecture across all platforms
// by utilizing WebGL instead of relying upon Direct2D.
// [WARNING] May cause issues on some Windows machines using integrated GPUs [2] [3]
// Add to your overrides if you have a dedicated GPU.
// [NOTE] Higher values will use more memory.
// [1] https://bugzilla.mozilla.org/show_bug.cgi?id=1741501
// [2] https://github.com/yokoffing/Betterfox/issues/153
// [3] https://github.com/yokoffing/Betterfox/issues/198
//user_pref("gfx.canvas.accelerated", true); // [DEFAULT FF133+]
user_pref("gfx.canvas.accelerated.cache-items", 16384); // [default=8192 FF135+]; Chrome=4096
user_pref("gfx.canvas.accelerated.cache-size", 1024); // default=256; Chrome=512
//user_pref("gfx.canvas.max-size", 32767); // DEFAULT=32767

// PREF: memory cache
// The "automatic" size selection (default) is based on a decade-old table
// that only contains settings for systems at or below 8GB of system memory [1].
// Waterfox G6 allows it to go above 8GB machines [3].
// Value can be up to the max size of an unsigned 64-bit integer.
// -1 = Automatically decide the maximum memory to use to cache decoded images,
// messages, and chrome based on the total amount of RAM
// For machines with 8GB+ RAM, that equals 32768 kb = 32 MB
// [1] https://kb.mozillazine.org/Browser.cache.memory.capacity#-1
// [2] https://searchfox.org/mozilla-central/source/netwerk/cache2/CacheObserver.cpp#94-125
// [3] https://github.com/WaterfoxCo/Waterfox/commit/3fed16932c80a2f6b37d126fe10aed66c7f1c214
user_pref("browser.cache.memory.capacity", 131072); // 128 MB RAM cache; alt=65536 (65 MB RAM cache); default=32768
user_pref("browser.cache.memory.max_entry_size", 20480); // 20 MB max entry; default=5120 (5 MB)

// PREF: image cache
user_pref("image.cache.size", 10485760); // (cache images up to 10MiB in size) [DEFAULT 5242880]
user_pref("image.mem.decode_bytes_at_a_time", 65536); // default=16384; alt=32768; chunk size for calls to the image decoders
//user_pref("image.mem.max_decoded_image_kb", 512000); // 500MB [HIDDEN OR REMOVED?]

// PREF: increase the absolute number of HTTP connections
// [1] https://kb.mozillazine.org/Network.http.max-connections
// [2] https://kb.mozillazine.org/Network.http.max-persistent-connections-per-server
// [3] https://www.reddit.com/r/firefox/comments/11m2yuh/how_do_i_make_firefox_use_more_of_my_900_megabit/jbfmru6/
user_pref("network.http.max-connections", 1000); // default=900
user_pref("network.http.max-persistent-connections-per-server", 10); // default=6; download connections; anything above 10 is excessive
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5); // default=3
//user_pref("network.http.max-persistent-connections-per-proxy", 48); // default=32
user_pref("network.http.request.max-start-delay", 5); // default=10
//user_pref("network.websocket.max-connections", 200); // DEFAULT

// PREF: increase DNS cache
// [1] https://developer.mozilla.org/en-US/docs/Web/Performance/Understanding_latency
user_pref("network.dnsCacheEntries", 800); // default=800
