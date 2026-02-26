import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import admin from "npm:firebase-admin";

let firebaseInitialized = false;

function initFirebase() {
  if (firebaseInitialized) return;

  const base64 = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_BASE64");
  if (!base64) throw new Error("FIREBASE_SERVICE_ACCOUNT_BASE64 not found");

  const json = atob(base64);
  const serviceAccount = JSON.parse(json);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  firebaseInitialized = true;
  console.log("Firebase initialized");
}

serve(async () => {
  try {
    initFirebase();

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error("Supabase env missing");
    }

    const res = await fetch(
      `${supabaseUrl}/rest/v1/devices?select=push_token`,
      {
        headers: {
          apikey: serviceRoleKey,
          Authorization: `Bearer ${serviceRoleKey}`,
        },
      },
    );

    if (!res.ok) {
      const text = await res.text();
      throw new Error(`Failed to fetch devices: ${text}`);
    }

    const devices = await res.json();

    if (!Array.isArray(devices)) {
      console.error("Invalid devices response:", devices);
      throw new Error("Devices is not an array");
    }

    const tokens = devices
      .map((d) => d.push_token)
      .filter((t) => typeof t === "string" && t.length > 0);

    console.log(`Tokens found: ${tokens.length}`);

    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({ success: 0, failed: 0, message: "No tokens" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: "Satu Ayat Sehari",
        body: "Mari luangkan waktu sejenak untuk firman Tuhan hari ini",
      },
    });

    console.log("FCM detail:", JSON.stringify(response.responses, null, 2));

    return new Response(
      JSON.stringify({
        success: response.successCount,
        failed: response.failureCount,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Edge Error:", err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
