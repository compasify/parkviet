import type { SignatureParty } from '../../lib/receipt-template/types';

// Signature boxes side by side, each with room to sign under its label.
export function SignatureBlock({
  parties,
}: {
  parties: { party: SignatureParty; label: string }[];
}) {
  return (
    <div
      className="receipt-signatures"
      style={{ gridTemplateColumns: `repeat(${parties.length}, minmax(0, 1fr))` }}
    >
      {parties.map(({ party, label }) => (
        <div key={party} className="receipt-signature">
          <strong>{label}</strong>
        </div>
      ))}
    </div>
  );
}
