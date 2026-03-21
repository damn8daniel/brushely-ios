import { useState, useEffect, useRef, useMemo } from "react";

/* ═══════════════════════════════════════════════════════════════
   BRUSHELY — APPLE/WHOOP GRADE DESIGN
   Every pixel intentional. Every radius consistent.
   Every shadow layered. Every animation spring-based.
   ═══════════════════════════════════════════════════════════════ */

// ─── DESIGN TOKENS ───
const T = {
  // Radius scale
  r4: 4, r8: 8, r12: 12, r16: 16, r20: 20, r24: 24, r28: 28, r32: 32,
  // Spacing scale (4px base)
  s2: 2, s4: 4, s6: 6, s8: 8, s12: 12, s16: 16, s20: 20, s24: 24, s32: 32, s40: 40, s48: 48, s64: 64,
  // Font sizes
  f10: 10, f11: 11, f12: 12, f13: 13, f14: 14, f15: 15, f16: 16, f17: 17, f20: 20, f24: 24, f28: 28, f32: 32, f40: 40, f48: 48,
  // Weights
  w4: 400, w5: 500, w6: 600, w7: 700, w8: 800,
};

// ─── COLOR PALETTE — Warm, considered, restrained ───
const C = {
  // Surfaces — barely-there warm whites
  bg:      "#FAFAF7",
  bg2:     "#F4F3EF",
  card:    "#FFFFFF",
  border:  "#EEECEA",
  borderL: "#F5F4F2",

  // Brand — refined jade green. Not neon. Not teal. Warm, trustworthy.
  brand:   "#2D9F83",
  brandD:  "#1E7F68",
  brandL:  "#8DDBC6",
  brandXL: "#D4F0E8",
  brandBg: "#EFF9F5",

  // Warm accent — terracotta/salmon for streaks, energy
  warm:    "#DA6A4A",
  warmL:   "#F4D0C4",
  warmBg:  "#FEF4F0",

  // Gold — achievements, records
  gold:    "#C4952E",
  goldL:   "#F0DEB4",
  goldBg:  "#FDF8EC",

  // Semantic
  ok:      "#2D9F83",
  err:     "#D4463A",
  errBg:   "#FDF0EF",

  // Text — warm charcoal, not cold gray
  t1:      "#1C2024",
  t2:      "#5F6B78",
  t3:      "#94A0AD",
  t4:      "#C5CCD3",

  // Shadows — warm, layered
  sh1: "0 1px 2px rgba(28,32,36,0.04)",
  sh2: "0 2px 8px rgba(28,32,36,0.06), 0 1px 2px rgba(28,32,36,0.04)",
  sh3: "0 4px 16px rgba(28,32,36,0.08), 0 2px 4px rgba(28,32,36,0.04)",
  sh4: "0 8px 32px rgba(28,32,36,0.10), 0 2px 8px rgba(28,32,36,0.05)",
  shBrand: `0 4px 16px rgba(45,159,131,0.20), 0 2px 4px rgba(45,159,131,0.10)`,
};

const font = "'SF Pro Display', 'SF Pro Text', -apple-system, system-ui, 'Helvetica Neue', sans-serif";

// ─── ZONE DATA ───
const ZONES = [
  { name: "Верхние наружные", short: "Наруж.", jaw: "upper", area: "outer", hint: "Вверх-вниз" },
  { name: "Верхние жевательные", short: "Жеват.", jaw: "upper", area: "chew", hint: "Вперёд-назад" },
  { name: "Верхние внутренние", short: "Внутр.", jaw: "upper", area: "inner", hint: "Вверх-вниз" },
  { name: "Нижние наружные", short: "Наруж.", jaw: "lower", area: "outer", hint: "Вверх-вниз" },
  { name: "Нижние жевательные", short: "Жеват.", jaw: "lower", area: "chew", hint: "Вперёд-назад" },
  { name: "Нижние внутренние", short: "Внутр.", jaw: "lower", area: "inner", hint: "Вверх-вниз" },
  { name: "Передние верхние", short: "Перед.", jaw: "upper", area: "front", hint: "Вертикально" },
  { name: "Передние нижние", short: "Перед.", jaw: "lower", area: "front", hint: "Вертикально" },
];

