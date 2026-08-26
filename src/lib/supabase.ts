import { createClient } from "@supabase/supabase-js";

export const SUPABASE_URL = "https://zrrcrhtzoupldvfcvmsz.supabase.co";
export const SUPABASE_ANON_KEY = "sb_publishable_gQ0h8n5vft2HhDGaOpGM0A_a1L3sT3E";
export const BUCKET_NAME = "bucket";

// Create client
export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export type WallStroke = {
  id: string;
  color: string;
  width: number;
  points: { x: number; y: number }[];
  author?: string;
  created_at?: string;
};

export type WallNote = {
  id: string;
  x: number;
  y: number;
  text: string;
  author: string;
  avatar_url?: string;
  color?: string;
  emoji?: string;
  likes?: number;
  created_at?: string;
};

export type WallStamp = {
  id: string;
  x: number;
  y: number;
  type: string;
  src: string;
  size: number;
  author?: string;
  created_at?: string;
};

/**
 * Upload a file/image to Supabase Storage bucket 'bucket'
 */
export async function uploadImageToStorage(file: Blob, path: string): Promise<string | null> {
  try {
    const { data, error } = await supabase.storage
      .from(BUCKET_NAME)
      .upload(path, file, {
        cacheControl: "3600",
        upsert: true,
      });

    if (error) {
      console.warn("Supabase storage upload error:", error.message);
      return null;
    }

    const { data: publicUrlData } = supabase.storage
      .from(BUCKET_NAME)
      .getPublicUrl(data.path);

    return publicUrlData.publicUrl;
  } catch (err) {
    console.error("Storage upload exception:", err);
    return null;
  }
}
