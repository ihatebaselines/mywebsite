"use client";

import React, { useState, useEffect, useRef, useCallback, useMemo } from "react";
import {
  PenTool,
  StickyNote,
  Stamp,
  Download,
  RotateCcw,
  ZoomIn,
  ZoomOut,
  Heart,
  Send,
  X,
  Move,
  Eraser,
  Check,
  Palette,
  Sparkles,
} from "lucide-react";
import { WallStroke, WallNote, WallStamp } from "@/lib/supabase";
import initialWallData from "@/content/wallState.json";
import styles from "@/app/page.module.css";

// Extended Drawing Palette (Catppuccin + Vibrant Spectrum + Monochrome)
const DRAWING_PALETTE = [
  { name: "Sapphire", color: "#89b4fa" },
  { name: "Mauve", color: "#cba6f7" },
  { name: "Green", color: "#a6e3a1" },
  { name: "Peach", color: "#fab387" },
  { name: "Red", color: "#f38ba8" },
  { name: "Yellow", color: "#f9e2af" },
  { name: "Teal", color: "#94e2d5" },
  { name: "Lavender", color: "#b4befe" },
  { name: "Black / Ink", color: "#11111b" },
  { name: "Pure White", color: "#ffffff" },
  { name: "Electric Cyan", color: "#00f0ff" },
  { name: "Hot Pink", color: "#ff2a85" },
  { name: "Neon Lime", color: "#39ff14" },
];

// Background Board Presets
const BOARD_PRESETS = [
  { id: "white", name: "⚪ Whiteboard", bg: "#ffffff", textColor: "#11111b" },
  { id: "mocha", name: "🐈 Mocha", bg: "#181825", textColor: "#cdd6f4" },
  { id: "midnight", name: "🌑 Dark", bg: "#08080c", textColor: "#cdd6f4" },
];

const AVAILABLE_STAMPS = [
  { label: "Pingu Trumpet", src: "/images/pingu-trumpet.png" },
  { label: "Pingu Noot", src: "/images/pingu-noot.png" },
  { label: "Pingu Wave", src: "/images/pingu-waving.png" },
  { label: "Pingu Chair", src: "/images/pingu-chair.png" },
  { label: "Pingu Standing", src: "/images/pingu-standing.png" },
  { label: "Sad Ducky", src: "/images/sad.webp" },
];

const EMOJIS = ["🐧", "🥇", "💻", "🚀", "🔥", "🌊", "🧠", "✨", "🎉", "⚡", "🎨", "👾"];

// Helper to calculate luminance for high-contrast dynamic grid and UI
function getLuminance(hexColor: string): number {
  let hex = hexColor.replace("#", "");
  if (hex.length === 3) {
    hex = hex.split("").map((c) => c + c).join("");
  }
  if (hex.length !== 6) return 0;
  const r = parseInt(hex.substring(0, 2), 16) || 0;
  const g = parseInt(hex.substring(2, 4), 16) || 0;
  const b = parseInt(hex.substring(4, 6), 16) || 0;
  return 0.299 * r + 0.587 * g + 0.114 * b;
}