// ─── APP ───
export default function App() {
  const [screen, setScreen] = useState("idle");
  const [phase, setPhase] = useState(0);

  useEffect(() => {
    if (screen !== "active") return;
    setPhase(0);
    const id = setInterval(() => setPhase(p => {
      if (p >= 1) { clearInterval(id); setTimeout(() => setScreen("completion"), 300); return 1; }
      return p + 0.005;
    }), 50);
    return () => clearInterval(id);
  }, [screen]);

  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", background: "#EDECE8", minHeight: "100vh", padding: "24px 0 48px", fontFamily: font }}>
      <style>{GLOBAL_CSS}</style>
      {/* Header */}
      <div style={{ display: "flex", alignItems: "baseline", gap: 8, marginBottom: T.s12 }}>
        <span style={{ fontSize: T.f20, fontWeight: T.w8, color: C.t1, letterSpacing: -0.5 }}>Brushely</span>
      </div>
      {/* Nav */}
      <div style={{ display: "flex", gap: T.s4, marginBottom: T.s20, background: C.card, borderRadius: T.r16, padding: 3, boxShadow: C.sh2, border: `1px solid ${C.border}` }}>
        {[["idle","Главная"],["active","Чистка"],["completion","Результат"],["calendar","Прогресс"]].map(([k,l]) => (
          <button key={k} onClick={() => setScreen(k)} style={{
            padding: "7px 16px", borderRadius: T.r12, border: "none",
            background: screen === k ? C.brand : "transparent",
            color: screen === k ? "#fff" : C.t3,
            fontWeight: T.w6, fontSize: T.f12, cursor: "pointer",
            transition: "all 0.25s cubic-bezier(.4,0,.2,1)",
            fontFamily: font,
          }}>{l}</button>
        ))}
      </div>
      {/* Phone */}
      <div style={{ width: 393, height: 852, borderRadius: 52, overflow: "hidden", position: "relative", background: C.bg, border: "4px solid #D8D6D2", boxShadow: "0 24px 80px rgba(0,0,0,0.12), 0 4px 16px rgba(0,0,0,0.06)" }}>
        <div style={{ position: "absolute", top: 12, left: "50%", transform: "translateX(-50%)", width: 126, height: 36, borderRadius: 20, background: "#1C2024", zIndex: 50 }} />
        <div style={{ position: "absolute", inset: 0 }}>
          {screen === "idle" && <IdleScreen onStart={() => setScreen("active")} />}
          {screen === "active" && <ActiveScreen phase={phase} onStop={() => setScreen("idle")} />}
          {screen === "completion" && <CompletionScreen onSave={() => setScreen("calendar")} onBack={() => setScreen("idle")} />}
          {screen === "calendar" && <CalendarScreen />}
          {(screen === "idle" || screen === "calendar") && <BottomTab active={screen === "calendar" ? 1 : 0} onChange={i => setScreen(i ? "calendar" : "idle")} />}
        </div>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   IDLE SCREEN — Hero with dental arch, session config
   ═══════════════════════════════════════════════════════════════ */
function IdleScreen({ onStart }) {
  return (
    <div style={{ position: "absolute", inset: 0, background: C.bg, overflow: "hidden" }}>
      {/* Subtle warm gradient wash at top */}
      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 360, background: `linear-gradient(180deg, ${C.brandBg} 0%, ${C.bg} 100%)`, opacity: 0.7 }} />

      <div style={{ position: "relative", zIndex: 1, display: "flex", flexDirection: "column", height: "100%", padding: `0 ${T.s24}px` }}>
        {/* Status bar space */}
        <div style={{ height: 64 }} />

        {/* Greeting */}
        <div style={{ marginBottom: T.s24 }}>
          <div style={{ fontSize: T.f14, fontWeight: T.w5, color: C.t3 }}>Готовы к чистке</div>
          <div style={{ fontSize: T.f28, fontWeight: T.w8, color: C.t1, letterSpacing: -0.8, marginTop: T.s4 }}>Доброе утро</div>
        </div>

        {/* Main card — the hero */}
        <div style={{ background: C.card, borderRadius: T.r28, padding: T.s24, boxShadow: C.sh3, border: `1px solid ${C.border}` }}>
          {/* Timer display */}
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: T.s20 }}>
            <div>
              <div style={{ fontSize: T.f48, fontWeight: T.w8, color: C.t1, letterSpacing: -2, lineHeight: 1, fontVariantNumeric: "tabular-nums" }}>2:00</div>
              <div style={{ fontSize: T.f12, fontWeight: T.w6, color: C.t3, marginTop: T.s4, letterSpacing: 0.5 }}>РЕКОМЕНДОВАНО</div>
            </div>
            {/* Mini dental arch preview */}
            <div style={{ width: 80, height: 80 }}>
              <DentalArch activeZone={-1} size={80} />
            </div>
          </div>

          {/* Zone pills */}
          <div style={{ display: "flex", gap: T.s4, flexWrap: "wrap" }}>
            {ZONES.map((z, i) => (
              <div key={i} style={{
                padding: "5px 10px", borderRadius: T.r8,
                background: i === 0 ? C.brandBg : C.bg2,
                border: `1px solid ${i === 0 ? C.brand + "33" : "transparent"}`,
                fontSize: T.f11, fontWeight: T.w6,
                color: i === 0 ? C.brand : C.t3,
              }}>
                {i + 1}. {z.short}
              </div>
            ))}
          </div>
        </div>

        <div style={{ height: T.s16 }} />

        {/* Info row */}
        <div style={{ display: "flex", gap: T.s8 }}>
          <InfoTile icon={<CamIcon />} title="Камера" sub="Отслеживание" />
          <InfoTile icon={<WaveIcon />} title="8 зон" sub="Полная чистка" />
          <InfoTile icon={<ShieldIcon />} title="AI анализ" sub="В реальном времени" />
        </div>

        <div style={{ flex: 1 }} />

        {/* CTA */}
        <button onClick={onStart} className="cta" style={{
          width: "100%", padding: "18px 0", borderRadius: T.r16, border: "none",
          background: C.brand, color: "#fff",
          fontSize: T.f16, fontWeight: T.w7, letterSpacing: 0.5,
          cursor: "pointer", fontFamily: font,
          boxShadow: C.shBrand,
          transition: "transform 0.15s cubic-bezier(.4,0,.2,1), box-shadow 0.15s",
        }}>
          Начать чистку
        </button>
        <div style={{ height: 96 }} />
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   ACTIVE BRUSHING SCREEN
   ═══════════════════════════════════════════════════════════════ */
