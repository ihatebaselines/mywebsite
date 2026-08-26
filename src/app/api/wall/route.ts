import { NextResponse } from "next/server";
import fs from "fs/promises";
import path from "path";
import { WallStroke, WallNote, WallStamp } from "@/lib/supabase";

const STATE_FILE = path.join(process.cwd(), "src", "content", "wallState.json");

interface WallState {
  strokes: WallStroke[];
  notes: WallNote[];
  stamps: WallStamp[];
}

let memoryState: WallState | null = null;

async function loadState(): Promise<WallState> {
  if (memoryState) return memoryState;
  try {
    const raw = await fs.readFile(STATE_FILE, "utf-8");
    memoryState = JSON.parse(raw);
    return memoryState!;
  } catch (err) {
    console.warn("Could not read wallState.json, initializing default:", err);
    memoryState = {
      strokes: [],
      notes: [
        {
          id: "welcome-note-ihatebaselines",
          x: 0,
          y: 0,
          text: 'Welcome to "TheWall"! A permanent infinite space where you can draw, leave notes, and make your mark. Do whatever you want! 🐧✨',
          author: "ihatebaselines",
          color: "#cba6f7",
          emoji: "🐧",
          likes: 42,
          created_at: new Date().toISOString(),
        },
      ],
      stamps: [],
    };
    return memoryState!;
  }
}

async function persistState(state: WallState) {
  try {
    await fs.writeFile(STATE_FILE, JSON.stringify(state, null, 2), "utf-8");
  } catch (err) {
    console.error("Error saving wall state to disk:", err);
  }
}

export async function GET() {
  try {
    const state = await loadState();
    return NextResponse.json({
      success: true,
      strokes: state.strokes || [],
      notes: state.notes || [],
      stamps: state.stamps || [],
    });
  } catch (err: any) {
    return NextResponse.json({ success: false, error: err.message }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { type, data } = body;
    const state = await loadState();

    if (type === "stroke" && data) {
      state.strokes.push(data);
      // Keep up to 3000 strokes in memory & file
      if (state.strokes.length > 3000) state.strokes.shift();
      await persistState(state);
      return NextResponse.json({ success: true, item: data });
    }

    if (type === "note" && data) {
      state.notes.push(data);
      await persistState(state);
      return NextResponse.json({ success: true, item: data });
    }

    if (type === "stamp" && data) {
      state.stamps.push(data);
      await persistState(state);
      return NextResponse.json({ success: true, item: data });
    }

    if (type === "like_note" && data?.id) {
      const note = state.notes.find((n) => n.id === data.id);
      if (note) {
        note.likes = (note.likes || 0) + 1;
        await persistState(state);
      }
      return NextResponse.json({ success: true, likes: note?.likes || 0 });
    }

    return NextResponse.json({ success: false, message: "Invalid payload" }, { status: 400 });
  } catch (err: any) {
    return NextResponse.json({ success: false, error: err.message }, { status: 500 });
  }
}
