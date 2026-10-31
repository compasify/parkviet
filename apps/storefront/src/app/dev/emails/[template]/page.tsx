import Link from "next/link";
import { notFound } from "next/navigation";
import { render } from "react-email";
import { emailFixtures, getEmailFixture } from "../fixtures";

interface PreviewPageProps {
  params: Promise<{ template: string }>;
  searchParams: Promise<{ format?: string }>;
}

export async function generateStaticParams() {
  return emailFixtures.map((f) => ({ template: f.slug }));
}

export default async function EmailPreviewPage({
  params,
  searchParams,
}: PreviewPageProps) {
  if (process.env.NODE_ENV === "production") {
    notFound();
  }

  const { template } = await params;
  const { format } = await searchParams;
  const fixture = getEmailFixture(template);

  if (!fixture) {
    notFound();
  }

  const element = fixture.render();

  if (format === "text") {
    const text = await render(element, { plainText: true });
    return (
      <pre
        style={{
          margin: 0,
          padding: "16px",
          whiteSpace: "pre-wrap",
          wordBreak: "break-word",
          fontFamily: "ui-monospace, SFMono-Regular, monospace",
          fontSize: "12px",
        }}
      >
        {text}
      </pre>
    );
  }

  const html = await render(element);

  return (
    <div
      style={{
        fontFamily:
          '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
      }}
    >
      <div
        style={{
          padding: "12px 16px",
          borderBottom: "1px solid #e5e7eb",
          display: "flex",
          alignItems: "center",
          gap: "16px",
        }}
      >
        <Link href="/dev/emails" style={{ color: "#6b7280" }}>
          ← All templates
        </Link>
        <strong style={{ color: "#111827" }}>{fixture.label}</strong>
        <Link
          href={`/dev/emails/${fixture.slug}?format=text`}
          style={{ marginLeft: "auto", color: "#6b7280" }}
        >
          View plain text
        </Link>
      </div>
      <iframe
        title={`${fixture.label} preview`}
        srcDoc={html}
        style={{
          width: "100%",
          minHeight: "calc(100vh - 50px)",
          border: 0,
        }}
      />
    </div>
  );
}