function ActiveScreen({ phase, onStop }) {
  const zi = Math.min(7, Math.floor(phase * 8));
  const zp = (phase * 8) % 1;
  const pct = Math.floor(phase * 87);
  const secs = Math.floor((1 - phase) * 120);
  const mm = Math.floor(secs / 60), ss = secs % 60;

  return (
    <div style={{ position: "absolute", inset: 0, background: "#E8E5DF" }}>
      {/* Camera simulation */}
      <div style={{ position: "absolute", inset: 0, background: "linear-gradient(170deg, #DDD9D2, #C8C3BB 60%, #B8B3AA)" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 50% 40%, rgba(255,255,255,0.2), transparent 70%)" }} />
      </div>
      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 200, background: `linear-gradient(180deg, ${C.bg}F0, transparent)`, zIndex: 2 }} />
      <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 380, background: `linear-gradient(0deg, ${C.bg}FA 20%, transparent)`, zIndex: 2 }} />

      {/* Center — dental arch with active zone */}
      <div style={{ position: "absolute", top: "24%", left: "50%", transform: "translateX(-50%)", zIndex: 3 }}>
        <div className="archBreathe">
          <DentalArch activeZone={zi} size={160} />
        </div>
        {/* Hz indicator below arch */}
        <div style={{ textAlign: "center", marginTop: T.s12 }}>
          <StatusPill phase={phase} />
        </div>
      </div>

      {/* HUD */}
      <div style={{ position: "absolute", inset: 0, zIndex: 4, display: "flex", flexDirection: "column" }}>
        {/* Top bar */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "60px 20px 0" }}>
          {/* Score */}
          <div style={{ background: C.card, borderRadius: T.r12, padding: "8px 14px", boxShadow: C.sh2, border: `1px solid ${C.border}`, display: "flex", alignItems: "center", gap: T.s8 }}>
            <ProgressRing size={28} stroke={3} progress={pct / 100} />
            <span style={{ fontSize: T.f15, fontWeight: T.w8, color: C.t1, fontVariantNumeric: "tabular-nums" }}>{pct}%</span>
          </div>
          {/* Timer */}
          <div style={{ background: C.card, borderRadius: T.r12, padding: "8px 14px", boxShadow: C.sh2, border: `1px solid ${C.border}`, display: "flex", alignItems: "center", gap: T.s8 }}>
            <ProgressRing size={28} stroke={3} progress={phase} color={C.warm} />
            <span style={{ fontSize: T.f15, fontWeight: T.w7, color: C.t1, fontVariantNumeric: "tabular-nums" }}>{mm}:{ss.toString().padStart(2, "0")}</span>
          </div>
        </div>

        <div style={{ flex: 1 }} />

        {/* Bottom zone card */}
        <div style={{ padding: "0 16px 16px" }}>
          <div style={{ background: C.card, borderRadius: T.r24, padding: T.s16, boxShadow: C.sh4, border: `1px solid ${C.border}` }}>
            <div style={{ display: "flex", gap: T.s12, alignItems: "center" }}>
              {/* Animated brush scene */}
              <div style={{ width: 72, height: 72, borderRadius: T.r20, background: C.brandBg, border: `1px solid ${C.brand}15`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                <BrushScene zone={ZONES[zi]} />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: "flex", alignItems: "center", gap: T.s6 }}>
                  <span style={{ fontSize: T.f10, fontWeight: T.w7, color: C.brand, letterSpacing: 1.2 }}>ШАГ {zi + 1}/8</span>
                  <div style={{ flex: 1, height: 1, background: C.border }} />
                </div>
                <div style={{ fontSize: T.f16, fontWeight: T.w7, color: C.t1, marginTop: T.s4, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{ZONES[zi].name}</div>
                <div style={{ display: "flex", alignItems: "center", gap: T.s4, marginTop: T.s6 }}>
                  <div className={ZONES[zi].area === "chew" ? "hintH" : "hintV"} style={{ display: "flex" }}>
                    <ArrowIcon dir={ZONES[zi].area === "chew" ? "h" : "v"} />
                  </div>
                  <span style={{ fontSize: T.f12, fontWeight: T.w6, color: C.t2 }}>{ZONES[zi].hint}</span>
                </div>
              </div>
            </div>
            {/* Progress track */}
            <div style={{ height: 4, borderRadius: 2, background: C.bg2, marginTop: T.s16, overflow: "hidden" }}>
              <div className="zoneBar" style={{ height: "100%", borderRadius: 2, width: `${zp * 100}%`, background: C.brand }} />
            </div>
          </div>

          <button onClick={onStop} style={{
            width: "100%", padding: "14px 0", marginTop: T.s8, borderRadius: T.r16,
            border: `1.5px solid ${C.err}28`, background: C.errBg,
            color: C.err, fontSize: T.f14, fontWeight: T.w7,
            cursor: "pointer", fontFamily: font,
          }}>Остановить</button>
        </div>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   COMPLETION SCREEN
   ═══════════════════════════════════════════════════════════════ */
function CompletionScreen({ onSave, onBack }) {
  const pct = 87;
  const [count, setCount] = useState(0);
  const [show, setShow] = useState(false);
  useEffect(() => {
    let c = 0;
    const t = setInterval(() => { c++; if (c >= pct) { c = pct; clearInterval(t); } setCount(c); }, 14);
    setTimeout(() => setShow(true), 1000);
    return () => clearInterval(t);
  }, []);

  return (
    <div style={{ position: "absolute", inset: 0, background: C.bg, overflow: "hidden" }}>
      {show && <ConfettiCanvas />}
      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 400, background: `linear-gradient(180deg, ${C.brandBg} 0%, ${C.bg} 100%)` }} />
      <div style={{ position: "relative", zIndex: 1, display: "flex", flexDirection: "column", alignItems: "center", height: "100%", padding: `0 ${T.s24}px` }}>
        <div style={{ height: 80 }} />

        {/* Grade badge */}
        <div style={{
          padding: "6px 16px", borderRadius: T.r8, background: C.brandBg, border: `1px solid ${C.brand}22`,
          opacity: show ? 1 : 0, transform: show ? "none" : "translateY(8px) scale(0.95)",
          transition: "all 0.5s cubic-bezier(.34,1.56,.64,1)",
        }}>
          <span style={{ fontSize: T.f13, fontWeight: T.w7, color: C.brand }}>Отлично</span>
        </div>

        <div style={{ height: T.s20 }} />

        {/* Big ring */}
        <div style={{ position: "relative" }}>
          <svg width="220" height="220" viewBox="0 0 220 220">
            <defs>
              <linearGradient id="compG" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor={C.brand} />
                <stop offset="100%" stopColor={C.brandL} />
              </linearGradient>
            </defs>
            <circle cx="110" cy="110" r="96" fill="none" stroke={C.bg2} strokeWidth="8" />
            <circle cx="110" cy="110" r="96" fill="none" stroke="url(#compG)" strokeWidth="8" strokeLinecap="round"
              strokeDasharray={`${(count / 100) * 603} 603`} transform="rotate(-90 110 110)"
              style={{ transition: "stroke-dasharray 0.06s linear", filter: `drop-shadow(0 2px 8px ${C.brand}30)` }} />
          </svg>
          <div style={{ position: "absolute", inset: 0, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
            <span style={{ fontSize: 56, fontWeight: T.w8, color: C.t1, letterSpacing: -2, lineHeight: 1, fontVariantNumeric: "tabular-nums" }}>{count}</span>
            <span style={{ fontSize: T.f14, fontWeight: T.w5, color: C.t3, marginTop: T.s4 }}>из 100</span>
          </div>
        </div>

        <div style={{ height: T.s24 }} />

        {/* Stats */}
        <div style={{ display: "flex", gap: T.s8, width: "100%", opacity: show ? 1 : 0, transform: show ? "none" : "translateY(16px)", transition: "all 0.5s ease 0.15s" }}>
          <ResultStat val="1:52" label="Время" sub="из 2:00" color={C.warm} bg={C.warmBg} />
          <ResultStat val="87" label="Верных" sub="движений" color={C.brand} bg={C.brandBg} />
          <ResultStat val="2.4" label="Частота" sub="Hz средн." color={C.gold} bg={C.goldBg} />
        </div>

        <div style={{ flex: 1 }} />

        <div style={{ width: "100%", opacity: show ? 1 : 0, transform: show ? "none" : "translateY(16px)", transition: "all 0.5s ease 0.3s" }}>
          <button onClick={onSave} className="cta" style={{
            width: "100%", padding: "18px 0", borderRadius: T.r16, border: "none",
            background: C.brand, color: "#fff",
            fontSize: T.f16, fontWeight: T.w7, cursor: "pointer", fontFamily: font,
            boxShadow: C.shBrand,
          }}>Сохранить</button>
          <button onClick={onBack} style={{ width: "100%", padding: "12px 0", background: "transparent", border: "none", color: C.t3, fontSize: T.f14, fontWeight: T.w5, cursor: "pointer", fontFamily: font }}>Пропустить</button>
        </div>
        <div style={{ height: T.s24 }} />
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   CALENDAR / PROGRESS SCREEN
   ═══════════════════════════════════════════════════════════════ */
function CalendarScreen() {
  const scored = {3:92,5:78,7:85,8:91,10:65,12:88,14:75,15:82,17:95,18:87,19:90,20:84,21:87};
  const sCol = s => s >= 85 ? C.brand : s >= 70 ? C.gold : C.warm;
  const sBg = s => s >= 85 ? C.brandBg : s >= 70 ? C.goldBg : C.warmBg;

  return (
    <div style={{ position: "absolute", inset: 0, background: C.bg, overflow: "auto" }}>
      <div style={{ padding: `0 ${T.s20}px`, paddingBottom: 100 }}>
        <div style={{ height: 64 }} />

        <div style={{ fontSize: T.f28, fontWeight: T.w8, color: C.t1, letterSpacing: -0.8 }}>Прогресс</div>

        <div style={{ height: T.s16 }} />

        {/* Streak banner */}
        <div style={{ display: "flex", alignItems: "center", gap: T.s12, padding: T.s16, borderRadius: T.r20, background: C.warmBg, border: `1px solid ${C.warm}15` }}>
          <div style={{ width: 44, height: 44, borderRadius: T.r12, background: C.card, boxShadow: C.sh1, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <FlameAsset />
          </div>
          <div>
            <div style={{ fontSize: T.f16, fontWeight: T.w8, color: C.warm }}>5 дней подряд</div>
            <div style={{ fontSize: T.f12, color: C.t2, marginTop: 1 }}>Рекорд: 7 дней</div>
          </div>
        </div>

        <div style={{ height: T.s16 }} />

        {/* Weekly summary — Apple Fitness rings style */}
        <div style={{ background: C.card, borderRadius: T.r24, padding: T.s20, boxShadow: C.sh2, border: `1px solid ${C.border}` }}>
          <div style={{ fontSize: T.f12, fontWeight: T.w7, color: C.t3, letterSpacing: 0.8, marginBottom: T.s16 }}>НЕДЕЛЯ</div>
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            {["Пн","Вт","Ср","Чт","Пт","Сб","Вс"].map((d, i) => {
              const val = [0.92, 0.84, 0.87, 0.90, 0.85, 0, 0][i];
              const today = i === 4;
              return (
                <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: T.s8 }}>
                  <ProgressRing size={36} stroke={3.5} progress={val} color={val > 0 ? C.brand : C.bg2} bg={C.bg2} />
                  <span style={{ fontSize: T.f11, fontWeight: today ? T.w7 : T.w5, color: today ? C.t1 : C.t3 }}>{d}</span>
                </div>
              );
            })}
          </div>
        </div>

        <div style={{ height: T.s16 }} />

        {/* Calendar */}
        <div style={{ background: C.card, borderRadius: T.r24, padding: T.s20, boxShadow: C.sh2, border: `1px solid ${C.border}` }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: T.s16 }}>
            <button style={navBtnS}><ChevLeft /></button>
            <span style={{ fontSize: T.f15, fontWeight: T.w7, color: C.t1 }}>Март 2026</span>
            <button style={navBtnS}><ChevRight /></button>
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(7,1fr)", gap: 2, textAlign: "center" }}>
            {["Пн","Вт","Ср","Чт","Пт","Сб","Вс"].map(d => <span key={d} style={{ fontSize: T.f10, fontWeight: T.w6, color: C.t4, padding: "6px 0" }}>{d}</span>)}
            {Array(6).fill(0).map((_, i) => <div key={`e${i}`} style={{ height: 40 }} />)}
            {Array.from({length: 31}, (_, i) => i + 1).map(d => {
              const sc = scored[d]; const today = d === 21;
              return (
                <div key={d} style={{
                  height: 40, borderRadius: T.r12,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  background: sc ? sBg(sc) : "transparent",
                  outline: today ? `2px solid ${C.brand}` : "none",
                  outlineOffset: -1,
                  fontSize: T.f13, fontWeight: sc || today ? T.w7 : T.w4,
                  color: sc ? sCol(sc) : today ? C.t1 : C.t3,
                }}>{d}</div>
              );
            })}
          </div>
        </div>

        <div style={{ height: T.s16 }} />

        {/* History */}
        <div style={{ fontSize: T.f12, fontWeight: T.w7, color: C.t3, letterSpacing: 0.8, marginBottom: T.s8 }}>НЕДАВНИЕ</div>
        {[{d:"Сегодня, 10:30",p:87,dur:"1:52"},{d:"Вчера, 09:15",p:84,dur:"2:00"},{d:"19 мар, 22:45",p:90,dur:"1:58"}].map((s, i) => (
          <div key={i} style={{ display: "flex", alignItems: "center", gap: T.s12, padding: T.s12, marginBottom: T.s6, background: C.card, borderRadius: T.r16, boxShadow: C.sh1, border: `1px solid ${C.border}` }}>
            <ProgressRing size={40} stroke={3.5} progress={s.p / 100} color={sCol(s.p)} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: T.f14, fontWeight: T.w7, color: C.t1 }}>{s.p}%</div>
              <div style={{ fontSize: T.f11, color: C.t3, marginTop: 1 }}>{s.d}</div>
            </div>
            <span style={{ fontSize: T.f13, fontWeight: T.w6, color: C.t2, fontVariantNumeric: "tabular-nums" }}>{s.dur}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   DENTAL ARCH — Anatomically shaped teeth in an arch layout
   Each tooth has proper shape: incisors flat, canines pointed,
   premolars/molars wider with cusps
   ═══════════════════════════════════════════════════════════════ */
function DentalArch({ activeZone, size }) {
  const s = size / 160;
  // Tooth positions along arch curve (upper jaw shown from front)
  // Each tooth: [cx, cy, width, height, type]
  // Types: 0=molar, 1=premolar, 2=canine, 3=lateral_incisor, 4=central_incisor
  const upperTeeth = [
    [-58,-8,11,13,0], [-47,-16,10,12,0], [-37,-22,9,11,1], [-28,-27,8,11,1],
    [-19,-30,7,12,2], [-11,-32,8,13,3], [-4,-33,9,14,4],
    [4,-33,9,14,4], [11,-32,8,13,3], [19,-30,7,12,2],
    [28,-27,8,11,1], [37,-22,9,11,1], [47,-16,10,12,0], [58,-8,11,13,0],
  ];
  const lowerTeeth = [
    [-56,8,11,12,0], [-45,15,10,11,0], [-36,20,9,10,1], [-27,24,8,10,1],
    [-18,27,7,11,2], [-10,29,7,12,3], [-3,30,8,13,4],
    [3,30,8,13,4], [10,29,7,12,3], [18,27,7,11,2],
    [27,24,8,10,1], [36,20,9,10,1], [45,15,10,11,0], [56,8,11,12,0],
  ];

  // Zone to tooth index mapping
  const zoneTeethUpper = { outer: [0,1,2,3,10,11,12,13], chew: [0,1,12,13], inner: [4,5,6,7,8,9], front: [5,6,7,8] };
  const zoneTeethLower = { outer: [0,1,2,3,10,11,12,13], chew: [0,1,12,13], inner: [4,5,6,7,8,9], front: [5,6,7,8] };

  const isActive = (jaw, idx) => {
    if (activeZone < 0) return false;
    const z = ZONES[activeZone];
    const map = z.jaw === "upper" ? zoneTeethUpper : zoneTeethLower;
    if (z.jaw !== jaw) return false;
    return map[z.area]?.includes(idx);
  };

  const drawTooth = (t, i, jaw) => {
    const [cx, cy, w, h, type] = t;
    const active = isActive(jaw, i);
    const x = 80 + cx * s;
    const y = 80 + cy * s;
    const tw = w * s;
    const th = h * s;

    let path;
    const r = tw * 0.3;
    if (type === 4) { // Central incisor — wider, flat bottom
      path = `M${x-tw/2+r},${y-th/2} Q${x-tw/2},${y-th/2} ${x-tw/2},${y-th/2+r} L${x-tw/2},${y+th/2-r} Q${x-tw/2},${y+th/2} ${x-tw/2+r},${y+th/2} L${x+tw/2-r},${y+th/2} Q${x+tw/2},${y+th/2} ${x+tw/2},${y+th/2-r} L${x+tw/2},${y-th/2+r} Q${x+tw/2},${y-th/2} ${x+tw/2-r},${y-th/2} Z`;
    } else if (type === 2) { // Canine — slightly pointed
      path = `M${x},${y-th/2-1} L${x+tw/2},${y-th/4} L${x+tw/2},${y+th/2-r} Q${x+tw/2},${y+th/2} ${x+tw/2-r},${y+th/2} L${x-tw/2+r},${y+th/2} Q${x-tw/2},${y+th/2} ${x-tw/2},${y+th/2-r} L${x-tw/2},${y-th/4} Z`;
    } else { // Premolar/molar — rounded rect
      path = `M${x-tw/2+r},${y-th/2} Q${x-tw/2},${y-th/2} ${x-tw/2},${y-th/2+r} L${x-tw/2},${y+th/2-r} Q${x-tw/2},${y+th/2} ${x-tw/2+r},${y+th/2} L${x+tw/2-r},${y+th/2} Q${x+tw/2},${y+th/2} ${x+tw/2},${y+th/2-r} L${x+tw/2},${y-th/2+r} Q${x+tw/2},${y-th/2} ${x+tw/2-r},${y-th/2} Z`;
    }

    return (
      <g key={`${jaw}${i}`}>
        {active && <ellipse cx={x} cy={y} rx={tw*0.8} ry={th*0.8} fill={C.brand} opacity="0.12" className="toothGlow" />}
        <path d={path} fill={active ? C.brandBg : "#F0EEEB"} stroke={active ? C.brand : "#D5D2CC"} strokeWidth={active ? 1.5 : 0.8} />
        {active && (type === 0 || type === 1) && (
          <line x1={x-tw*0.25} y1={y} x2={x+tw*0.25} y2={y} stroke={C.brand} strokeWidth="0.5" opacity="0.3" />
        )}
      </g>
    );
  };

  return (
    <svg width={size} height={size} viewBox="0 0 160 160">
      {/* Gum lines */}
      <ellipse cx="80" cy="50" rx={62*s} ry={22*s} fill="none" stroke="#E8B4B0" strokeWidth={1.5} opacity="0.25" strokeDasharray="2 3" />
      <ellipse cx="80" cy="110" rx={60*s} ry={20*s} fill="none" stroke="#E8B4B0" strokeWidth={1.5} opacity="0.25" strokeDasharray="2 3" />
      {/* Upper teeth */}
      {upperTeeth.map((t, i) => drawTooth(t, i, "upper"))}
      {/* Lower teeth */}
      {lowerTeeth.map((t, i) => drawTooth(t, i, "lower"))}
      {/* Center divider */}
      <line x1="30" y1="80" x2="130" y2="80" stroke={C.border} strokeWidth="0.5" opacity="0.5" />
    </svg>
  );
}

/* ═══════════════════════════════════════════════════════════════
   BRUSH SCENE — Detailed toothbrush moving on teeth
   ═══════════════════════════════════════════════════════════════ */
function BrushScene({ zone }) {
  const isH = zone.area === "chew";
  return (
    <svg width="56" height="56" viewBox="0 0 56 56">
      <defs>
        <linearGradient id="hdG" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={C.brand} />
          <stop offset="100%" stopColor={C.brandD} />
        </linearGradient>
        <linearGradient id="hnG" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#D8D5D0" />
          <stop offset="100%" stopColor="#BFBBB5" />
        </linearGradient>
      </defs>
      {/* Teeth background */}
      {zone.area === "chew" ? (
        <g>
          {[0,1,2].map(i => (
            <rect key={i} x={6+i*16} y={20} width={13} height={14} rx={3.5} fill="#F0EEEB" stroke="#D5D2CC" strokeWidth="0.8" />
          ))}
        </g>
      ) : zone.area === "front" ? (
        <g>
          <rect x={14} y={8} width={12} height={34} rx={5} fill="#F0EEEB" stroke="#D5D2CC" strokeWidth="0.8" />
          <rect x={30} y={10} width={12} height={32} rx={5} fill="#F0EEEB" stroke="#D5D2CC" strokeWidth="0.8" />
        </g>
      ) : (
        <g>
          {[0,1,2,3].map(i => (
            <rect key={i} x={3+i*13} y={10} width={10} height={30} rx={4} fill="#F0EEEB" stroke="#D5D2CC" strokeWidth="0.8">
              <animate attributeName="y" values="10;8.5;10" dur="1.8s" begin={`${i*0.12}s`} repeatCount="indefinite" />
            </rect>
          ))}
        </g>
      )}
      {/* Toothbrush */}
      <g className={isH ? "brH" : "brV"}>
        {/* Handle */}
        <rect x="18" y="38" width="20" height="3.5" rx="1.75" fill="url(#hnG)" />
        {/* Head */}
        <rect x="12" y="24" width="14" height="20" rx="5" fill="url(#hdG)" />
        {/* Bristle rows */}
        {[0,1,2,3,4].map(r => (
          <g key={r}>
            <rect x={15} y={27+r*3.2} width={2.5} height={1.8} rx={0.9} fill="white" opacity="0.6" />
            <rect x={19} y={27+r*3.2} width={2.5} height={1.8} rx={0.9} fill="white" opacity="0.5" />
          </g>
        ))}
        {/* Highlight on head */}
        <rect x="14" y="25" width="3" height="10" rx="1.5" fill="white" opacity="0.15" />
      </g>
    </svg>
  );
}

/* ═══════════════════════════════════════════════════════════════
   PROGRESS RING — Apple Fitness style
   ═══════════════════════════════════════════════════════════════ */
function ProgressRing({ size, stroke, progress, color = C.brand, bg = C.bg2 }) {
  const r = (size - stroke) / 2;
  const circ = 2 * Math.PI * r;
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={bg} strokeWidth={stroke} />
      {progress > 0 && (
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={color} strokeWidth={stroke} strokeLinecap="round"
          strokeDasharray={`${progress * circ} ${circ}`} transform={`rotate(-90 ${size/2} ${size/2})`}
          style={{ transition: "stroke-dasharray 0.3s ease" }} />
      )}
    </svg>
  );
}

/* ═══════════════════════════════════════════════════════════════
   SMALL COMPONENTS & ICONS
   ═══════════════════════════════════════════════════════════════ */

function StatusPill({ phase }) {
  const hz = (phase * 2.5 + 0.5).toFixed(1);
  const ok = phase > 0.3;
  return (
    <div style={{ display: "inline-flex", alignItems: "center", gap: T.s8, padding: "8px 16px", borderRadius: T.r12, background: C.card, boxShadow: C.sh2, border: `1px solid ${C.border}` }}>
      <div style={{ width: 8, height: 8, borderRadius: "50%", background: ok ? C.ok : C.t4, boxShadow: ok ? `0 0 6px ${C.ok}66` : "none", transition: "all 0.4s" }} />
      <span style={{ fontSize: T.f14, fontWeight: T.w7, color: C.t1, fontVariantNumeric: "tabular-nums" }}>{hz} Hz</span>
      <span style={{ fontSize: T.f12, fontWeight: T.w5, color: ok ? C.brand : C.t3 }}>{ok ? "Верно" : "Анализ..."}</span>
    </div>
  );
}

function InfoTile({ icon, title, sub }) {
  return (
    <div style={{ flex: 1, padding: `${T.s12}px ${T.s8}px`, borderRadius: T.r16, background: C.card, boxShadow: C.sh1, border: `1px solid ${C.border}`, display: "flex", flexDirection: "column", alignItems: "center", gap: T.s6, textAlign: "center" }}>
      <div style={{ width: 32, height: 32, borderRadius: T.r8, background: C.brandBg, display: "flex", alignItems: "center", justifyContent: "center" }}>{icon}</div>
      <div style={{ fontSize: T.f12, fontWeight: T.w7, color: C.t1 }}>{title}</div>
      <div style={{ fontSize: T.f10, color: C.t3 }}>{sub}</div>
    </div>
  );
}

function ResultStat({ val, label, sub, color, bg }) {
  return (
    <div style={{ flex: 1, padding: T.s16, borderRadius: T.r20, background: C.card, boxShadow: C.sh2, border: `1px solid ${C.border}`, textAlign: "center" }}>
      <div style={{ fontSize: T.f24, fontWeight: T.w8, color: C.t1, fontVariantNumeric: "tabular-nums" }}>{val}</div>
      <div style={{ fontSize: T.f12, fontWeight: T.w6, color: color, marginTop: T.s4 }}>{label}</div>
      <div style={{ fontSize: T.f10, color: C.t3, marginTop: T.s2 }}>{sub}</div>
    </div>
  );
}

function BottomTab({ active, onChange }) {
  return (
    <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, zIndex: 10, background: `${C.card}F8`, backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)", borderTop: `1px solid ${C.border}`, padding: "8px 0 28px", display: "flex" }}>
      {[["Чистка", <ToothTabIcon active={active===0} />], ["Прогресс", <ChartTabIcon active={active===1} />]].map(([l, icon], i) => (
        <button key={i} onClick={() => onChange(i)} style={{
          flex: 1, display: "flex", flexDirection: "column", alignItems: "center", gap: 2,
          background: "transparent", border: "none", cursor: "pointer", fontFamily: font,
        }}>
          {icon}
          <span style={{ fontSize: T.f10, fontWeight: T.w6, color: active === i ? C.brand : C.t3, transition: "color 0.2s" }}>{l}</span>
        </button>
      ))}
    </div>
  );
}

// ─── SVG Icons — Crisp, 1.5px stroke, rounded caps ───
function CamIcon() { return <svg width="16" height="16" viewBox="0 0 20 20" fill="none"><rect x="2" y="5" width="16" height="12" rx="2.5" stroke={C.brand} strokeWidth="1.5"/><circle cx="10" cy="11" r="3.5" stroke={C.brand} strokeWidth="1.5"/></svg>; }
function WaveIcon() { return <svg width="16" height="16" viewBox="0 0 20 20" fill="none"><path d="M2 10c2-4 3-4 4 0s2 4 4 0 2-4 4 0 2 4 4 0" stroke={C.brand} strokeWidth="1.5" strokeLinecap="round"/></svg>; }
function ShieldIcon() { return <svg width="16" height="16" viewBox="0 0 20 20" fill="none"><path d="M10 2L3 5.5v4.5c0 4.5 3 7.5 7 8.5 4-1 7-4 7-8.5V5.5L10 2z" stroke={C.brand} strokeWidth="1.5" strokeLinejoin="round"/><path d="M7 10.5l2 2 4-4" stroke={C.brand} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>; }
function ArrowIcon({ dir }) {
  if (dir === "h") return <svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M2 7h10M9 4.5l3 2.5-3 2.5M5 9.5l-3-2.5 3-2.5" stroke={C.brand} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>;
  return <svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M7 2v10M4.5 9l2.5 3 2.5-3M9.5 5l-2.5-3-2.5 3" stroke={C.brand} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>;
}
function ChevLeft() { return <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M7.5 2.5l-4 3.5 4 3.5" stroke={C.t2} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>; }
function ChevRight() { return <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M4.5 2.5l4 3.5-4 3.5" stroke={C.t2} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>; }
function FlameAsset() { return <svg width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M12 2C12 2 7 7 7 13a5 5 0 0010 0c0-2-1-3.5-2-4.5.5 1 .5 2-.5 3a2.5 2.5 0 01-5 0C9.5 9 12 7 12 2z" fill={C.warm} opacity="0.85"/><path d="M12 14c0-1.5 1-2.5 1-2.5s1 1 1 2.5a1 1 0 01-2 0z" fill="#FFF4E0" opacity="0.6"/></svg>; }
function ToothTabIcon({ active }) { return <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M12 3c-3 0-5.5 2-7 5s-2 7-1.5 10.5c.5 3 2 5.5 3.5 6.5 1 .5 1.5 0 2-2s1-3 3-3 2 1 3 3 1 2.5 2 2c1.5-1 3-3.5 3.5-6.5S20 11 18.5 8 15 3 12 3z" stroke={active ? C.brand : C.t4} strokeWidth="1.8" fill={active ? C.brandBg : "none"}/></svg>; }
function ChartTabIcon({ active }) { return <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="3" y="14" width="4" height="7" rx="1.5" stroke={active ? C.brand : C.t4} strokeWidth="1.8" fill={active ? C.brandBg : "none"}/><rect x="10" y="8" width="4" height="13" rx="1.5" stroke={active ? C.brand : C.t4} strokeWidth="1.8" fill={active ? C.brandBg : "none"}/><rect x="17" y="3" width="4" height="18" rx="1.5" stroke={active ? C.brand : C.t4} strokeWidth="1.8" fill={active ? C.brandBg : "none"}/></svg>; }

const navBtnS = { width: 32, height: 32, borderRadius: "50%", background: C.bg2, border: `1px solid ${C.border}`, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" };

// ─── Confetti ───
function ConfettiCanvas() {
  const ref = useRef(null);
  useEffect(() => {
    const cv = ref.current; if (!cv) return;
    const ctx = cv.getContext("2d");
    cv.width = 393; cv.height = 852;
    const cols = [C.brand, C.brandL, C.warm, C.gold, C.goldL, C.t4];
    const ps = Array.from({length: 45}, () => ({
      x: 196 + (Math.random() - 0.5) * 80, y: 350,
      vx: (Math.random() - 0.5) * 10, vy: -Math.random() * 15 - 6,
      w: 3 + Math.random() * 3, h: 6 + Math.random() * 6,
      r: Math.random() * 360, rv: (Math.random() - 0.5) * 12,
      c: cols[Math.floor(Math.random() * cols.length)], life: 1,
    }));
    let fr;
    const draw = () => {
      ctx.clearRect(0, 0, 393, 852); let alive = false;
      ps.forEach(p => {
        if (p.life <= 0) return; alive = true;
        p.x += p.vx; p.y += p.vy; p.vy += 0.3; p.r += p.rv; p.life -= 0.006; p.vx *= 0.99;
        ctx.save(); ctx.translate(p.x, p.y); ctx.rotate(p.r * Math.PI / 180);
        ctx.globalAlpha = Math.max(0, p.life); ctx.fillStyle = p.c;
        ctx.beginPath(); ctx.roundRect(-p.w/2, -p.h/2, p.w, p.h, 1.5); ctx.fill();
        ctx.restore();
      });
      if (alive) fr = requestAnimationFrame(draw);
    };
    draw();
    return () => cancelAnimationFrame(fr);
  }, []);
  return <canvas ref={ref} style={{ position: "absolute", inset: 0, zIndex: 10, pointerEvents: "none" }} />;
}

/* ═══════════════════════════════════════════════════════════════
   GLOBAL CSS — Refined, purposeful animations
   ═══════════════════════════════════════════════════════════════ */
const GLOBAL_CSS = `
  * { box-sizing: border-box; margin: 0; }

  .cta:active { transform: scale(0.98) !important; }

  .archBreathe { animation: archB 3s ease-in-out infinite alternate; }
  @keyframes archB { 0% { transform: scale(1); } 100% { transform: scale(1.02); } }

  .toothGlow { animation: tGlow 1.5s ease-in-out infinite alternate; }
  @keyframes tGlow { 0% { opacity: 0.08; } 100% { opacity: 0.18; } }

  .brV { animation: brV 1.5s cubic-bezier(.45,.05,.55,.95) infinite alternate; }
  .brH { animation: brH 1.5s cubic-bezier(.45,.05,.55,.95) infinite alternate; }
  @keyframes brV { 0% { transform: translateY(-6px); } 100% { transform: translateY(8px); } }
  @keyframes brH { 0% { transform: translateX(-8px); } 100% { transform: translateX(8px); } }

  .hintV { animation: hV 0.8s ease-in-out infinite alternate; }
  .hintH { animation: hH 0.8s ease-in-out infinite alternate; }
  @keyframes hV { 0% { transform: translateY(-1px); } 100% { transform: translateY(1px); } }
  @keyframes hH { 0% { transform: translateX(-1px); } 100% { transform: translateX(1px); } }

  .zoneBar { transition: width 0.12s linear; }

  ::-webkit-scrollbar { display: none; }
`;
