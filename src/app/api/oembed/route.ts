import { NextResponse } from "next/server";

export const dynamic = "force-static";

export async function GET() {
  return NextResponse.json(
    {
      version: "1.0",
      type: "rich",
      title: "ihatebaselines. — Vlad Andrei Rus",
      description:
        "Portfolio, notes and projects by Vlad Andrei Rus — AI architectures, machine learning, competitive programming, math, and building things from zero.",
      author_name: "Vlad Andrei Rus",
      author_url: "https://ihatebaselines.com",
      provider_name: "ihatebaselines",
      provider_url: "https://ihatebaselines.com",
      thumbnail_url: "https://ihatebaselines.com/images/ihatebaselines.jpg",
      thumbnail_width: 800,
      thumbnail_height: 400,
      width: 800,
      height: 400,
      html: `<iframe src="https://ihatebaselines.com" width="800" height="400" frameborder="0" title="ihatebaselines preview"></iframe>`,
    },
    {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Cache-Control": "public, max-age=86400, s-maxage=86400",
      },
    }
  );
}
