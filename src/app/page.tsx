import Link from "next/link";
import { Sparkles, ArrowRight, ShieldCheck, Palette, Users } from "lucide-react";

export default function HomePage() {
  return (
    <div className="flex flex-col min-h-screen">
      <header className="border-b px-6 py-4 flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <Sparkles className="w-6 h-6 text-primary" />
          <span className="font-bold text-xl tracking-tight">Undangan Digital</span>
        </div>
        <nav className="flex items-center gap-4 text-sm font-medium">
          <Link href="/templates" className="text-muted-foreground hover:text-foreground transition-colors">
            Katalog
          </Link>
          <Link href="/pricing" className="text-muted-foreground hover:text-foreground transition-colors">
            Harga
          </Link>
          <Link
            href="/login"
            className="px-4 py-2 rounded-md bg-primary text-primary-foreground hover:bg-primary/90 transition-colors"
          >
            Masuk
          </Link>
        </nav>
      </header>

      <main className="flex-1 flex flex-col items-center justify-center p-8 text-center max-w-4xl mx-auto">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-secondary text-secondary-foreground text-xs font-semibold mb-6">
          <Sparkles className="w-3.5 h-3.5" />
          Platform Jasa Pembuatan Undangan Digital
        </div>
        <h1 className="text-4xl sm:text-6xl font-extrabold tracking-tight mb-6">
          Undangan Digital Eksklusif, Dikelola Profesional
        </h1>
        <p className="text-lg text-muted-foreground mb-8 max-w-2xl">
          Pilih template favorit Anda, kirim materi acara, dan biarkan tim kami mengerjakan desain, konfigurasi, hingga publikasi undangan digital berkualitas tinggi.
        </p>

        <div className="flex flex-wrap items-center justify-center gap-4 mb-16">
          <Link
            href="/templates"
            className="inline-flex items-center gap-2 px-6 py-3 rounded-lg bg-primary text-primary-foreground font-semibold hover:bg-primary/90 transition-colors shadow-sm"
          >
            Jelajahi Template
            <ArrowRight className="w-4 h-4" />
          </Link>
          <Link
            href="/pricing"
            className="inline-flex items-center gap-2 px-6 py-3 rounded-lg border border-input bg-background font-semibold hover:bg-accent hover:text-accent-foreground transition-colors"
          >
            Lihat Paket Layanan
          </Link>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 w-full text-left">
          <div className="p-6 rounded-xl border bg-card">
            <Palette className="w-8 h-8 text-primary mb-3" />
            <h3 className="font-semibold text-lg mb-1">Desain Berkualitas</h3>
            <p className="text-sm text-muted-foreground">
              Koleksi template wedding, birthday, corporate, dan lainnya yang selalu responsif di semua perangkat.
            </p>
          </div>
          <div className="p-6 rounded-xl border bg-card">
            <ShieldCheck className="w-8 h-8 text-primary mb-3" />
            <h3 className="font-semibold text-lg mb-1">Managed Production</h3>
            <p className="text-sm text-muted-foreground">
              Admin memeriksa data acara, melakukan penyesuaian desain, dan melakukan QA sebelum publikasi.
            </p>
          </div>
          <div className="p-6 rounded-xl border bg-card">
            <Users className="w-8 h-8 text-primary mb-3" />
            <h3 className="font-semibold text-lg mb-1">Guest & RSVP</h3>
            <p className="text-sm text-muted-foreground">
              Manajemen tamu undangan yang terintegrasi dengan formulir RSVP dan ucapan secara real-time.
            </p>
          </div>
        </div>
      </main>

      <footer className="border-t py-6 text-center text-sm text-muted-foreground">
        © {new Date().getFullYear()} Digital Invitation Service Platform. All rights reserved.
      </footer>
    </div>
  );
}
