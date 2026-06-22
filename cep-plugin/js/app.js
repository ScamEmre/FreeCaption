// FreeCaption CEP Panel - v1.0
// Python backend (lokal) <-> CEP UI <-> ExtendScript (Premiere DOM)

(function () {
  "use strict";

  // ===== API CONFIG (lokal varsayilan, VDS icin Ayarlar'dan degisir) =====
  function normalizeUrl(u) {
    if (!u) return "";
    u = u.trim().replace(/\/$/, "");
    if (!u) return "";
    // http:// veya https:// yoksa http:// ekle (cogu kullanim plain HTTP IP)
    if (!/^https?:\/\//i.test(u)) u = "http://" + u;
    return u;
  }
  function loadApi() {
    try {
      var url = localStorage.getItem("fc_api_url");
      if (url && url.length > 0) {
        var n = normalizeUrl(url);
        // Normalize edilmis hali localStorage'a geri yaz (eski kayitlari duzelt)
        if (n !== url) { try { localStorage.setItem("fc_api_url", n); } catch (e) {} }
        return n;
      }
    } catch (e) {}
    return "http://127.0.0.1:7860";
  }
  function loadApiKey() {
    try { return localStorage.getItem("fc_api_key") || ""; } catch (e) { return ""; }
  }
  var API = loadApi();
  var API_KEY = loadApiKey();
  window.FC_API = API;
  window.FC_API_KEY = API_KEY;

  // fetch wrapper — API key header'i otomatik
  function fcFetch(path, opts) {
    opts = opts || {};
    opts.headers = opts.headers || {};
    if (API_KEY) opts.headers["X-API-Key"] = API_KEY;
    return fetch(API + path, opts);
  }
  window.FC_fetch = fcFetch;

  var cs = new CSInterface();

  var $ = function (id) { return document.getElementById(id); };

  // DOM refs
  var healthEl = $("health");
  var healthText = $("healthText");
  var seqNameEl = $("seqName");
  var selInfoEl = $("selInfo");
  var refreshBtn = $("refreshBtn");
  var clearCaptionBtn = $("clearCaptionBtn");
  var helpBtn = $("helpBtn");
  var languageSel = $("language");
  var styleSeg = $("styleSeg");
  var placementSeg = $("placementSeg");
  var outputDirMode = $("outputDirMode");
  var customDirRow = $("customDirRow");
  var customDirInput = $("customDirInput");
  var customDirBtn = $("customDirBtn");
  var autoPlaceChk = $("autoPlace");
  var generateBtn = $("generateBtn");
  var jobBox = $("jobBox");
  var jobName = $("jobName");
  var jobStatus = $("jobStatus");
  var jobStage = $("jobStage");
  var bar = $("bar");
  var jobError = $("jobError");
  var ghLink = $("ghLink");
  var webLink = $("webLink");

  // Onboarding
  var onboarding = $("onboarding");
  var obStep1Status = $("obStep1Status");
  var obClose = $("obClose");

  // State
  var lastClipInfo = null;
  var currentMaxChars = 22;
  var currentPlacement = "sequence_start";
  var projectDir = null; // Premiere proje klasoru

  // ===== ExtendScript bridge =====
  function evalJSX(fnCall) {
    return new Promise(function (resolve, reject) {
      cs.evalScript(fnCall, function (result) {
        if (result === "EvalScript error.") {
          reject(new Error("EvalScript error: " + fnCall));
          return;
        }
        try { resolve(JSON.parse(result)); }
        catch (e) { resolve(result); }
      });
    });
  }

  // ===== Settings persistence =====
  function loadSetting(key, fallback) {
    try { var v = localStorage.getItem("fc_" + key); return v === null ? fallback : v; }
    catch (e) { return fallback; }
  }
  function saveSetting(key, val) {
    try { localStorage.setItem("fc_" + key, val); } catch (e) {}
  }

  // ===== External links =====
  function openExternal(url) {
    try { cs.openURLInDefaultBrowser(url); } catch (e) { window.open(url); }
  }
  if (ghLink) ghLink.addEventListener("click", function (e) { e.preventDefault(); openExternal(ghLink.href); });
  if (webLink) webLink.addEventListener("click", function (e) { e.preventDefault(); openExternal(webLink.href); });

  // ===== Health check =====
  function checkHealth() {
    return fcFetch("/api/health", { cache: "no-store" })
      .then(function (r) { return r.json(); })
      .then(function (j) {
        healthEl.classList.add("ok");
        healthEl.classList.remove("err");
        healthText.textContent = j.gpu ? ("GPU: " + (j.gpu_name || "var")) : "CPU modu";
        if (obStep1Status) {
          obStep1Status.textContent = "✓ Sunucu çalışıyor" + (j.gpu ? " (GPU)" : " (CPU)");
          obStep1Status.className = "ob-step-status ok";
        }
        return true;
      })
      .catch(function () {
        healthEl.classList.remove("ok");
        healthEl.classList.add("err");
        healthText.textContent = "Sunucu kapalı";
        if (obStep1Status) {
          obStep1Status.textContent = "✗ Sunucu kapalı. Panel'deki 'Sunucu Başlat' tuşuna bas.";
          obStep1Status.className = "ob-step-status err";
        }
        return false;
      });
  }
  setInterval(checkHealth, 5000);
  checkHealth();

  // ===== Tab switching =====
  var tabBtns = document.querySelectorAll(".tab-btn");
  var tabPanels = document.querySelectorAll(".tab-panel");
  tabBtns.forEach(function (btn) {
    btn.addEventListener("click", function () {
      var target = btn.dataset.tab;
      tabBtns.forEach(function (b) { b.classList.remove("is-active"); });
      tabPanels.forEach(function (p) { p.classList.remove("is-active"); });
      btn.classList.add("is-active");
      var panel = document.getElementById("tab-" + target);
      if (panel) panel.classList.add("is-active");
      try { localStorage.setItem("fc_active_tab", target); } catch (e) {}
    });
  });
  // Son seçili tab'ı geri yükle
  try {
    var savedTab = localStorage.getItem("fc_active_tab");
    if (savedTab) {
      var btn = document.querySelector('.tab-btn[data-tab="' + savedTab + '"]');
      if (btn) btn.click();
    }
  } catch (e) {}

  // ===== SUNUCU KONTROL =====
  var srvStartBtn = $("srvStartBtn");
  var srvStopBtn = $("srvStopBtn");
  var srvPurgeBtn = $("srvPurgeBtn");
  var serverStatusEl = $("serverStatus");

  function setServerStatus(text, klass) {
    if (serverStatusEl) {
      serverStatusEl.textContent = text;
      serverStatusEl.className = "server-status" + (klass ? " " + klass : "");
    }
  }

  // start.bat yolunu coz: (1) kullanici ayari -> (2) cep_kur.bat'in yazdigi
  // server_path.txt -> (3) bos. Bulununca localStorage'a yazip tekrar arama.
  function resolveStartBat() {
    try {
      var saved = localStorage.getItem("fc_local_start_bat");
      if (saved && saved.length > 0) return saved;
    } catch (e) {}
    try {
      var fs = require("fs");
      var path = require("path");
      var f = path.join(getExtensionDir(), "server_path.txt");
      if (fs.existsSync(f)) {
        var p = (fs.readFileSync(f, "utf8") || "").trim();
        if (p) {
          try { localStorage.setItem("fc_local_start_bat", p); } catch (e2) {}
          return p;
        }
      }
    } catch (e) {}
    return "";
  }

  if (srvStartBtn) srvStartBtn.addEventListener("click", function () {
    if (typeof process !== "undefined" && process.platform === "darwin") {
      setServerStatus("macOS'ta yerel başlatma desteklenmiyor. Lütfen VDS sunucusuna bağlanın.", "err");
      return;
    }
    setServerStatus("Başlatılıyor…", "busy");
    // Lokal sunucu yolu otomatik bulunur (server_path.txt); bulunamazsa kullanicidan iste.
    // VDS modunda bu buton gereksizdir; URL uzak sunucuya işaret eder.
    var batPath = resolveStartBat();
    if (!batPath) {
      var entered = prompt(
        "start.bat dosyasinin tam yolunu yapistir\n(orn. C:\\Users\\ad\\FreeCaption\\start.bat):",
        ""
      );
      if (entered) {
        entered = entered.trim().replace(/^"+|"+$/g, "");
        try { localStorage.setItem("fc_local_start_bat", entered); } catch (e) {}
        batPath = entered;
      }
    }
    if (!batPath) {
      setServerStatus("Sunucu yolu ayarlanmadi. install.bat + cep_kur.bat'i calistir ya da start.bat yolunu gir.", "err");
      return;
    }
    var workDir = batPath.replace(/[\\\/][^\\\/]+$/, "");
    var launched = false;
    var lastErr = "";

    // YOL 1: CEP'in resmi process API'si (en güvenilir)
    try {
      if (window.cep && window.cep.process && typeof window.cep.process.createProcess === "function") {
        // cmd /c start ile yeni görünür terminal aç
        var res = window.cep.process.createProcess(
          "cmd.exe", "/c",
          "start", "FreeCaption Server",
          "cmd.exe", "/k", batPath
        );
        console.log("[CEP] cep.process.createProcess result:", res);
        // res: { err: 0, data: <pid> } başarılı
        if (res && (res.err === 0 || typeof res === "number")) {
          launched = true;
        } else {
          lastErr = "cep.process err=" + (res && res.err);
        }
      }
    } catch (e1) { lastErr = "cep.process ex: " + e1.message; }

    // YOL 2: Node.js child_process (fallback)
    if (!launched) {
      try {
        var cp = require("child_process");
        var child = cp.spawn("cmd.exe",
          ["/c", "start", "FreeCaption Server", "cmd.exe", "/k", batPath],
          { cwd: workDir, detached: true, stdio: "ignore", windowsHide: false }
        );
        child.unref();
        launched = true;
      } catch (e2) { lastErr += " | child_process ex: " + e2.message; }
    }

    // YOL 3: exec (son çare)
    if (!launched) {
      try {
        var cp2 = require("child_process");
        cp2.exec('start "FreeCaption" cmd /k "' + batPath + '"', { cwd: workDir });
        launched = true;
      } catch (e3) { lastErr += " | exec ex: " + e3.message; }
    }

    if (launched) {
      setServerStatus("Terminal açıldı, modeller yükleniyor (10-30sn)…", "busy");
      // Health check'i birden fazla kez tetikle
      setTimeout(function () { checkHealth(); }, 5000);
      setTimeout(function () { checkHealth(); }, 10000);
      setTimeout(function () { checkHealth(); }, 20000);
    } else {
      console.error("[CEP] Tüm başlatma yolları başarısız:", lastErr);
      setServerStatus("✗ Başlatılamadı: " + lastErr, "err");
    }
  });

  if (srvStopBtn) srvStopBtn.addEventListener("click", function () {
    if (!confirm("Sunucuyu kapat? Aktif iş varsa kaybolur.")) return;
    setServerStatus("Kapatılıyor…", "busy");
    fcFetch("/api/shutdown", { method: "POST" })
      .then(function (r) { return r.json(); })
      .then(function (j) {
        if (j.ok) setServerStatus("Sunucu kapandı.", "err");
        else setServerStatus("Kapatma hatası: " + j.error, "err");
      }).catch(function () {
        // Genelde shutdown sonrası response gelmez — bu normal
        setServerStatus("Sunucu kapandı.", "err");
      });
  });

  if (srvPurgeBtn) srvPurgeBtn.addEventListener("click", function () {
    setServerStatus("RAM temizleniyor…", "busy");
    fcFetch("/api/unload", { method: "POST" })
      .then(function (r) { return r.json(); })
      .then(function (j) {
        if (j.ok) {
          setServerStatus("✓ RAM temizlendi (Whisper unload).", "ok");
          setTimeout(checkHealth, 1500);
        } else {
          setServerStatus("Hata: " + (j.error || "?"), "err");
        }
      }).catch(function (e) {
        setServerStatus("Bağlantı hatası: " + e.message, "err");
      });
  });

  // ===== ExtendScript bridge testi (panel acilir acilmaz) =====
  setTimeout(function () {
    evalJSX("fcPing()")
      .then(function (r) {
        console.log("[CEP] fcPing OK:", r);
        // UI'da gorulebilir
        if (r && r.ok) {
          seqNameEl.textContent = "✓ Bridge OK";
          seqNameEl.style.color = "#22c55e";
        }
      })
      .catch(function (e) {
        console.error("[CEP] fcPing FAIL:", e.message);
        // UI'da gorulebilir hata
        seqNameEl.textContent = "✗ JSX yuklenmiyor";
        seqNameEl.style.color = "#ef4444";
        selInfoEl.textContent = "main.jsx parse hata";
      });
  }, 800);

  // ===== Eklenti Otomatik Guncelleme (GitHub'tan) =====
  var GITHUB_REPO = "ScamEmre/FreeCaption";
  var GITHUB_BRANCH = "main";

  function getInstalledCommit() {
    try {
      var fs = require("fs");
      var path = require("path");
      var ext = getExtensionDir();
      var versionFile = path.join(ext, ".fc_commit");
      if (fs.existsSync(versionFile)) return fs.readFileSync(versionFile, "utf8").trim();
    } catch (e) {}
    return null;
  }

  function getExtensionDir() {
    try {
      // CEP eklentinin gerçek konumunu öğrenmek için __dirname benzeri
      // window.location pathname'i kullan
      var loc = window.location.pathname.replace(/\\/g, "/");
      // .../FreeCaption/index.html → .../FreeCaption
      var dir = loc.substring(0, loc.lastIndexOf("/"));
      // Windows mutlak yolu (file:///C:/...)
      if (/^\/[A-Za-z]:\//.test(dir)) dir = dir.substring(1);
      if (typeof process !== "undefined" && process.platform === "darwin") {
        return dir;
      }
      return dir.replace(/\//g, "\\");
    } catch (e) {
      // Fallback
      if (typeof process !== "undefined" && process.platform === "darwin") {
        return process.env.HOME + "/Library/Application Support/Adobe/CEP/extensions/FreeCaption";
      }
      return process.env.APPDATA + "\\Adobe\\CEP\\extensions\\FreeCaption";
    }
  }

  function updatePlugin() {
    var updateBtn = $("updateBtn");
    if (updateBtn) updateBtn.disabled = true;
    showToast("Güncelleme indiriliyor…");

    try {
      var https = require("https");
      var fs = require("fs");
      var path = require("path");
      var os = require("os");
      var cp = require("child_process");

      // 1) Son commit SHA'sini API'den al (rate limit'siz GitHub raw API)
      var apiUrl = "https://api.github.com/repos/" + GITHUB_REPO + "/commits/" + GITHUB_BRANCH;
      https.get(apiUrl, { headers: { "User-Agent": "FreeCaption-Updater" } }, function (res) {
        var data = "";
        res.on("data", function (c) { data += c; });
        res.on("end", function () {
          var sha;
          try { sha = JSON.parse(data).sha; } catch (e) { sha = null; }
          if (!sha) {
            showToast("✗ GitHub commit alınamadı", true);
            if (updateBtn) updateBtn.disabled = false;
            return;
          }
          var installed = getInstalledCommit();
          if (installed === sha) {
            showToast("✓ Zaten en güncel: " + sha.substring(0, 7));
            if (updateBtn) updateBtn.disabled = false;
            return;
          }
          downloadAndApply(sha, updateBtn);
        });
      }).on("error", function (e) {
        showToast("✗ GitHub baglantisi: " + e.message, true);
        if (updateBtn) updateBtn.disabled = false;
      });
    } catch (e) {
      showToast("✗ " + e.message, true);
      if (updateBtn) updateBtn.disabled = false;
    }
  }

  function downloadAndApply(sha, updateBtn) {
    try {
      var os = require("os");
      var path = require("path");
      var fs = require("fs");
      var cp = require("child_process");

      var zipUrl = "https://github.com/" + GITHUB_REPO + "/archive/" + sha + ".zip";
      var tempZip = path.join(os.tmpdir(), "fc_update_" + Date.now() + ".zip");
      var extractDir = path.join(os.tmpdir(), "fc_update_" + Date.now());
      var extDir = getExtensionDir();

      showToast("ZIP indiriliyor…");

      var isMac = (typeof process !== "undefined" && process.platform === "darwin");
      if (isMac) {
        var shCmd =
          "curl -L '" + zipUrl + "' -o '" + tempZip + "' && " +
          "mkdir -p '" + extractDir + "' && " +
          "unzip -q '" + tempZip + "' -d '" + extractDir + "' && " +
          "src_dir=$(find '" + extractDir + "' -maxdepth 1 -type d | grep -v '^" + extractDir + "$' | head -n 1) && " +
          "cp -R \"$src_dir/cep-plugin/\"* '" + extDir + "' && " +
          "echo -n '" + sha + "' > '" + extDir + "/.fc_commit' && " +
          "rm -rf '" + tempZip + "' '" + extractDir + "'";

        cp.exec(shCmd, { maxBuffer: 100 * 1024 * 1024 }, function (err, stdout, stderr) {
          if (err) {
            showToast("✗ Güncelleme hata: " + (stderr || err.message).slice(0, 150), true);
            if (updateBtn) updateBtn.disabled = false;
            return;
          }
          showToast("✓ Güncellendi → " + sha.substring(0, 7) + " · Panel yeniden yükleniyor…");
          setTimeout(function () { window.location.reload(); }, 1500);
        });
      } else {
        // PowerShell ile indir + aç + kopyala (CEP'te node https büyük ZIP'lerde yavaş)
        var psCmd =
          "Invoke-WebRequest '" + zipUrl + "' -OutFile '" + tempZip + "' -UseBasicParsing; " +
          "Expand-Archive '" + tempZip + "' '" + extractDir + "' -Force; " +
          "$src = Get-ChildItem '" + extractDir + "' -Directory | Select-Object -First 1; " +
          "Copy-Item -Path \"$($src.FullName)\\cep-plugin\\*\" -Destination '" + extDir + "' -Recurse -Force; " +
          "Set-Content -Path '" + extDir + "\\.fc_commit' -Value '" + sha + "' -Encoding ASCII -NoNewline; " +
          "Remove-Item '" + tempZip + "','" + extractDir + "' -Recurse -Force";

        cp.exec('powershell -NoProfile -ExecutionPolicy Bypass -Command "' + psCmd.replace(/"/g, '\\"') + '"',
          { maxBuffer: 100 * 1024 * 1024 },
          function (err, stdout, stderr) {
            if (err) {
              showToast("✗ Güncelleme hata: " + (stderr || err.message).slice(0, 150), true);
              if (updateBtn) updateBtn.disabled = false;
              return;
            }
            showToast("✓ Güncellendi → " + sha.substring(0, 7) + " · Panel yeniden yükleniyor…");
            setTimeout(function () { window.location.reload(); }, 1500);
          });
      }
    } catch (e) {
      showToast("✗ " + e.message, true);
      if (updateBtn) updateBtn.disabled = false;
    }
  }

  var updateBtn = $("updateBtn");
  if (updateBtn) updateBtn.addEventListener("click", function () {
    if (!confirm("Eklentiyi GitHub'tan en son sürüme güncelle?\n\nReposi: " + GITHUB_REPO + "\nPanel yeniden yüklenecek.")) return;
    updatePlugin();
  });

  // ===== Sunucu Ayarlari (URL + API Key) =====
  var settingsBtn = $("settingsBtn");
  if (settingsBtn) {
    settingsBtn.addEventListener("click", function () {
      var currentUrl = API;
      var currentKey = API_KEY;
      var newUrl = prompt(
        "Sunucu URL (lokal: http://127.0.0.1:7860 — VDS: https://api.YOURDOMAIN.com):",
        currentUrl
      );
      if (newUrl === null) return; // iptal
      newUrl = normalizeUrl(newUrl);
      if (!newUrl) {
        try { localStorage.removeItem("fc_api_url"); } catch (e) {}
        API = "http://127.0.0.1:7860";
      } else {
        try { localStorage.setItem("fc_api_url", newUrl); } catch (e) {}
        API = newUrl;
      }
      window.FC_API = API;

      var newKey = prompt(
        "API Key (VDS icin .env'den; lokal'de bos birakabilirsin):",
        currentKey
      );
      if (newKey !== null) {
        newKey = newKey.trim();
        try {
          if (newKey) localStorage.setItem("fc_api_key", newKey);
          else localStorage.removeItem("fc_api_key");
        } catch (e) {}
        API_KEY = newKey;
        window.FC_API_KEY = API_KEY;
      }

      showToast("✓ Sunucu ayarlari kaydedildi: " + API);
      setTimeout(checkHealth, 300);
    });
  }

  // ===== Onboarding =====
  function showOnboarding() { onboarding.classList.remove("hidden"); }
  function hideOnboarding() {
    onboarding.classList.add("hidden");
    saveSetting("seen_onboarding", "1");
  }
  obClose.addEventListener("click", hideOnboarding);
  helpBtn.addEventListener("click", showOnboarding);
  if (!loadSetting("seen_onboarding", null)) {
    setTimeout(showOnboarding, 600);
  }

  // ===== Segmented pickers =====
  function bindSeg(segEl, callback) {
    if (!segEl) return;
    var segs = segEl.querySelectorAll(".seg");
    segs.forEach(function (btn) {
      btn.addEventListener("click", function () {
        segs.forEach(function (b) { b.classList.remove("is-active"); });
        btn.classList.add("is-active");
        callback(btn);
      });
    });
  }
  bindSeg(styleSeg, function (btn) {
    currentMaxChars = parseInt(btn.dataset.chars, 10) || 22;
    saveSetting("max_chars", String(currentMaxChars));
  });
  bindSeg(placementSeg, function (btn) {
    currentPlacement = btn.dataset.mode || "sequence_start";
    saveSetting("placement", currentPlacement);
  });

  // Restore preferences
  (function restore() {
    var savedChars = loadSetting("max_chars", null);
    if (savedChars) {
      currentMaxChars = parseInt(savedChars, 10);
      var match = styleSeg.querySelector('.seg[data-chars="' + savedChars + '"]');
      if (match) {
        styleSeg.querySelectorAll(".seg").forEach(function (b) { b.classList.remove("is-active"); });
        match.classList.add("is-active");
      }
    }
    var savedPl = loadSetting("placement", null);
    if (savedPl) {
      currentPlacement = savedPl;
      var pm = placementSeg.querySelector('.seg[data-mode="' + savedPl + '"]');
      if (pm) {
        placementSeg.querySelectorAll(".seg").forEach(function (b) { b.classList.remove("is-active"); });
        pm.classList.add("is-active");
      }
    }
    var savedLang = loadSetting("language", null);
    if (savedLang && languageSel.querySelector('option[value="' + savedLang + '"]')) {
      languageSel.value = savedLang;
    }
    var savedOutMode = loadSetting("output_mode", null);
    if (savedOutMode && outputDirMode.querySelector('option[value="' + savedOutMode + '"]')) {
      outputDirMode.value = savedOutMode;
    }
    var savedCustom = loadSetting("custom_dir", null);
    if (savedCustom) customDirInput.value = savedCustom;
    toggleCustomDir();
  })();

  languageSel.addEventListener("change", function () { saveSetting("language", languageSel.value); });
  outputDirMode.addEventListener("change", function () {
    saveSetting("output_mode", outputDirMode.value);
    toggleCustomDir();
  });
  customDirInput.addEventListener("change", function () { saveSetting("custom_dir", customDirInput.value); });

  function toggleCustomDir() {
    if (outputDirMode.value === "custom") customDirRow.classList.remove("hidden");
    else customDirRow.classList.add("hidden");
  }

  // Folder picker (CEP'te node.js fs varsa folder secimi yapilabilir)
  customDirBtn.addEventListener("click", function () {
    try {
      // CEP'te node entegrasyonu varsa Electron-style dialog yok, basit prompt
      var v = prompt("Tam klasör yolu (örn. C:\\Users\\...\\Klasor):", customDirInput.value || "");
      if (v) {
        customDirInput.value = v;
        saveSetting("custom_dir", v);
      }
    } catch (e) {}
  });

  // ===== Premiere proje dizini =====
  function refreshProjectDir() {
    evalJSX("getProjectDir()").then(function (r) {
      projectDir = (r && r.ok) ? r.dir : null;
    }).catch(function () { projectDir = null; });
  }
  refreshProjectDir();
  setInterval(refreshProjectDir, 10000);

  // ===== Sequence info =====
  var _probeLogged = false;
  function refreshSequenceInfo() {
    evalJSX("getSelectedClipInfo()").then(function (info) {
      if (info && info.ok) {
        if (info.itemName) info.itemName = decodeURIComponent(info.itemName);
        if (info.mediaPath) info.mediaPath = decodeURIComponent(info.mediaPath);
        if (info.seqName) info.seqName = decodeURIComponent(info.seqName);
      }
      // V7 probe: ilk gelen probe raporunu console'a tam yaz
      if (info && info.probe && !_probeLogged) {
        console.log("[CEP] V7 PROBE FULL:", info);
        _probeLogged = true;
      }
      if (!info || !info.ok) {
        seqNameEl.textContent = (info && info.t4_seqName) || (info && info.seqName) || "—";
        // V7: en son test (tX_ERR veya tX_xxx) bilgisini panele yaz
        var msg = "—";
        if (info) {
          if (info.error) msg = info.error;
          // Hangi T_ERR varsa onu goster
          var keys = ["t9_ERR", "t8_ERR", "t7_ERR", "t6_ERR", "t5_ERR", "t4_ERR", "t3_ERR", "t2_ERR", "t1_ERR"];
          for (var i = 0; i < keys.length; i++) {
            if (info[keys[i]]) { msg = keys[i] + ": " + info[keys[i]]; break; }
          }
          // Hicbir hata yoksa son durumu goster
          if (msg === "—" && info.t6_selLen !== undefined) {
            msg = "Sel: " + info.t6_selLen + " | VT: " + (info.t7_vtCount || 0);
          }
        }
        selInfoEl.textContent = msg;
        selInfoEl.title = JSON.stringify(info || {}, null, 2);
        lastClipInfo = null;
        return;
      }
      seqNameEl.textContent = info.seqName || info.t4_seqName || "Aktif";
      var dur = info.duration ? (info.duration.toFixed(1) + "s") : "";
      var name = info.itemName ? (" · " + info.itemName) : "";
      selInfoEl.textContent = "1 klip · " + dur + name;
      selInfoEl.title = info.mediaPath || "";
      lastClipInfo = info;
      // Tab 2'ye SEQUENCE FPS + DIMENSION + clip start paylas (PNG export icin kritik)
      try {
        if (info.seqFps) window.FC_LAST_SEQ_FPS = info.seqFps;
        if (info.seqWidth) window.FC_LAST_SEQ_WIDTH = info.seqWidth;
        if (info.seqHeight) window.FC_LAST_SEQ_HEIGHT = info.seqHeight;
        if (typeof info.startTime === "number") window.FC_LAST_CLIP_SEQ_START = info.startTime;
      } catch (e) {}
    }).catch(function (e) {
      seqNameEl.textContent = "—";
      selInfoEl.textContent = "JSX err: " + (e.message || e);
      console.error("[CEP] getSelectedClipInfo:", e);
    });
  }
  refreshBtn.addEventListener("click", refreshSequenceInfo);
  setInterval(refreshSequenceInfo, 1500);
  refreshSequenceInfo();

  // ===== C1 Temizle =====
  clearCaptionBtn.addEventListener("click", function () {
    if (!confirm("Caption track'lerdeki TÜM altyazıları sil?")) return;
    clearCaptionBtn.disabled = true;
    var oldHTML = clearCaptionBtn.innerHTML;
    clearCaptionBtn.innerHTML = "Siliniyor…";
    evalJSX("clearCaptionTracks()").then(function (r) {
      clearCaptionBtn.innerHTML = oldHTML;
      clearCaptionBtn.disabled = false;
      if (r && r.ok) showToast("✓ " + (r.cleared || 0) + " caption silindi");
      else showToast("✗ " + ((r && r.error) || "Hata"), true);
      if (r && r.log) console.log("[CEP] clear log:", r.log.join("\n"));
    }).catch(function (e) {
      clearCaptionBtn.innerHTML = oldHTML;
      clearCaptionBtn.disabled = false;
      showToast("✗ " + e.message, true);
    });
  });

  // ===== UPLOAD AKISI (VDS modu icin) =====
  // Lokal API: /api/clip ile media_path gonder
  // Remote API: ffmpeg ile WAV ekstrakt + /api/upload + job poll + SRT indir
  function isRemoteMode() {
    return !/(127\.0\.0\.1|localhost)/.test(API);
  }

  // ffmpeg yolunu bul (PATH veya WinGet)
  function findFfmpegPath() {
    try {
      var fs = require("fs");
      var path = require("path");

      if (typeof process !== "undefined" && process.platform === "darwin") {
        var macCandidates = [
          "/opt/homebrew/bin/ffmpeg",
          "/usr/local/bin/ffmpeg",
          "/usr/bin/ffmpeg"
        ];
        for (var i = 0; i < macCandidates.length; i++) {
          if (fs.existsSync(macCandidates[i])) return macCandidates[i];
        }
        return "ffmpeg"; // PATH fallback
      }

      var candidates = [
        process.env.LOCALAPPDATA + "\\Microsoft\\WinGet\\Links\\ffmpeg.exe",
        "C:\\ffmpeg\\bin\\ffmpeg.exe",
        "C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe",
      ];
      for (var i = 0; i < candidates.length; i++) {
        if (candidates[i] && fs.existsSync(candidates[i])) return candidates[i];
      }
    } catch (e) {}
    return "ffmpeg"; // PATH'te varsay
  }

  function extractWav(mediaPath, inPoint, outPoint, callback) {
    try {
      // CEP Node API kontrol — require window scope'unda olabilir (mixed-context)
      var req = (typeof require === "function") ? require : (typeof window.cep_node !== "undefined" ? window.cep_node.require : null);
      if (!req) {
        return callback(new Error("CEP Node integrasyonu aktif degil — manifest.xml'e --mixed-context ekle, eklentiyi yeniden yukle"));
      }
      var cp = req("child_process");
      var path = req("path");
      var os = req("os");
      var ffmpeg = findFfmpegPath();
      var tempWav = path.join(os.tmpdir(), "fc_upload_" + Date.now() + ".wav");
      var args = [];
      // -ss ve -to: input ÖNCESI hizli seek
      if (inPoint && inPoint > 0) { args.push("-ss"); args.push(String(inPoint)); }
      if (outPoint && outPoint > inPoint) { args.push("-to"); args.push(String(outPoint)); }
      args.push("-i", mediaPath, "-vn", "-ac", "1", "-ar", "16000", "-y", tempWav);
      console.log("[CEP] ffmpeg", ffmpeg, args.join(" "));
      cp.execFile(ffmpeg, args, { maxBuffer: 200 * 1024 * 1024 }, function (err, stdout, stderr) {
        if (err) {
          var errMsg = stderr ? stderr.trim().split(/\r?\n/).slice(-3).join("\n") : err.message;
          return callback(new Error("ffmpeg fail:\n" + errMsg + "\nCommand: " + ffmpeg + " " + args.join(" ")));
        }
        callback(null, tempWav);
      });
    } catch (e) { callback(e); }
  }

  function uploadAndTranscribe(wavPath, language, maxCharsPerLine, onStage, onDone) {
    try {
      var req = (typeof require === "function") ? require : (typeof window.cep_node !== "undefined" ? window.cep_node.require : null);
      if (!req) return onDone(null, null, new Error("Node API yok"));
      var fs = req("fs");
      onStage("WAV yukleniyor (" + Math.round(fs.statSync(wavPath).size / 1024 / 1024) + " MB)…");
      var wavBuf = fs.readFileSync(wavPath);
      var blob = new Blob([wavBuf], { type: "audio/wav" });
      var fd = new FormData();
      fd.append("file", blob, "clip.wav");
      if (language) fd.append("language", language);
      if (maxCharsPerLine && maxCharsPerLine > 0) {
        fd.append("max_chars_per_line", String(maxCharsPerLine));
      }
      fd.append("max_words_per_line", "99");

      fcFetch("/api/upload", { method: "POST", body: fd })
        .then(function (r) {
          if (!r.ok) return r.text().then(function (t) { throw new Error("Upload " + r.status + ": " + t); });
          return r.json();
        })
        .then(function (job) {
          onStage("Transkripsiyon basladi (job=" + job.id + ")");
          pollServerJob(job.id, onStage, onDone, wavPath);
        })
        .catch(function (e) { onDone(null, null, e); });
    } catch (e) { onDone(null, null, e); }
  }

  function pollServerJob(jobId, onStage, onDone, wavPathToClean) {
    var done = false;
    function tick() {
      if (done) return;
      fcFetch("/api/job/" + jobId, { cache: "no-store" })
        .then(function (r) { return r.json(); })
        .then(function (j) {
          var pct = Math.round((j.progress || 0) * 100);
          onStage((j.stage || "isleniyor") + " · %" + pct, j);
          if (j.status === "done") {
            done = true;
            // SRT indir
            fcFetch("/download/" + jobId + "/srt")
              .then(function (r) { return r.text(); })
              .then(function (srtText) {
                // wav temizle
                try { require("fs").unlinkSync(wavPathToClean); } catch (e) {}
                onDone(srtText, j);
              })
              .catch(function (e) { onDone(null, j, e); });
          } else if (j.status === "error") {
            done = true;
            try { require("fs").unlinkSync(wavPathToClean); } catch (e) {}
            onDone(null, j, new Error(j.error || "Sunucu hatasi"));
          } else {
            setTimeout(tick, 800);
          }
        }).catch(function (e) {
          done = true;
          onDone(null, null, e);
        });
    }
    tick();
  }

  function saveSrtLocal(srtText, baseName) {
    try {
      var fs = require("fs");
      var path = require("path");
      var os = require("os");
      // Output klasoru karari: project > custom > default
      var outDir = null;
      var mode = outputDirMode.value;
      if (mode === "project" && projectDir) outDir = projectDir;
      else if (mode === "custom" && customDirInput.value) outDir = customDirInput.value.trim();
      if (!outDir) outDir = path.join(os.homedir(), "Documents", "FreeCaption");
      if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
      var stamp = new Date().toTimeString().slice(0,8).replace(/:/g, "");
      var name = (baseName || "subtitle") + "_" + currentMaxChars + "c_" + stamp + ".srt";
      var fullPath = path.join(outDir, name);
      fs.writeFileSync(fullPath, srtText, "utf8");
      return fullPath;
    } catch (e) {
      console.error("[CEP] SRT save fail:", e);
      return null;
    }
  }

  // ===== Generate =====
  generateBtn.addEventListener("click", function () {
    console.log("[CEP] generateBtn clicked");
    generateBtn.disabled = true;
    jobError.classList.add("hidden");

    // UI'ya hemen bir job kartı göster (kullanıcı tepki gördüğünden emin olsun)
    showJob("İşleniyor…");
    jobStage.textContent = "Klip ve sunucu kontrol ediliyor…";

    // ÖNCE klip selection'ı taze al
    evalJSX("getSelectedClipInfo()")
      .catch(function (e) {
        console.warn("[CEP] getSelectedClipInfo failed:", e);
        return null;
      })
      .then(function (info) {
        console.log("[CEP] getSelectedClipInfo:", info);
        if (info && info.ok) {
          lastClipInfo = info;
          if (lastClipInfo.mediaPath) lastClipInfo.mediaPath = decodeURIComponent(lastClipInfo.mediaPath);
          if (lastClipInfo.itemName) lastClipInfo.itemName = decodeURIComponent(lastClipInfo.itemName);
          if (lastClipInfo.seqName) lastClipInfo.seqName = decodeURIComponent(lastClipInfo.seqName);
        }
        return checkHealth();
      })
      .then(function (ok) {
      console.log("[CEP] checkHealth ok:", ok);
      if (!ok) { failJob("Sunucu çalışmıyor. Panel'deki 'Sunucu Başlat' tuşuna bas."); generateBtn.disabled = false; return; }
      if (!lastClipInfo || !lastClipInfo.mediaPath) {
        failJob("Klip seçili değil.\n\nTimeline'da bir klibe (video veya ses) TIKLA, klip mavi vurgulanmalı. Sonra Altyazı Üret'e bas.");
        generateBtn.disabled = false;
        return;
      }

      // Output dir karari
      var outDir = null;
      var mode = outputDirMode.value;
      if (mode === "project") {
        if (projectDir) {
          outDir = projectDir;
        } else {
          // Proje kaydedilmemis → default
          console.warn("[CEP] Proje kaydedilmemis, default output kullaniliyor");
        }
      } else if (mode === "custom") {
        if (customDirInput.value && customDirInput.value.trim()) {
          outDir = customDirInput.value.trim();
        }
      }

      var lang = languageSel.value === "auto" ? null : languageSel.value;
      showJob(lastClipInfo.mediaPath);

      // ===== REMOTE MODE: WAV ekstrakt + upload + poll + SRT indir =====
      if (isRemoteMode()) {
        console.log("[CEP] REMOTE MODE: " + API);
        jobStage.textContent = "Ses cikariliyor (FFmpeg)…";
        extractWav(lastClipInfo.mediaPath, lastClipInfo.inPoint, lastClipInfo.outPoint, function (errW, wavPath) {
          if (errW) {
            var isMac = typeof process !== "undefined" && process.platform === "darwin";
            var installHelp = isMac 
              ? "FFmpeg bulunamadi. Terminal'den 'brew install ffmpeg' ile kurabilirsin." 
              : "FFmpeg PATH'te olmali. 'winget install ffmpeg' ile kurabilirsin.";
            failJob("FFmpeg hata: " + errW.message + "\n\n" + installHelp);
            generateBtn.disabled = false;
            return;
          }
          console.log("[CEP] WAV ready:", wavPath);
          uploadAndTranscribe(wavPath, lang, currentMaxChars, function (stage, j) {
            jobStage.textContent = stage;
            if (j) updateJobUI(j);
          }, function (srtText, finalJob, errU) {
            if (errU || !srtText) {
              failJob("Sunucu hata: " + (errU ? errU.message : "SRT bos"));
              generateBtn.disabled = false;
              return;
            }
            // SRT'i lokale yaz
            var baseName = lastClipInfo.itemName
              ? lastClipInfo.itemName.replace(/\.[^.]+$/, "")
              : "subtitle";
            var localSrt = saveSrtLocal(srtText, baseName);
            if (!localSrt) {
              failJob("SRT lokale kaydedilemedi.");
              generateBtn.disabled = false;
              return;
            }
            // pollJob ile uyumlu son durumu UI'a yansit
            updateJobUI({ status: "done", stage: "Tamamlandi", progress: 1.0 });
            jobBox.classList.remove("hidden");
            jobStatus.textContent = "Tamamlandı";
            jobStatus.className = "badge done";
            // Timeline'a yerlestir
            if (autoPlaceChk.checked) placeOnTimeline({ srt_path_abs: localSrt });
            generateBtn.disabled = false;
          });
        });
        return;
      }

      // ===== LOCAL MODE: eski /api/clip yolu =====
      var payload = {
        media_path: lastClipInfo.mediaPath,
        in_point: lastClipInfo.inPoint || 0,
        out_point: lastClipInfo.outPoint || 0,
        sequence_offset: lastClipInfo.startTime || 0,
        language: lang,
        max_words_per_line: 99,
        max_chars_per_line: currentMaxChars,
        output_dir: outDir
      };

      console.log("[CEP] LOCAL payload:", payload);
      jobStage.textContent = "Sunucuya gönderiliyor…";
      fcFetch("/api/clip", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
      }).then(function (r) {
        console.log("[CEP] /api/clip response:", r.status);
        if (!r.ok) return r.text().then(function (t) { throw new Error("Sunucu " + r.status + ": " + t); });
        return r.json();
      }).then(function (job) {
        console.log("[CEP] job started:", job);
        showJob(payload.media_path);
        pollJob(job.id);
      }).catch(function (e) {
        console.error("[CEP] fetch error:", e);
        failJob(e.message || String(e));
        generateBtn.disabled = false;
      });
    })
    .catch(function (e) {
      // En dış catch — promise chain'de takılma olursa
      console.error("[CEP] generate chain error:", e);
      failJob("Beklenmedik hata: " + (e.message || e));
      generateBtn.disabled = false;
    });
  });

  function showJob(path) {
    jobBox.classList.remove("hidden");
    jobName.textContent = path.split(/[\\/]/).pop();
    jobStatus.textContent = "Sırada";
    jobStatus.className = "badge";
    jobStage.textContent = "Hazırlanıyor";
    bar.style.width = "0%";
    bar.parentElement.classList.add("indet");
    jobError.classList.add("hidden");
    jobError.removeAttribute("style"); // varsa eski success style temizle
  }

  function failJob(msg) {
    jobBox.classList.remove("hidden");
    jobStatus.textContent = "Hata";
    jobStatus.className = "badge error";
    jobError.textContent = msg;
    jobError.classList.remove("hidden");
    bar.parentElement.classList.remove("indet");
  }

  function pollJob(jobId) {
    var done = false;
    function tick() {
      if (done) return;
      fcFetch("/api/job/" + jobId, { cache: "no-store" })
        .then(function (r) { return r.json(); })
        .then(function (j) {
          updateJobUI(j);
          if (j.status === "done") {
            done = true;
            if (autoPlaceChk.checked) placeOnTimeline(j);
            generateBtn.disabled = false;
          } else if (j.status === "error") {
            done = true; failJob(j.error || "Bilinmeyen hata"); generateBtn.disabled = false;
          } else { setTimeout(tick, 600); }
        }).catch(function (e) {
          done = true; failJob(e.message); generateBtn.disabled = false;
        });
    }
    tick();
  }

  function updateJobUI(j) {
    jobStatus.className = "badge";
    var label = "İşleniyor";
    if (j.status === "queued") label = "Sırada";
    else if (j.status === "done") { label = "Tamamlandı"; jobStatus.classList.add("done"); }
    else if (j.status === "error") { label = "Hata"; jobStatus.classList.add("error"); }
    jobStatus.textContent = label;
    jobStage.textContent = j.stage || "—";
    var pct = Math.round((j.progress || 0) * 100);
    if (pct > 3) bar.parentElement.classList.remove("indet");
    bar.style.width = pct + "%";
  }

  function placeOnTimeline(job) {
    var srtPath = job.srt_path_abs;
    if (!srtPath) { failJob("SRT yolu yok"); return; }
    // Tab 2'ye son uretilen SRT yolunu + clibin sekanstaki konumunu bildir
    try {
      window.FC_LAST_SRT_PATH = srtPath;
      // Clibin sekanstaki baslangic saati (PNG sequence import konumu)
      var seqStart = (lastClipInfo && lastClipInfo.startTime) ? lastClipInfo.startTime : 0;
      window.FC_LAST_CLIP_SEQ_START = seqStart;
    } catch (e) {}
    // YENI imza: importAndPlaceSubtitle(srtPath, placementMode, explicitSeconds)
    var jsxCall = 'importAndPlaceSubtitle("' + encodeURIComponent(srtPath) + '", "' + currentPlacement + '", 0)';

    evalJSX(jsxCall).then(function (r) {
      console.log("[CEP] importAndPlace result:", r);
      if (r && r.ok) {
        jobStage.textContent = "✓ Yerleştirildi · " + (r.method || "");
        jobError.classList.add("hidden");
      } else {
        var msg = "";
        if (r && r.noCaptionTrack) {
          msg = "Caption track oluşturulamadı.\n\nBin'deki " + (r.itemName || "SRT") +
                " dosyasını timeline'a sürükle — Premiere otomatik caption track yapar.";
        } else {
          msg = "Bin'e eklendi, timeline insert başarısız.";
          if (r && r.errors && r.errors.length) {
            msg += "\n\nHata:\n" + r.errors.slice(0, 3).join("\n");
          }
        }
        jobError.textContent = msg;
        jobError.classList.remove("hidden");
        if (r && r.log) console.log("[CEP] JSX log:\n" + r.log.join("\n"));
      }
    }).catch(function (e) {
      jobError.textContent = "ExtendScript hata: " + e.message;
      jobError.classList.remove("hidden");
    });
  }

  // ===== Toast =====
  function showToast(msg, isErr) {
    var t = document.createElement("div");
    t.textContent = msg;
    Object.assign(t.style, {
      position: "fixed", bottom: "20px", left: "50%",
      transform: "translateX(-50%)",
      background: isErr ? "rgba(239,68,68,0.95)" : "rgba(34,197,94,0.95)",
      color: "#fff", padding: "9px 14px", borderRadius: "9px",
      fontSize: "11.5px", fontWeight: "600", zIndex: "2000",
      boxShadow: "0 12px 32px rgba(0,0,0,0.5)"
    });
    document.body.appendChild(t);
    setTimeout(function () {
      t.style.opacity = "0"; t.style.transition = "opacity 0.3s";
      setTimeout(function () { t.remove(); }, 300);
    }, 2400);
  }
})();
