import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Digital Invitation Platform",
  description: "Platform layanan pembuatan undangan digital profesional dan elegan",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="id">
      <body className="min-h-screen bg-background font-sans antialiased">
        {children}
      </body>
    </html>
  );
}