export default function InfiniteWall() {
  // Canvas Transform State
  const [pan, setPan] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const [zoom, setZoom] = useState<number>(1);
  const [isPanning, setIsPanning] = useState(false);
  const panStartRef = useRef<{ x: number; y: number }>({ x: 0, y: 0 });

  // Board Background Customizer (Whiteboard / Dark / Custom Color Wheel)
  const [boardBg, setBoardBg] = useState<string>("#ffffff"); // Default Whiteboard
  const isLightBoard = useMemo(() => getLuminance(boardBg) > 140, [boardBg]);

  // Tool Modes: "pan" | "draw" | "note" | "stamp" | "erase"
  const [tool, setTool] = useState<"pan" | "draw" | "note" | "stamp" | "erase">("draw");
  const [selectedColor, setSelectedColor] = useState<string>("#11111b"); // Default ink for whiteboard
  const [brushSize, setBrushSize] = useState<number>(4);
  const [selectedStamp, setSelectedStamp] = useState<string>(AVAILABLE_STAMPS[0].src);

  // Wall Content Data (initialized from permanent wallState and merged with local visitor items)
  const [strokes, setStrokes] = useState<WallStroke[]>((initialWallData.strokes as WallStroke[]) || []);
  const [notes, setNotes] = useState<WallNote[]>((initialWallData.notes as WallNote[]) || []);
  const [stamps, setStamps] = useState<WallStamp[]>((initialWallData.stamps as WallStamp[]) || []);
  const [currentStroke, setCurrentStroke] = useState<{ x: number; y: number }[] | null>(null);

  // Sync & Auto-Save State
  const [isSyncing, setIsSyncing] = useState<boolean>(false);
  const [saveFeedback, setSaveFeedback] = useState<boolean>(false);

  // Note Modal State
  const [showNoteModal, setShowNoteModal] = useState(false);
  const [notePlacementCoords, setNotePlacementCoords] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const [noteAuthor, setNoteAuthor] = useState("");
  const [noteText, setNoteText] = useState("");
  const [noteEmoji, setNoteEmoji] = useState("🐧");
  const [noteColor, setNoteColor] = useState("#cba6f7");
  const [isSubmittingNote, setIsSubmittingNote] = useState(false);

  // Color Pickers refs
  const drawColorInputRef = useRef<HTMLInputElement>(null);
  const boardBgInputRef = useRef<HTMLInputElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  // Load background and saved items from localStorage on mount
  useEffect(() => {
    try {
      const savedBg = localStorage.getItem("ihateb_wall_bg");
      if (savedBg) {
        setBoardBg(savedBg);
        if (getLuminance(savedBg) > 140) {
          setSelectedColor("#11111b");
        } else {
          setSelectedColor("#89b4fa");
        }
      }

      const localStrokes = localStorage.getItem("ihateb_wall_strokes");
      if (localStrokes) {
        const parsed = JSON.parse(localStrokes) as WallStroke[];
        if (Array.isArray(parsed) && parsed.length > 0) {
          setStrokes((prev) => {
            const map = new Map(prev.map((s) => [s.id, s]));
            parsed.forEach((s) => map.set(s.id, s));
            return Array.from(map.values());
          });
        }
      }

      const localNotes = localStorage.getItem("ihateb_wall_notes");
      if (localNotes) {
        const parsed = JSON.parse(localNotes) as WallNote[];
        if (Array.isArray(parsed) && parsed.length > 0) {
          setNotes((prev) => {
            const map = new Map(prev.map((n) => [n.id, n]));
            parsed.forEach((n) => map.set(n.id, n));
            return Array.from(map.values());
          });
        }
      }

      const localStamps = localStorage.getItem("ihateb_wall_stamps");
      if (localStamps) {
        const parsed = JSON.parse(localStamps) as WallStamp[];
        if (Array.isArray(parsed) && parsed.length > 0) {
          setStamps((prev) => {
            const map = new Map(prev.map((st) => [st.id, st]));
            parsed.forEach((st) => map.set(st.id, st));
            return Array.from(map.values());
          });
        }
      }
    } catch (_) {}
  }, []);

  const persistLocal = useCallback((type: "stroke" | "note" | "stamp" | "like", data: any) => {
    try {
      if (type === "stroke") {
        const existing = JSON.parse(localStorage.getItem("ihateb_wall_strokes") || "[]");
        existing.push(data);
        localStorage.setItem("ihateb_wall_strokes", JSON.stringify(existing.slice(-300)));
      } else if (type === "note") {
        const existing = JSON.parse(localStorage.getItem("ihateb_wall_notes") || "[]");
        existing.push(data);
        localStorage.setItem("ihateb_wall_notes", JSON.stringify(existing));
      } else if (type === "stamp") {
        const existing = JSON.parse(localStorage.getItem("ihateb_wall_stamps") || "[]");
        existing.push(data);
        localStorage.setItem("ihateb_wall_stamps", JSON.stringify(existing));
      } else if (type === "like") {
        const existing = (JSON.parse(localStorage.getItem("ihateb_wall_notes") || "[]") as WallNote[]) || [];
        const note = existing.find((n) => n.id === data.id);
        if (note) {
          note.likes = (note.likes || 0) + 1;
          localStorage.setItem("ihateb_wall_notes", JSON.stringify(existing));
        }
      }
    } catch (_) {}
  }, []);

  const handleBoardBgChange = (newBg: string) => {
    setBoardBg(newBg);
    try {
      localStorage.setItem("ihateb_wall_bg", newBg);
    } catch (_) {}
    if (getLuminance(newBg) > 140 && (selectedColor === "#ffffff" || selectedColor === "#11111b")) {
      setSelectedColor("#11111b");
    } else if (getLuminance(newBg) <= 140 && selectedColor === "#11111b") {
      setSelectedColor("#89b4fa");
    }
  };

  // Convert Screen (clientX, clientY) to Infinite World (worldX, worldY)
  const screenToWorld = useCallback(
    (screenX: number, screenY: number) => {
      if (!containerRef.current) return { x: 0, y: 0 };
      const rect = containerRef.current.getBoundingClientRect();
      const centerX = rect.width / 2;
      const centerY = rect.height / 2;

      const worldX = (screenX - rect.left - centerX - pan.x) / zoom;
      const worldY = (screenY - rect.top - centerY - pan.y) / zoom;
      return { x: Math.round(worldX), y: Math.round(worldY) };
    },
    [pan, zoom]
  );

  // Redraw Canvas on changes
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas || !containerRef.current) return;

    const rect = containerRef.current.getBoundingClientRect();
    const dpr = window.devicePixelRatio || 1;
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    ctx.scale(dpr, dpr);
    ctx.clearRect(0, 0, rect.width, rect.height);

    ctx.save();
    // Translate origin to center of viewport + pan offset
    ctx.translate(rect.width / 2 + pan.x, rect.height / 2 + pan.y);
    ctx.scale(zoom, zoom);

    // Draw Grid Background with Dynamic Contrast for Whiteboard / Dark mode
    const gridSize = 40;
    const startX = Math.floor((-rect.width / 2 - pan.x) / zoom / gridSize) * gridSize;
    const endX = Math.ceil((rect.width / 2 - pan.x) / zoom / gridSize) * gridSize;
    const startY = Math.floor((-rect.height / 2 - pan.y) / zoom / gridSize) * gridSize;
    const endY = Math.ceil((rect.height / 2 - pan.y) / zoom / gridSize) * gridSize;

    // Grid dots color adapts dynamically to board luminance
    ctx.fillStyle = isLightBoard ? "rgba(15, 23, 42, 0.12)" : "rgba(205, 214, 244, 0.09)";
    for (let gx = startX; gx <= endX; gx += gridSize) {
      for (let gy = startY; gy <= endY; gy += gridSize) {
        ctx.beginPath();
        ctx.arc(gx, gy, 1.4 / zoom, 0, Math.PI * 2);
        ctx.fill();
      }
    }

    // Draw Axis Origin Crosshairs
    ctx.strokeStyle = isLightBoard ? "rgba(15, 23, 42, 0.22)" : "rgba(137, 180, 250, 0.2)";
    ctx.lineWidth = 1.2 / zoom;
    ctx.beginPath();
    ctx.moveTo(-160, 0);
    ctx.lineTo(160, 0);
    ctx.moveTo(0, -160);
    ctx.lineTo(0, 160);
    ctx.stroke();

    // Draw Center Origin Marker
    ctx.fillStyle = isLightBoard ? "#475569" : "#89b4fa";
    ctx.beginPath();
    ctx.arc(0, 0, 3.5 / zoom, 0, Math.PI * 2);
    ctx.fill();

    // Draw All Completed Strokes
    strokes.forEach((stroke) => {
      if (!stroke.points || stroke.points.length < 2) return;
      ctx.strokeStyle = stroke.color;
      ctx.lineWidth = stroke.width;
      ctx.lineCap = "round";
      ctx.lineJoin = "round";

      ctx.beginPath();
      ctx.moveTo(stroke.points[0].x, stroke.points[0].y);
      for (let i = 1; i < stroke.points.length; i++) {
        ctx.lineTo(stroke.points[i].x, stroke.points[i].y);
      }
      ctx.stroke();
    });

    // Draw Active In-Progress Stroke
    if (currentStroke && currentStroke.length > 1) {
      ctx.strokeStyle = tool === "erase" ? boardBg : selectedColor;
      ctx.lineWidth = tool === "erase" ? brushSize * 3.5 : brushSize;
      ctx.lineCap = "round";
      ctx.lineJoin = "round";

      ctx.beginPath();
      ctx.moveTo(currentStroke[0].x, currentStroke[0].y);
      for (let i = 1; i < currentStroke.length; i++) {
        ctx.lineTo(currentStroke[i].x, currentStroke[i].y);
      }
      ctx.stroke();
    }

    ctx.restore();
  }, [pan, zoom, strokes, currentStroke, selectedColor, brushSize, tool, boardBg, isLightBoard]);

  // Pointer / Mouse Handlers
  const handlePointerDown = (e: React.PointerEvent) => {
    if (tool === "pan" || e.button === 1) {
      setIsPanning(true);
      panStartRef.current = { x: e.clientX - pan.x, y: e.clientY - pan.y };
      return;
    }

    const worldCoord = screenToWorld(e.clientX, e.clientY);

    if (tool === "draw" || tool === "erase") {
      setCurrentStroke([worldCoord]);
    } else if (tool === "stamp") {
      // Place stamp & immediately auto-save
      const newStamp: WallStamp = {
        id: `stamp-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
        x: worldCoord.x,
        y: worldCoord.y,
        type: "pingu",
        src: selectedStamp,
        size: 95,
        author: "visitor",
        created_at: new Date().toISOString(),
      };
      setStamps((prev) => [...prev, newStamp]);

      // Auto-save instantly
      persistLocal("stamp", newStamp);
      showAutoSaveNotice();
    } else if (tool === "note") {
      setNotePlacementCoords(worldCoord);
      setShowNoteModal(true);
    }
  };

  const handlePointerMove = (e: React.PointerEvent) => {
    if (isPanning) {
      setPan({
        x: e.clientX - panStartRef.current.x,
        y: e.clientY - panStartRef.current.y,
      });
      return;
    }

    if (currentStroke && (tool === "draw" || tool === "erase")) {
      const worldCoord = screenToWorld(e.clientX, e.clientY);
      setCurrentStroke((prev) => (prev ? [...prev, worldCoord] : [worldCoord]));
    }
  };

  const handlePointerUp = () => {
    if (isPanning) {
      setIsPanning(false);
      return;
    }

    if (currentStroke && currentStroke.length > 1 && tool === "draw") {
      const newStroke: WallStroke = {
        id: `stroke-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
        color: selectedColor,
        width: brushSize,
        points: currentStroke,
        author: "visitor",
        created_at: new Date().toISOString(),
      };

      setStrokes((prev) => [...prev, newStroke]);
      setCurrentStroke(null);

      // Auto-save stroke instantly
      persistLocal("stroke", newStroke);
      showAutoSaveNotice();
    } else {
      setCurrentStroke(null);
    }
  };

  const showAutoSaveNotice = () => {
    setSaveFeedback(true);
    setTimeout(() => setSaveFeedback(false), 2200);
  };

  // Zoom on Wheel
  const handleWheel = (e: React.WheelEvent) => {
    e.preventDefault();
    const zoomFactor = 1.08;
    const newZoom = e.deltaY < 0 ? Math.min(zoom * zoomFactor, 3.5) : Math.max(zoom / zoomFactor, 0.25);
    setZoom(Number(newZoom.toFixed(2)));
  };

  // Sticky Note submission (Auto-saved directly)
  const handleSubmitNote = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!noteText.trim()) return;

    setIsSubmittingNote(true);

    const newNote: WallNote = {
      id: `note-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
      x: notePlacementCoords.x,
      y: notePlacementCoords.y,
      text: noteText.trim(),
      author: noteAuthor.trim() || "Anonymous Friend",
      color: noteColor,
      emoji: noteEmoji,
      likes: 1,
      created_at: new Date().toISOString(),
    };

    setNotes((prev) => [...prev, newNote]);
    setShowNoteModal(false);
    setNoteText("");
    setIsSubmittingNote(false);
    showAutoSaveNotice();

    persistLocal("note", newNote);
  };

  // Like a note
  const handleLikeNote = async (id: string) => {
    setNotes((prev) =>
      prev.map((note) => (note.id === id ? { ...note, likes: (note.likes || 0) + 1 } : note))
    );
    persistLocal("like", { id });
  };

  // Export Canvas snapshot as PNG
  const exportSnapshot = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const link = document.createElement("a");
    link.download = `TheWall-${Date.now()}.png`;
    link.href = canvas.toDataURL("image/png");
    link.click();
  };

  return (
    <div
      className={styles.wallWrapper}
      ref={containerRef}
      style={{ backgroundColor: boardBg, color: isLightBoard ? "#11111b" : "#cdd6f4" }}
    >
      {/* ─── Top Wall Toolbar ─── */}
      <div
        className={`${styles.wallToolbar} ${isLightBoard ? styles.wallToolbarLight : styles.wallToolbarDark}`}
      >
        {/* Tool Selector */}
        <div className={styles.wallToolGroup}>
          <button
            type="button"
            className={`${styles.wallToolBtn} ${tool === "draw" ? styles.wallToolBtnActive : ""}`}
            onClick={() => setTool("draw")}
            title="Draw Freehand (auto-saves instantly)"
          >
            <PenTool size={16} />
            <span>Draw</span>
          </button>

          <button
            type="button"
            className={`${styles.wallToolBtn} ${tool === "note" ? styles.wallToolBtnActive : ""}`}
            onClick={() => setTool("note")}
            title="Click on canvas to leave a Sticky Note"
          >
            <StickyNote size={16} />
            <span>Sticky Note</span>
          </button>

          <button
            type="button"
            className={`${styles.wallToolBtn} ${tool === "stamp" ? styles.wallToolBtnActive : ""}`}
            onClick={() => setTool("stamp")}
            title="Stamp Pingus & Stickers"
          >
            <Stamp size={16} />
            <span>Stamps</span>
          </button>

          <button
            type="button"
            className={`${styles.wallToolBtn} ${tool === "pan" ? styles.wallToolBtnActive : ""}`}
            onClick={() => setTool("pan")}
            title="Pan / Move Canvas"
          >
            <Move size={16} />
            <span>Pan</span>
          </button>

          <button
            type="button"
            className={`${styles.wallToolBtn} ${tool === "erase" ? styles.wallToolBtnActive : ""}`}
            onClick={() => setTool("erase")}
            title="Eraser"
          >
            <Eraser size={16} />
          </button>
        </div>

        {/* ─── Drawing Color Palette + Color Wheel ─── */}
        {tool === "draw" && (
          <div className={styles.wallColorGroup}>
            {DRAWING_PALETTE.slice(0, 9).map((c) => (
              <button
                key={c.name}
                type="button"
                className={`${styles.wallColorDot} ${selectedColor.toLowerCase() === c.color.toLowerCase() ? styles.wallColorDotActive : ""}`}
                style={{ backgroundColor: c.color }}
                onClick={() => setSelectedColor(c.color)}
                title={c.name}
              />
            ))}

            {/* Custom Color Wheel Button */}
            <div className={styles.wallColorWheelBtnWrapper}>
              <input
                ref={drawColorInputRef}
                type="color"
                value={selectedColor}
                onChange={(e) => setSelectedColor(e.target.value)}
                className={styles.hiddenColorInput}
                title="Pick ANY custom color with the Color Wheel"
              />
              <button
                type="button"
                className={styles.wallColorWheelBtn}
                onClick={() => drawColorInputRef.current?.click()}
                title="Open Color Wheel (Pick any RGB color)"
              >
                <div
                  className={styles.wallColorWheelPreview}
                  style={{ backgroundColor: selectedColor }}
                />
                <Palette size={13} className={styles.wallColorWheelIcon} />
              </button>
            </div>

            {/* Brush Sizes */}
            <div className={styles.wallBrushSizes}>
              {[2, 4, 8, 14].map((size) => (
                <button
                  key={size}
                  type="button"
                  className={`${styles.wallSizeBtn} ${brushSize === size ? styles.wallSizeBtnActive : ""}`}
                  onClick={() => setBrushSize(size)}
                  title={`Brush ${size}px`}
                >
                  <span
                    style={{
                      width: Math.min(size * 1.3, 12),
                      height: Math.min(size * 1.3, 12),
                      borderRadius: "50%",
                      background: isLightBoard ? "#0f172a" : "#ffffff",
                    }}
                  />
                </button>
              ))}
            </div>
          </div>
        )}

        {/* ─── Stamps Selector ─── */}
        {tool === "stamp" && (
          <div className={styles.wallStampGroup}>
            {AVAILABLE_STAMPS.map((s) => (
              <button
                key={s.src}
                type="button"
                className={`${styles.wallStampOption} ${selectedStamp === s.src ? styles.wallStampOptionActive : ""}`}
                onClick={() => setSelectedStamp(s.src)}
                title={s.label}
              >
                <img src={s.src} alt={s.label} />
              </button>
            ))}
          </div>
        )}

        {/* ─── Board Background Switcher (High Contrast Readable Buttons) ─── */}
        <div className={styles.wallBgSwitcherGroup}>
          <div className={styles.wallBgOptions}>
            {BOARD_PRESETS.map((p) => (
              <button
                key={p.id}
                type="button"
                className={`${styles.wallBgOptionBtn} ${boardBg.toLowerCase() === p.bg.toLowerCase() ? styles.wallBgOptionBtnActive : ""}`}
                style={{
                  backgroundColor: p.bg,
                  color: p.textColor,
                  border: boardBg.toLowerCase() === p.bg.toLowerCase() ? "2px solid #89b4fa" : "1px solid rgba(128,128,128,0.3)",
                }}
                onClick={() => handleBoardBgChange(p.bg)}
                title={`${p.name} Mode`}
              >
                {p.name}
              </button>
            ))}

            {/* Background Custom Color Wheel */}
            <div className={styles.wallBgWheelWrapper}>
              <input
                ref={boardBgInputRef}
                type="color"
                value={boardBg}
                onChange={(e) => handleBoardBgChange(e.target.value)}
                className={styles.hiddenColorInput}
                title="Choose custom background color"
              />
              <button
                type="button"
                className={styles.wallBgWheelBtn}
                onClick={() => boardBgInputRef.current?.click()}
                title="Board Background Color Wheel"
              >
                <Palette size={13} />
                <span>Custom Bg</span>
              </button>
            </div>
          </div>
        </div>

        {/* ─── Action Utilities ─── */}
        <div className={styles.wallActionGroup}>
          <button
            type="button"
            className={`${styles.wallActionBtn} ${saveFeedback ? styles.wallSaveSuccessBtn : ""}`}
            onClick={showAutoSaveNotice}
            title="Auto-saves automatically upon every stroke or action"
          >
            {saveFeedback ? <Check size={14} color="#a6e3a1" /> : <Sparkles size={14} />}
            <span>{saveFeedback ? "Saved Live!" : "Auto-Saved"}</span>
          </button>

          <button
            type="button"
            className={styles.wallActionBtn}
            onClick={exportSnapshot}
            title="Download Canvas Snapshot (PNG)"
          >
            <Download size={14} />
          </button>

          <button
            type="button"
            className={styles.wallActionBtn}
            onClick={() => {
              setPan({ x: 0, y: 0 });
              setZoom(1);
            }}
            title="Reset Canvas View (0,0)"
          >
            <RotateCcw size={14} />
          </button>
        </div>
      </div>

      {/* ─── Infinite Canvas Area ─── */}
      <canvas
        ref={canvasRef}
        className={`${styles.wallCanvas} ${
          tool === "pan" || isPanning
            ? styles.wallCanvasPan
            : tool === "note" || tool === "stamp"
            ? styles.wallCanvasCrosshair
            : styles.wallCanvasDraw
        }`}
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        onPointerLeave={handlePointerUp}
        onWheel={handleWheel}
      />

      {/* ─── DOM Sticky Notes Layer (Transformed) ─── */}
      <div
        className={styles.wallDomLayer}
        style={{
          transform: `translate(${containerRef.current ? containerRef.current.clientWidth / 2 + pan.x : pan.x}px, ${
            containerRef.current ? containerRef.current.clientHeight / 2 + pan.y : pan.y
          }px) scale(${zoom})`,
        }}
      >
        {/* Sticky Notes */}
        {notes.map((note) => (
          <div
            key={note.id}
            className={`${styles.stickyNoteCard} ${isLightBoard ? styles.stickyNoteCardLight : styles.stickyNoteCardDark}`}
            style={{
              transform: `translate(${note.x}px, ${note.y}px)`,
              borderLeftColor: note.color || "#cba6f7",
            }}
          >
            <div className={styles.stickyNoteHeader}>
              <span className={styles.stickyNoteEmoji}>{note.emoji || "🐧"}</span>
              <span className={styles.stickyNoteAuthor} style={{ color: note.color || "#cba6f7" }}>
                {note.author}
              </span>
            </div>
            <p className={styles.stickyNoteText}>{note.text}</p>
            <div className={styles.stickyNoteFooter}>
              <button
                type="button"
                className={styles.stickyNoteLikeBtn}
                onClick={(e) => {
                  e.stopPropagation();
                  handleLikeNote(note.id);
                }}
              >
                <Heart size={12} fill="#f38ba8" color="#f38ba8" />
                <span>{note.likes || 0}</span>
              </button>
              <span className={styles.stickyNoteDate}>
                {note.created_at ? new Date(note.created_at).toLocaleDateString() : "Just now"}
              </span>
            </div>
          </div>
        ))}

        {/* Stamps & Stickers */}
        {stamps.map((stamp) => (
          <div
            key={stamp.id}
            className={styles.wallStampItem}
            style={{
              transform: `translate(${stamp.x - stamp.size / 2}px, ${stamp.y - stamp.size / 2}px)`,
              width: stamp.size,
              height: stamp.size,
            }}
          >
            <img src={stamp.src} alt="" />
          </div>
        ))}
      </div>

      {/* ─── Bottom HUD & TheWall Live Indicator ─── */}
      <div
        className={`${styles.wallHud} ${isLightBoard ? styles.wallHudLight : styles.wallHudDark}`}
      >
        {/* Live TheWall Status */}
        <div className={styles.wallLiveSyncBadge} title="Permanent real-time canvas synchronized across all visitors">
          <span className={`${styles.wallLiveDot} ${isSyncing ? styles.wallLiveDotSyncing : ""}`} />
          <span className={styles.wallLiveText}>TheWall</span>
          <span className={styles.wallStatsCounts}>
            ({strokes.length} strokes · {notes.length} notes · {stamps.length} stamps)
          </span>
        </div>

        <div className={styles.wallHudRightGroup}>
          <span className={styles.wallCoordBadge}>
            X: {Math.round(-pan.x / zoom)} | Y: {Math.round(-pan.y / zoom)}
          </span>
          <span className={styles.wallZoomBadge}>{Math.round(zoom * 100)}%</span>
          <div className={styles.wallZoomBtns}>
            <button
              type="button"
              onClick={() => setZoom((z) => Math.min(z * 1.15, 3.5))}
              className={styles.wallHudBtn}
              title="Zoom In"
            >
              <ZoomIn size={14} />
            </button>
            <button
              type="button"
              onClick={() => setZoom((z) => Math.max(z / 1.15, 0.25))}
              className={styles.wallHudBtn}
              title="Zoom Out"
            >
              <ZoomOut size={14} />
            </button>
          </div>
        </div>
      </div>

      {/* ─── Sticky Note Creation Modal ─── */}
      {showNoteModal && (
        <div className={styles.noteModalOverlay} onClick={() => setShowNoteModal(false)}>
          <div className={styles.noteModalDialog} onClick={(e) => e.stopPropagation()}>
            <div className={styles.noteModalHeader}>
              <h3>Leave a Sticky Note</h3>
              <button
                type="button"
                className={styles.noteModalClose}
                onClick={() => setShowNoteModal(false)}
              >
                <X size={18} />
              </button>
            </div>

            <form onSubmit={handleSubmitNote} className={styles.noteModalForm}>
              <div className={styles.noteInputRow}>
                <label>
                  <span>Your Name / Handle</span>
                  <input
                    type="text"
                    placeholder="e.g. vlad / @friend"
                    value={noteAuthor}
                    onChange={(e) => setNoteAuthor(e.target.value)}
                    required
                  />
                </label>
              </div>

              <div className={styles.noteInputRow}>
                <label>
                  <span>Message / Note</span>
                  <textarea
                    rows={3}
                    placeholder="Write a message, congrats, or leave your mark..."
                    value={noteText}
                    onChange={(e) => setNoteText(e.target.value)}
                    required
                  />
                </label>
              </div>

              <div className={styles.noteEmojiPicker}>
                <span>Emoji Stamp:</span>
                <div className={styles.noteEmojiList}>
                  {EMOJIS.map((em) => (
                    <button
                      key={em}
                      type="button"
                      className={`${styles.noteEmojiBtn} ${noteEmoji === em ? styles.noteEmojiBtnActive : ""}`}
                      onClick={() => setNoteEmoji(em)}
                    >
                      {em}
                    </button>
                  ))}
                </div>
              </div>

              <div className={styles.noteColorPicker}>
                <span>Accent Color:</span>
                <div className={styles.noteColorList}>
                  {DRAWING_PALETTE.slice(0, 8).map((c) => (
                    <button
                      key={c.name}
                      type="button"
                      className={`${styles.noteColorBtn} ${noteColor === c.color ? styles.noteColorBtnActive : ""}`}
                      style={{ backgroundColor: c.color }}
                      onClick={() => setNoteColor(c.color)}
                    />
                  ))}
                </div>
              </div>

              <div className={styles.noteModalActions}>
                <button
                  type="button"
                  className={styles.noteModalCancelBtn}
                  onClick={() => setShowNoteModal(false)}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className={styles.noteModalSubmitBtn}
                  disabled={isSubmittingNote}
                >
                  <Send size={15} />
                  <span>{isSubmittingNote ? "Pinning..." : "Pin to TheWall"}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
