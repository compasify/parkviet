import Link from "next/link";
import { notFound } from "next/navigation";
import { emailFixtures } from "./fixtures";

export default function EmailPreviewIndex() {
  if (process.env.NODE_ENV === "production") {
    notFound();
  }

  return (
    <div
      style={{
        fontFamily:
          '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
        maxWidth: "640px",
        margin: "0 auto",
        padding: "40px 20px",
      }}
    >
      <h1 style={{ fontSize: "24px", marginBottom: "8px" }}>Email Previews</h1>
      <p style={{ color: "#6b7280", marginBottom: "24px" }}>
        Dev-only previews of transactional email templates. Renders the same
        templates used by webhook handlers, with sample data.
      </p>
      <ul style={{ listStyle: "none", padding: 0, margin: 0 }}>
        {emailFixtures.map((fixture) => (
          <li key={fixture.slug} style={{ marginBottom: "8px" }}>
            <Link
              href={`/dev/emails/${fixture.slug}`}
              style={{
                display: "block",
                padding: "12px 16px",
                border: "1px solid #e5e7eb",
                borderRadius: "8px",
                color: "#111827",
                textDecoration: "none",
              }}
            >
              {fixture.label}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
